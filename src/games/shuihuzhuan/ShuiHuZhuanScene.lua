--[[
*	水浒传
*	@author：gwj
]]
local ShuiHuZhuanScene = class("ShuiHuZhuanScene",require("src.base.extend.CCSceneExtend"),IEventListener)
local COLUMN_COUNT = 5		--列总数
local LINE_COUNT = 3		--行总数
local BEFORE_WAIT_TIME = 0.5	--转动开始之前的等待时间
local PLAY_INTERVAL = 0.5    --每列之间的间隔
function ShuiHuZhuanScene:ctor(room)
	self:super("ctor")
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self.room = room
	self.noNeedClearRes = false
	self.isinit = false
	self.lineItems = {}
	self.controller = require("src.games.shuihuzhuan.data.ShuiHuZhuanController").getInstance()
	self.soundController = require("src.games.shuihuzhuan.data.ShuiHuZhuanSoundController").getInstance()
	self:initUi()
	self:initData()
	require("src.ui.item.TalkControl").show(self.room,self,nil,108)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(140)),110)
end
local LIST_POSITION = {
	cc.p(14,0),
	cc.p(234,0),
	cc.p(454,0),
	cc.p(674,0),
	cc.p(894,0)
}

function ShuiHuZhuanScene:handlerEvent(event,arg)
	--金币发生改变
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		self.main_layout:updateGold()
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		display.enterScene("src.ui.ReloginScene",{self.room})
	end
end
--初始化UI
function ShuiHuZhuanScene:initUi()
	self.game_layouts={} 		--转动的列容器
	self.runState = false
	self.column_count = 0
	self.isAuto = false
	self.isPlayAniNow = false	--是否正在播放动画
	local main_layout = require("src.games.shuihuzhuan.ui.ShuiHuZhuanUiPanel").new()
	self:addChild(main_layout)
	self.main_layout = main_layout
	self.content_layout = main_layout:getContentLayout()
	local function gamestop_event(event,index)
		self.column_count=self.column_count+1
		-- self:playSingleSpecial(index)
		if self.column_count == COLUMN_COUNT then
			self:gameOver()
		end
	end
	for i=1,COLUMN_COUNT do
		local gameLayout=require("src.games.shuihuzhuan.ui.GameColumnLayout").new(i)
		gameLayout:setPosition(LIST_POSITION[i])
		gameLayout:addEventListener("LIST_GAME_STOP",gamestop_event)
		self.content_layout:addChild(gameLayout,0)
		table.insert(self.game_layouts,gameLayout)
	end

	self.main_layout:addEventListener("UI_MAIN_EVENT",function(event,eventtype,parms)
		if eventtype == "START_EVENT" then	--开始点击
			if self.isAuto then
				self.isAuto = false
				self:stopGame()
				return
			end
			if not self.runState then
				self:playGame()
			else
				if self.isPlayAniNow then
					self:quickOver()
				else
					self:stopGame()
				end
			end
		elseif eventtype == "ACTO_EVENT" then	--自动开始
			self.isAuto = true
			self:playGame()
			self.main_layout:autoMode()
		elseif eventtype == "ADD_BET" then  --添加下注
			self.controller:addBetMoney()
			self.main_layout:updateYaFen()
		elseif eventtype == "CUTDOWN_BET" then  --减少下注
			self.controller:cutdownYaFen()
			self.main_layout:updateYaFen()
		elseif eventtype == "DICE_ENTER" then	--骰子
			local diceWindow = require("src.games.shuihuzhuan.ui.ShuiHuZhuanDiceWindows").show(self.content_data.winMoney)
			diceWindow:addEventListener("SHZ_DICE_WINDOW_OUT",function(event)
				self.main_layout:updateGold()
				self.main_layout:setCompareBtnState(false)
			end)
		end
	end)
end

--初始化数据
function ShuiHuZhuanScene:initData()
	ConnectMgr.connect("src.games.shuihuzhuan.content.ShuiHuZhuanInitConnect",function(result)
		if result ~= false then
			self.isinit = true
			self.main_layout:updateYaFen()
		end
	end)
end

--播放轮播线条
function ShuiHuZhuanScene:playBlinkLine(linedatas)
	local length = #linedatas
	local index = 0
	if length == 0 then
		return
	end
	local turns_action = nil
	local display_time = 0.5
	local function binkStart()
		SoundsManager.playSound("shz_turn_compare_bt")
		index = index + 1
		local line_data = linedatas[index]
		local item = nil
		item = self:getLineItem(line_data)
		item:setVisible(true)
		item:runAction(cc.Sequence:create({
			cc.DelayTime:create(display_time),
			cc.CallFunc:create(function(sender)
				sender:setVisible(false)
			end)
		}))
		self:playRect(line_data)
		if index == length then
			if turns_action then
				self:stopAction(turns_action)
				turns_action = nil
			end
		end
	end
	binkStart()
	-- SoundsManager.playSound("FS_addScoring",true)
	if length > 1 then
		turns_action = self:schedule(function()
			binkStart()
		end,display_time)
		self.controller:addActionHandler(turns_action)
	end
end

function ShuiHuZhuanScene:playRect(line_data)
	for i=1,#self.game_layouts do
		self.game_layouts[i]:hideAll()
	end
	if line_data.direction == 0 then
		for i=1,line_data.count do
			self.game_layouts[i]:itemNormalByIndex(line_data.locations[i])
		end
	else
		for i=COLUMN_COUNT,line_data.count,-1 do
			self.game_layouts[i]:itemNormalByIndex(line_data.locations[i])
		end
	end
end

function ShuiHuZhuanScene:playAnimation(line_datas)
	for i=1,#line_datas do
		local line_data = line_datas[i]
		if line_data.direction == 0 then
			for i=1,line_data.count do
				self.game_layouts[i]:playPrizeByIndex(line_data.locations[i])
			end
		else
			for i=COLUMN_COUNT,line_data.count,-1 do
				self.game_layouts[i]:playPrizeByIndex(line_data.locations[i])
			end
		end
	end
end

function ShuiHuZhuanScene:playFullPrize()
	for x=1,#self.game_layouts do
		for y=1,LINE_COUNT do
			self.game_layouts[x]:playPrizeByIndex(y)
		end
	end
end

--创建线条
function ShuiHuZhuanScene:getLineItem(linedata)
	local lineSid = linedata.sid
	if self.lineItems[lineSid] then
		return self.lineItems[lineSid]
	end
	local line_img = display.newDynamicImage("game/shuihuzhuan/line/shz_line_"..lineSid..".png")
	line_img:setPosition(cc.p(680,linedata.position))
	self.main_layout:addChild(line_img,2)
	self.lineItems[lineSid] = line_img
	return line_img
end

--根据索引获取特效元素
function ShuiHuZhuanScene:createEffect(column,line)
	local effect = self.effectList[column][line]
	if not effect then
		local column_layout = self.game_layouts[column]
		local x = column_layout:getPositionX()+ELEMENT_WIDTH/2
		local y = column_layout:getPositionY()+ELEMENT_HEIGHT*(line-1)+ELEMENT_HEIGHT/2
		local etype = column_layout:getTypeByIndex(line)
		local data = require("src.games.shuihuzhuan.data.ShuiHuZhuan_element_data").new(etype)
		effect = require("src.games.shuihuzhuan.ui.GameEffect").new(data,self.main_layout.isFreeState)
		self.content_layout:addChild(effect,2)
		effect:setPosition(cc.p(x,y))
		self.effectList[column][line] = effect
	end
	return effect
end

--显示得分
function ShuiHuZhuanScene:showScore(value)
	local layout = display.newLayout()
	layout:setAnchorPoint(cc.p(0.5,0.5))
	local score_icon = display.newImage("shz_icon_26.png")
	score_icon:setAnchorPoint(cc.p(0,0.5))
	score_icon:setPosition(cc.p(0,50))
	layout:addChild(score_icon)
	local score_label = ccui.TextAtlas:create(1,"game/shuihuzhuan/shz_number_2.png",95,95,0)
	score_label:setAnchorPoint(cc.p(0,0.5))
	score_label:setString(value)
	score_label:setPosition(cc.p(score_icon:getContentSize().width,50))
	layout:addChild(score_label)
	local layout_size = cc.size(score_icon:getContentSize().width + score_label:getContentSize().width,100)
	layout:setContentSize(layout_size)
	layout:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
	self.main_layout:addChild(layout,5)
	if self.content_data.fullSid > 0 then
		local full_image = display.newImage("shz_full_font_"..self.content_data.fullSid..".png")
		full_image:setPosition(cc.p(layout_size.width/2,180))
		layout:addChild(full_image)
	end
	self.score_layout = layout
end

function ShuiHuZhuanScene:removeScore()
	if self.score_layout then
		self.score_layout:removeFromParent(true)
	end
	self.score_layout = nil
end

--开始旋转 specialIndex:特殊旋转标识
function ShuiHuZhuanScene:playGame()
	if self.runState or not self.isinit then return end
	ConnectMgr.connect("src.games.shuihuzhuan.content.ShuiHuZhuanPlayConnect",self.main_layout:getBetMoney(),function(result)
		if result then
			self.main_layout:setStartState(false)
			self.content_data = result
			self.main_layout:setCompareBtnState(false)
			self:desktopClean()
			self.soundController:roundOver()
			SoundsManager.playSound("shz_turn_start")
			self.runState = true
			self.isPlayAniNow = false
			self.main_layout:beginUpdateState()
			self.column_count = 0
			local i=0
			local wait_value = BEFORE_WAIT_TIME
			local interval_value = PLAY_INTERVAL
			for i=1,#self.game_layouts do
				self.game_layouts[i]:play(wait_value + ((i-1)*interval_value),self.content_data.element_datas[i])
			end
		end
	end)
end

--本回合结束
function ShuiHuZhuanScene:stopGame()
	for i=1,#self.game_layouts do
		self.game_layouts[i]:over()
	end
end

--停止旋转开始结算
function ShuiHuZhuanScene:gameOver()
	local sequence_array = {}
	table.insert(sequence_array,cc.DelayTime:create(0.2))
	table.insert(sequence_array,cc.CallFunc:create(function()
		self.isPlayAniNow = true
	end))
	if self.content_data.fullSid > 0 then
		table.insert(sequence_array,cc.CallFunc:create(function()
			self:playFullPrize()
		end))
		table.insert(sequence_array,cc.DelayTime:create(4))
		table.insert(sequence_array,cc.CallFunc:create(function()
			self:showScore(self.content_data.winMoney)
			self:elementNormal()
		end))
	else
		if #self.content_data.line_datas > 0 then
			table.insert(sequence_array,cc.CallFunc:create(function()
				self:playBlinkLine(self.content_data.line_datas)
			end))
			table.insert(sequence_array,cc.DelayTime:create(#self.content_data.line_datas))
			table.insert(sequence_array,cc.CallFunc:create(function()
				self:playAnimation(self.content_data.line_datas)
			end))
			table.insert(sequence_array,cc.DelayTime:create(4))
			table.insert(sequence_array,cc.CallFunc:create(function()
				self:showScore(self.content_data.winMoney)
				self:elementNormal()
			end))
		end
	end
	table.insert(sequence_array,cc.CallFunc:create(function()
		if self.isAuto then
			self.runState = false
			self:performWithDelay(function()
				self:playGame()
			end,0.5)
			self.main_layout:overUpdateState(self.content_data.winMoney)
		else
			self.isPlayAniNow = false
			self:quickOver()
		end
	end))
	local gameover_handler =  self:runAction(cc.Sequence:create(sequence_array))
	self.controller:addActionHandler(gameover_handler)
end

function ShuiHuZhuanScene:quickOver()
	if self.isPlayAniNow then
		self:elementNormal()
		self:desktopClean()
		self:showScore(self.content_data.winMoney)
	end
	self.main_layout:setStartState(true)
	self.main_layout:normalMode()
	if self.content_data.winMoney > 0 then
		self.main_layout:setCompareBtnState(true)
	end
	self.main_layout:overUpdateState(self.content_data.winMoney)
	self.runState = false
end

--移除线条
function ShuiHuZhuanScene:removeLines()
	for k,v in pairs(self.lineItems) do
		v:removeFromParent()
	end
	self.lineItems={}
end

function ShuiHuZhuanScene:elementNormal()
	for i=1,#self.game_layouts do
		self.game_layouts[i]:setNormalAll()
	end
end

--播放单个特殊元素 index:列 (百搭元素没有中奖也需要播放特效)
function ShuiHuZhuanScene:playSingleSpecial(column)
	local index=self.game_layouts[column]:getIndexByType(9)
	if index>0 then
		self.game_layouts[column]:playAnimationByIndex(index)
	end
end

--清场
function ShuiHuZhuanScene:desktopClean()
	for i=1,#self.controller.action_array do
		self:stopAction(self.controller.action_array[i])
	end
	self.controller:cleanActionHandler()
	SoundsManager.stopAllSounds()
	self:removeLines()
	self:removeScore()
end


function ShuiHuZhuanScene:onCleanup()
	SoundsManager.stopAllMusic()
	SoundsManager.stopAllSounds()
	self:removeAllEvent()
	if not self.noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
end

return ShuiHuZhuanScene