--[[
*	一拳超人
*	@author：gwj
]]
local FistSuperManScene = class("FistSuperManScene",function()
	local scene = display.extend("CCSceneExtend",cc.Scene:createWithPhysics())
	return scene
end,IEventListener)
local COLUMN_COUNT = 5		--列总数
local LINE_COUNT = 4		--行总数
local ELEMENT_WIDTH = 182	--每一项的宽度
local ELEMENT_HEIGHT = 140	--每一项的高度
local ELEMENT_MAXCOUNT = 12 --元素总数
local BEFORE_WAIT_TIME = 1	--转动开始之前的等待时间
local PLAY_INTERVAL = 0.5    --每列之间的间隔
local LIST_POSITION = {
	cc.p(10,10),
	cc.p(201,10),
	cc.p(392,10),
	cc.p(583,10),
	cc.p(774,10)
}
function FistSuperManScene:ctor(room)
	self:super("ctor")
	self.room = room
	self.noNeedClearRes = false
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	--设置场景引力
    self:getPhysicsWorld():setGravity(cc.p(0,-600))
	self.game_layouts={} 		--转动的列容器
	self.effectList={}			--正在使用的特效控件
	self.lineItems={}			--线控件集合
	self.column_count = 0 	 	--已经停止的列数
	self.playgame_action = nil	--是否正在启动
	self.freeCount = 0          --免费的次数
	self.Interval=0             --自动间隔
	self.freeCount=0            --累计免费次数
	self.autoCount = 0  		--自动的次数
	self.runState = false			--运行状态
	self.main_layout = nil		--主容器
	self.content_layout = nil	--内容容器
	self.speed_multiple = 1     --游戏速度的倍数
	self.isAtOnceStop = false	--是否立即停止
	self.controller = require("src.games.fistsuperman.data.FistsupermanController").getInstance()
	self.soundcontroller = require("src.games.fistsuperman.data.FistsupermanSoundController").getInstance()
	self:initUi()
	self:initData()

	require("src.ui.item.TalkControl").show(self.room,self,cc.p(0,D_SIZE.height/2 + 70),108)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(40)),110)

	SoundsManager.playMusic("yqcr_bg",true)
	
end

function FistSuperManScene:handlerEvent(event,arg)
	--金币发生改变
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		self.main_layout:updateScore()
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		display.enterScene("src.ui.ReloginScene",{self.room})
	end
end

--初始化UI
function FistSuperManScene:initUi()
	local main_layout = require("src.games.fistsuperman.ui.FistSuperManUiPanel").new()
	self:addChild(main_layout)
	self.main_layout = main_layout
	--内容
	local content_layout = main_layout:getContentLayout()
	self.content_layout = content_layout
	for i=1,COLUMN_COUNT do
		local gameLayout=require("src.games.fistsuperman.ui.GameColumnLayout").new(ELEMENT_MAXCOUNT,i)
		gameLayout:setPosition(LIST_POSITION[i])
		gameLayout:addEventListener("LIST_GAME_STOP",function(event,index)
			self:gameColumnStop(index)
		end)
		self.content_layout:addChild(gameLayout,0)
		table.insert(self.game_layouts,gameLayout)
	end
	self.main_layout:addEventListener("UI_MAIN_EVENT",function(event,eventtype,parms)
		if eventtype == "START_EVENT" then	--开始点击
			if not self.runState then
				self:playGame()
			else
				self:stopGame()
			end
		elseif eventtype == "ACTO_EVENT" then	--自动开始
			self.autoCount = parms
			self.main_layout:updateAutoCount(self.autoCount)
			if self.autoCount > 0 and not self.runState then
				self:playGame()
			end
		elseif eventtype == "SPEEDUP_EVENT" then  --加速按钮
			if parms then
				self.speed_multiple = 2
			else
				self.speed_multiple = 1
			end
			-- for i=1,COLUMN_COUNT do
			-- 	local gameLayout=self.game_layouts[i]
			-- 	gameLayout:speedUp(parms)
			-- end
		elseif eventtype == "ADD_BET" then  --添加下注
			self.controller:addBetMoney()
			self.main_layout:updateBet()
		elseif eventtype == "CUTDOWN_BET" then  --减少下注
			self.controller:cutdownBetMoney()
			self.main_layout:updateBet()
		elseif eventtype == "FREE_OVER_EVENT" then	--免费结束
			self:desktopClean()
			if parms > 40000000 then
				self:shootGold()
			end
		end
	end)
	-- self:shootGold()
end

--初始化数据
function FistSuperManScene:initData()
	for x=1,COLUMN_COUNT do
		self.effectList[x] = {}
		for y=1,LINE_COUNT do
			self.effectList[x][y] = false
		end
	end
	ConnectMgr.connect("src.games.fistsuperman.content.FistSuperManInitConnect",function(result)
		if self.controller:isFree() then
			self.main_layout:showFree(self.controller.totalFreeWinMoney)
		end
		self.main_layout:updateBet()
	end)
end

--启动旋转
function FistSuperManScene:runTurn()
	local i=0
	local wait_value = BEFORE_WAIT_TIME/self.speed_multiple
	local interval_value = PLAY_INTERVAL/self.speed_multiple
	self.playgame_action = self:schedule(function()
		i=i+1
		if i > COLUMN_COUNT then
			if self.playgame_action then
				self:stopAction(self.playgame_action)
				self.playgame_action = nil
			end
			return
		end

		local delay = nil
		if i >= 3 and self.content_data:getHasBonusByCloum(i) >= 2 then
			delay = 0
		elseif i == 5 and #self.content_data.maybeBlowCloums > 1 then
			delay = 0
		else
			delay = wait_value + interval_value*(i-1)
		end
		self.game_layouts[i]:play(self.content_data.element_datas[i],delay)
		if i == COLUMN_COUNT then
			self:stopAction(self.playgame_action)
			self.playgame_action = nil
		end
	end,0.05)
	self.controller:addActionHandler(self.playgame_action)
end

--有转动停止
function FistSuperManScene:gameColumnStop(index)
	self.column_count = self.column_count + 1
	if self.column_count == COLUMN_COUNT then
		self:gameOver()
		return
	end
	self:playSingleSpecial(self.column_count)
	local next_column = self.column_count+1
	if not self.isAtOnceStop and self.game_layouts[next_column].isManual then
		if next_column == 3 and self.content_data:getHasBonusByCloum(next_column) >= 2 then
			self.game_layouts[3]:setSpecial()
		elseif next_column == 5 and #self.content_data.maybeBlowCloums > 0 then
			self.game_layouts[5]:setSpecial(self.content_data.maybeBlowCloums)
		else
			self.game_layouts[next_column]:delayOver(PLAY_INTERVAL/self.speed_multiple)
		end
	end
end

--播放单个特殊元素 index:列 
function FistSuperManScene:playSingleSpecial(column)
	local index = self.game_layouts[column]:getIndexByType(11)
	if index>0 then
		SoundsManager.playSound("FS_BonusSingle")
	end
end

--播放免费奖特效
function FistSuperManScene:playBonusEffect(bonusCloums)
	self:showBonusMask()
	SoundsManager.playSound("FS_bonus")
	local count = 0
	for i=1,#bonusCloums do
		if bonusCloums[i] then
			local effect = self:createEffect(bonusCloums[i][1],bonusCloums[i][2])
			effect:playBonu(function()
				count = count + 1
				if count == #bonusCloums then
					self:removeEffect()
					self:removeBonusMask()
					SoundsManager.stopAudio("FS_bonus")
					self.main_layout:enterFreeEffect(self.content_data.addFreeCount)
				end
			end)
		end
	end
end

function FistSuperManScene:showBonusMask()
	local bonus_mask = display.newMask(self.content_layout:getContentSize())
	self.content_layout:addChild(bonus_mask,0)
	self.bonus_mask = bonus_mask
end

function FistSuperManScene:removeBonusMask()
	if self.bonus_mask then
		self.bonus_mask:removeFromParent(true)
		self.bonus_mask = nil
	end
end

--播放拳头 blowList 一个二维数组
function FistSuperManScene:playFistBlow()
	local function normalBlow()
		SoundsManager.playSound("FS_blow")
		local x = 6
		local function blowStart()        --普通铁拳
			if x == 1 then
				self:stopAction(self.fist_action)
				self.fist_action = nil
				self:performWithDelay(function()
					for x=1,#self.content_data.element_datas do
						local columns = self.content_data.element_datas[x]
						for y=1,#columns do
							if self.content_data.element_datas[x][y]:getBlowState() then
								local effect = self:createEffect(x,y)
								effect:playBigPrizeII()
							end
						end
					end
				end,0.8)
				return
			end
			x = x - 1
			for y=1,LINE_COUNT do
				if self.content_data.element_datas[x][y]:getBlowState() then
					local effect = self:createEffect(x,y)
					effect:playBigPrizeI()
				end
			end
		end
		blowStart()
		self.fist_action = self:schedule(function()
			blowStart()
		end,0.55)
	end
	local function freeBlow()        --免费模式的铁拳
		local middle_index = 3
		SoundsManager.playSound("FS_Freeblow")
		local sort_array = {{3},{2,4},{1,5}}
		local temp = 0
		local function freeblowStart()
			if temp == #sort_array then
				self:stopAction(self.freefist_action)
				self.freefist_action = nil
				self:performWithDelay(function()
					for x=1,#self.content_data.element_datas do
						local columns = self.content_data.element_datas[x]
						for y=1,#columns do
							if self.content_data.element_datas[x][y]:getBlowState() then
								local effect = self:createEffect(x,y)
								effect:playBigPrizeII()
							end
						end
					end
				end,0.8)
				return
			end
			temp = temp + 1
			for y=1,LINE_COUNT do
				for i=1,#sort_array[temp] do
					local x = sort_array[temp][i]
					if self.content_data.element_datas[x][y]:getBlowState() then
						local effect = self:createEffect(x,y)
						effect:playBigPrizeI()
					end
				end
			end
		end
		freeblowStart()
		self.freefist_action = self:schedule(function()
			freeblowStart()
		end,0.55)
	end
	if self.controller:isFree() then
		freeBlow()
	else
		normalBlow()
	end
end

--播放元素动画(由于存在遮罩问题,特效就放在更高层级)
function FistSuperManScene:playElement(column,line,etype)
	local effect = self.effectList[column][line]
	effect:playPrize()
end

--播放连线元素的边框
function FistSuperManScene:playRect(line_data)
	self:hideRect()
	local locations = line_data.locations
	local count = line_data.count
	for i=1,count do
		local effect = self:createEffect(i,locations[i])
		if effect then
			effect:setRect(line_data.sid,line_data:getBlowState())
			if i == 1 then
				effect:setMultiple(line_data.multiple)
			end
		end
	end
end

--播放普通线
function FistSuperManScene:playNormalLine(linedatas)
	self:hideAllEffect()
	local length = #linedatas
	for i=1,length do
		local line_img = self:getLineItem(linedatas[i].sid,3)
		line_img:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.9),
			cc.CallFunc:create(function(sender)
				sender:setVisible(false)
				sender:setLocalZOrder(1)
			end)
		}))
	end
	SoundsManager.playSound("FS_addScoring",true)
end

--播放轮播线条
function FistSuperManScene:playBlinkLine(linedatas)
	local length = #linedatas
	local index = 0
	if length == 0 then
		return
	end
	local topItem = nil
	local function binkStart()
		index = index + 1
		local line_data = linedatas[index] 
		local item = nil
		item = self:getLineItem(line_data.sid)
		item:setVisible(true) 
		self:playRect(line_data)
		if length > 1 then
			if topItem then
				topItem:setVisible(false)
			end
			topItem = item
			if index == length then
				index = 0
			end
		end
	end
	binkStart()
	if length > 1 then
		local turns_action = self:schedule(function()
			binkStart()
		end,1.5)
		self.controller:addActionHandler(turns_action)
	end
end

--创建线条
function FistSuperManScene:getLineItem(lineSid,zorder)
	if self.lineItems[lineSid] then
		return self.lineItems[lineSid]
	end
	local tZorder = 1
	if not zorder then
		tZorder = zorder
	end
	local line_img = display.newDynamicImage("game/fistsuperman/line/FS_Line_"..lineSid..".png")
	line_img:setAnchorPoint(cc.p(0,0))
	line_img:setPosition(10,0)
	self.content_layout:addChild(line_img)
	self.lineItems[lineSid] = line_img
	return line_img
end

--隐藏所有边框
function FistSuperManScene:hideRect()
	for i=1,#self.effectList do
		local columns = self.effectList[i]
		for n=1,#columns do
			if columns[n] then
				self.effectList[i][n]:hideRect()
			end
		end
	end
end

--加载中奖元素的控件
function FistSuperManScene:loadEffects(rewardDatas)
	for i=1,#rewardDatas do
		local data = rewardDatas[i]
		local line_data = require("src.games.fistsuperman.data.Fistsuperman_line_data").new(data.lineType)
		local element_sid = resultdata.sid
		local reward_count = resultdata.number
		for n=1,#reward_count do
			self:createEffect(n,line_data.locations[n])
		end
	end
end

--根据索引获取特效元素
function FistSuperManScene:createEffect(column,line)
	local effect = self.effectList[column][line]
	if not effect then
		local column_layout = self.game_layouts[column]
		local x = column_layout:getPositionX()+ELEMENT_WIDTH/2
		local y = column_layout:getPositionY()+ELEMENT_HEIGHT*(line-1)+ELEMENT_HEIGHT/2
		local etype = column_layout:getTypeByIndex(line)
		local data = require("src.games.fistsuperman.data.Fistsuperman_element_data").new(etype)
		
		effect = require("src.games.fistsuperman.ui.GameEffect").new(data,self.main_layout.isFreeState)
		self.content_layout:addChild(effect,2)
		effect:setPosition(cc.p(x,y))
		self.effectList[column][line] = effect
	end
	effect:setVisible(true)
	return effect
end

--开始旋转 specialIndex:特殊旋转标识
function FistSuperManScene:playGame()
	if self.playgame_action then return end
	SoundsManager:stopAudio("FS_addScoring")
	ConnectMgr.connect("src.games.fistsuperman.content.FistSuperManPlayConnect",self.controller:getBetMoney(),function(result)
		if result then
			self:desktopClean()
			self.isAtOnceStop = false
			self.runState = true
			if self.autoCount > 0 then
				self.main_layout:updateAutoCount(self.autoCount)
			else
				self.main_layout:setStartBtnState(3)
			end
			self.column_count = 0
			SoundsManager.playSound("FS_turn")
			self.content_data = result
			self.main_layout:updateBeginFreeLabels()
			self:runTurn()
		end
	end)
end

--游戏结束
function FistSuperManScene:gameOver()
	local delay = 0.5
	SoundsManager.stopAudio("FS_turn")
	local sequence_array = {}
	table.insert(sequence_array,cc.DelayTime:create(0.2))
	if self.content_data.isHasFree then --检查是否有免费奖
		self.autoCount = 0
		table.insert(sequence_array,cc.CallFunc:create(function()
			self:playBonusEffect(self.content_data.bonus_cloums)
		end))
		table.insert(sequence_array,cc.DelayTime:create(5))
	end
	if self.content_data.isBlowAction then	--是否有拳头
		local callback = cc.CallFunc:create(function()
			self:playFistBlow()
		end)
		table.insert(sequence_array,callback)
		table.insert(sequence_array,cc.DelayTime:create(4))
	end
	if #self.content_data.line_datas > 0 then
		table.insert(sequence_array,cc.CallFunc:create(function()
			self:playNormalLine(self.content_data.line_datas)
		end))
		table.insert(sequence_array,cc.DelayTime:create(1))
		table.insert(sequence_array,cc.CallFunc:create(function()
			self:playBlinkLine(self.content_data.line_datas)
		end))
		if self.speed_multiple == 1 then	--加速的时候只显示连线 不显示具体
			delay = delay + #self.content_data.line_datas
		end
	end

	local callback = cc.CallFunc:create(function()
		local isAuto = false
		if self.autoCount > 0 then
			isAuto = true
		elseif self.controller.maxFreeCount > self.controller.freeCountNow and self.main_layout.isFreeBegin then
			isAuto = true
		end
		self.main_layout:updateFreeOverState(self.content_data.winMoney,self.content_data.freeMultiple,self.content_data.totalFreeWinMoney,delay)
		self.runState = false
		if isAuto then
			self:autoPlayGame(delay)
		else
			self.main_layout:gameOver()
		end
	end)
	table.insert(sequence_array,callback)
	local quene_action = self:runAction(cc.Sequence:create(sequence_array))
	self.controller:addActionHandler(quene_action)
end

--[[本回合结束]]
function FistSuperManScene:stopGame()
	self.isAtOnceStop = true
	for i=1,#self.game_layouts do
		self.game_layouts[i]:stopAtOnceStop()
	end
end

--[[自动开始]]
function FistSuperManScene:autoPlayGame(delay)
	local auto_action = self:performWithDelay(function()
		if self.autoCount > 0 then
			self.autoCount = 999
			-- self.autoCount = self.autoCount - 1
			self.main_layout:updateAutoCount(self.autoCount)
			self:playGame()
		else
			self:playGame()
		end
	end,delay)
	self.controller:addActionHandler(auto_action)
end

--清场
function FistSuperManScene:desktopClean()
	for i=1,#self.controller.action_array do
		if self.controller.action_array[i] ~= nil then
			self:stopAction(self.controller.action_array[i])
		end
	end
	self.playgame_action = nil
	self.main_layout:winMoneyStop()
	self.controller:cleanActionHandler()
	self.soundcontroller:roundOver()
	SoundsManager.stopAllSounds()
	self:removeEffect()
	self:removeLines()
end

--隐藏特效
function FistSuperManScene:hideAllEffect()
	for i=1,#self.effectList do
		local lines = self.effectList[i]
		for n=1,#lines do
			if lines[n] then
				lines[n]:setVisible(false)
			end
		end
	end
end

--移除特效控件
function FistSuperManScene:removeEffect()
	for i=1,#self.effectList do
		local lines = self.effectList[i]
		for n=1,#lines do
			if lines[n] then
				lines[n]:removeFromParent(true)
				lines[n] = false
			end
		end
	end
end

--移除线条
function FistSuperManScene:removeLines()
	for k,v in pairs(self.lineItems) do
		v:removeFromParent()
	end
	self.lineItems={}
end

--发射炮弹
function FistSuperManScene:shootGold()
	SoundsManager.playSound("FS_goldBlow")
	local gold_Panel = display.newMask(cc.size(D_SIZE.width,D_SIZE.height),0)
	display.extend("CCNodeExtend",gold_Panel)
	self.main_layout:addChild(gold_Panel,4)
	local temp_number = 0
	local function singleGold()
		local goldSprite=require("src.games.fistsuperman.ui.GoldSprite").new()
	    gold_Panel:addChild(goldSprite)
	    local rotation = math.random(-180,180)
	    local position_x = math.random(-300,300)
	    goldSprite:setPosition(cc.p(D_SIZE.width/2 + position_x,-64))
	    goldSprite:getPhysicsBody():setVelocity(cc.p(rotation,1100))
	end

	local function goldFire()
		for i=1,1 do
			singleGold()
		end
	end
	gold_Panel:schedule(function()
		temp_number = temp_number + 1
		if temp_number <= 100 then
			goldFire()
		end
	end,0.04)

	gold_Panel:performWithDelay(function ()
		SoundsManager.stopAudio("FS_goldBlow")
		gold_Panel:removeFromParent(true)
	end,7.8)
	goldFire()
end

function FistSuperManScene:onCleanup()
	SoundsManager.stopAllMusic()
	SoundsManager.stopAllSounds()
	self.controller:init()
	self.soundcontroller:init()
	self:removeAllEvent()
	if not self.noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
end

return FistSuperManScene