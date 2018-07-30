--[[
*	烟花爆竹
*	@author：gwj
]]
local FirecrackerScene = class("FirecrackerScene",require("src.base.extend.CCSceneExtend"),IEventListener)
local soundController = require("src.games.firecracker.data.FirecrackerSoundController").getInstance()
local COLUMN_COUNT = 5		--列总数
local LINE_COUNT = 3		--行总数
local ELEMENT_WIDTH = 192	--每一项的宽度
local ELEMENT_HEIGHT = 162	--每一项的高度
local ELEMENT_MAXCOUNT = 13 --元素总数
local BEFORE_WAIT_TIME = 1	--转动开始之前的等待时间
local PLAY_INTERVAL = 0.5    --每列之间的间隔
local DEVIATION={
	[7]={["x"]=0,["y"]=0},
	[8]={["x"]=0,["y"]=0},
	[9]={["x"]=0,["y"]=0},
	[10]={["x"]=0,["y"]=0},
	[11]={["x"]=0,["y"]=0},
	[12]={["x"]=-1,["y"]=-1},
	[13]={["x"]=3,["y"]=0}
}
local LIST_POSITION = {
	cc.p(21,29),
	cc.p(223,29),
	cc.p(424,29),
	cc.p(625,29),
	cc.p(826,29)
}

--随机的音效

local RANDOM_WINSOUND={
	"firecracker_win2",
	"firecracker_win3",
	"firecracker_win4"
}

function FirecrackerScene:ctor(room)
	self:super("ctor")
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self.game_layouts={} 		--转动的列容器
	self.effectList={}			--正在使用的特效控件
	self.column_count = 0 	 	--已经停止的列数
	self.playgame_action = nil	--是否正在启动
	self.isFree=false			--是否正在免费状态
	self.freeCount = 0          --免费的次数
	self.Interval=0             --自动间隔
	self.freeCount=0            --累计免费次数
	self.autoCount = 0  		--自动的次数
	self.runState=false			--运行状态
	self.main_layout = nil		--主容器
	self.content_layout = nil	--内容容器
	self.speed_multiple = 1     --游戏速度的倍数
	self.controller = require("src.games.firecracker.data.FirecrackerController").getInstance()
	self.soundController = require("src.games.firecracker.data.FirecrackerSoundController").getInstance()
	self:initUi()
	self:initData()
	self.noNeedClearRes = false
	self.room = room
	require("src.ui.item.TalkControl").show(self.room,self,cc.p(0,D_SIZE.height/2 + 50),108)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(670)),110)
end

function FirecrackerScene:handlerEvent(event,arg)
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
function FirecrackerScene:initUi()
	local main_layout = require("src.games.firecracker.ui.FireCrackerUiPanel").new()
	self:addChild(main_layout)
	self.main_layout = main_layout
	--内容
	local content_layout = main_layout:getContentLayout()
	self.content_layout = content_layout
	for i=1,COLUMN_COUNT do
		local gameLayout=require("src.games.firecracker.ui.GameColumnLayout").new(ELEMENT_MAXCOUNT,i)
		gameLayout:setPosition(LIST_POSITION[i])
		gameLayout:addEventListener("LIST_GAME_STOP",function(event,index)
			self:gameColumnStop(index)
		end)
		self.content_layout:addChild(gameLayout)
		table.insert(self.game_layouts,gameLayout)
	end
	self.main_layout:addEventListener("UI_MAIN_EVENT",function(event,eventtype,parms)
		if eventtype == "START_EVENT" then	--开始点击
			if not self.runState then
				self:playGame()
			else
				self:stopGame()
			end
			self.soundController:playClick()
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
		elseif eventtype == "ADD_BET" then  --添加下注
			self.controller:addBetMoney()
			self.main_layout:updateBet()
		elseif eventtype == "CUTDOWN_BET" then  --减少下注
			self.controller:cutdownBetMoney()
			self.main_layout:updateBet()
		elseif eventtype == "FREE_OVER_EVENT" then	--免费结束
			self:desktopClean()
		end
	end)
end

--初始化数据
function FirecrackerScene:initData()
	for x=1,COLUMN_COUNT do
		self.effectList[x] = {}
		for y=1,LINE_COUNT do
			self.effectList[x][y] = false
		end
	end
	ConnectMgr.connect("src.games.firecracker.content.FirecrackerInitConnect",function(result)
		if self.controller:isFree() then
			self.main_layout:enterFreeState(self.controller.totalFreeWinMoney)
		end
		self.main_layout:updateBet()
	end)
end


--有转动停止
function FirecrackerScene:gameColumnStop(index)
	self.column_count = self.column_count + 1
	if not self.content_data.isFull then
		self:playSingleSpecial(index)
	end
	if self.column_count == COLUMN_COUNT then
		self:gameOver()
		return
	end
	local next_column = self.column_count + 1
	print("self.column_count-----------------------------------",self.column_count)
	if not self.isAtOnceStop and self.game_layouts[next_column].isManual then
		if next_column == 4 and self.content_data:getHasBonusByCloum(next_column) >= 2 then
			self.game_layouts[4]:setSpecial(3/self.speed_multiple)
			self.game_layouts[5]:setSpecial(6/self.speed_multiple)
		elseif next_column == 5 and not self.game_layouts[5].isSpecial and self.content_data:getHasBonusByCloum(5) >= 2 then
			self.game_layouts[5]:setSpecial(3/self.speed_multiple)
		elseif not self.game_layouts[next_column].isSpecial then
			self.game_layouts[next_column]:stopAtOnceStop()
		end
	end
end

--启动旋转
function FirecrackerScene:runTurn()
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
		if i >= 4 and self.content_data:getHasBonusByCloum(i) >= 2 then
			delay = 0
		else
			delay = wait_value + interval_value*(i-1)
		end
		self.game_layouts[i]:play(self.content_data.resultdata[i],delay)
		if i == COLUMN_COUNT then
			self:stopAction(self.playgame_action)
			self.playgame_action=nil
		end
	end,0.05)
	self.controller:addActionHandler(self.playgame_action)
end

--播放单个特殊元素 index:列 
function FirecrackerScene:playSingleSpecial(column)
	local index = self.game_layouts[column]:getIndexByType(13)
	if index>0 then
		local effect_sprite = self:createEffect(column,index)
		effect_sprite:setPositionX(effect_sprite:getPositionX() + 5)
		effect_sprite:setVisible(true)
		effect_sprite:playBonu(1)
		self.game_layouts[column]:hideByIndex(index)
		-- if not self.isAtOnceStop then
			SoundsManager.playSound("firecracker_tq1")
		-- end
	end
end

--播放免费奖特效
function FirecrackerScene:playBonusEffect(bonusCloums)
	-- SoundsManager.playSound("bdr_bonus")
	for i=1,#bonusCloums do
		local effect = self:createEffect(bonusCloums[i][1],bonusCloums[i][2])
		-- effect:setPositionX(effect:getPositionX() + 10)
		self.game_layouts[bonusCloums[i][1]]:hideByIndex(bonusCloums[i][2])
		effect:playBonu(#bonusCloums)
	end
	if #bonusCloums > 2 then
		self.autoCount = 0
		self.soundController:playOnlyOverSound("firecracker_tq3")
		self:performWithDelay(function()
			self.main_layout:enterFreeState(0)
		end,1)
	elseif #bonusCloums == 2 then
		self.main_layout:showRemind(2)
	end
end

-- function FirecrackerScene:playTestEffect(x,y)
-- 	local effect = self:createEffect(x,y)
-- 	effect:setVisible(true)
-- 	effect:playPrize()
-- 	self.game_layouts[x]:hideByIndex(y)
-- end

--播放特效
function FirecrackerScene:playEffect()
	local winDatas = self.content_data.windatas
	--优先级大奖
	if #self.content_data.bonus_cloums > 1 then
		self:playBonusEffect(self.content_data.bonus_cloums)
	end
	local soundName = nil
	for i=1,#winDatas do
		local result_data = winDatas[i]
		if result_data.number >= 5 then
			soundName = "firecracker_win3"
			self.main_layout:showRemind(1)
		end
		if soundName == nil and result_data.sid >= 7 and result_data.sid <= 11 then
			soundName = "firecracker_win5"
		end
	end
	soundName = soundName or "firecracker_win1"
	self.soundController:playOnlyOverSound(soundName)
	for i=1,#self.content_data.normal_win_array do
		local ps = self.content_data.normal_win_array[i]
		local effect = self:createEffect(ps[1],ps[2])
		self.game_layouts[ps[1]]:hideByIndex(ps[2])
		effect:playPrize()
	end
end

function FirecrackerScene:playFullEffect()
	for x=1,#self.content_data.resultdata do
		local cloum = self.content_data.resultdata[x]
		for y=1,#cloum do
			local effect = self:createEffect(x,y)
			self.game_layouts[x]:hideByIndex(y)
			effect:playPrize()
		end
	end
	self.main_layout:showRemind(3)
	self.soundController:playOnlyOverSound("firecracker_win5")
	if self.content_data.resultdata[1][1] == 13 then
		self.main_layout:enterFreeState(0)
	end
end

--根据索引获取特效元素
function FirecrackerScene:createEffect(column,line)
	local effect = self.effectList[column][line]
	if not effect then
		local column_layout = self.game_layouts[column]
		-- local x = column_layout:getPositionX() + ELEMENT_WIDTH/2
		-- local y = column_layout:getPositionY() + ELEMENT_HEIGHT*(line-1) + ELEMENT_HEIGHT/2
		local x = column_layout:getPositionX()
		local y = column_layout:getPositionY() + ELEMENT_HEIGHT*(line-1)
		local etype = column_layout:getTypeByIndex(line)
		local data = require("src.games.firecracker.data.Firecracker_element_data").new(etype)
		effect = require("src.games.firecracker.ui.GameEffect").new(data)
		self.content_layout:addChild(effect,3)
		effect:setPosition(cc.p(x,y))
		self.effectList[column][line] = effect
	end
	return effect
end

--本回合结束
function FirecrackerScene:stopGame()
	self.isAtOnceStop = true
	for i=1,#self.game_layouts do
		self.game_layouts[i]:stopAtOnceStop()
	end
end

--移除特效控件
function FirecrackerScene:removeEffect()
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

--自动开始
function FirecrackerScene:autoPlayGame(delay)
	local auto_action = self:performWithDelay(function()
		if self.autoCount > 0 then
			-- self.autoCount = self.autoCount - 1
			self.autoCount = 999
			self.main_layout:updateAutoCount(self.autoCount)
			self:playGame()
		else
			self:playGame()
		end
	end,delay)
	self.controller:addActionHandler(auto_action)
end

--清场
function FirecrackerScene:desktopClean()
	for i=1,#self.controller.action_array do
		self:stopAction(self.controller.action_array[i])
	end
	for i=1,#self.game_layouts do
		self.game_layouts[i]:showAll()
	end
	self.playgame_action = nil
	self.main_layout:winMoneyStop()
	self.controller:cleanActionHandler()
	SoundsManager.stopAllSounds()
	self:removeEffect()
end

--开始旋转 specialIndex:特殊旋转标识
function FirecrackerScene:playGame()
	if self.playgame_action then return end
	-- SoundsManager:stopAudio("bdr_addScoring")
	ConnectMgr.connect("src.games.firecracker.content.FirecrackerPlayConnect",self.controller:getBetMoney(),function(result)
		if result ~= false then
			self.soundController:roundOver()
			if self.autoCount > 0 then
				self.main_layout:updateAutoCount(self.autoCount)
			else
				self.main_layout:setStartBtnState(3)
			end
			self:desktopClean()
			self.isAtOnceStop = false
			self.runState = true
			self.column_count = 0
			self.content_data = result
			self.controller:setFreeCount(self.content_data.freeNum)
			self.main_layout:updateBeginState()
			self:runTurn()
		end
	end)
end

function FirecrackerScene:gameOver()
	local delay = 0.5
	local sequence_array = {}
	table.insert(sequence_array,cc.DelayTime:create(0.2))
	if self.content_data.isFull then
		table.insert(sequence_array,cc.CallFunc:create(function()
			self:playFullEffect()
		end))
		table.insert(sequence_array,cc.DelayTime:create(1))
		delay = 3
	else
		if #self.content_data.windatas > 0 then
			table.insert(sequence_array,cc.CallFunc:create(function()
				self:playEffect()
			end))
			table.insert(sequence_array,cc.DelayTime:create(1))
			delay = 3
		end
	end
	local callback = cc.CallFunc:create(function()
		self.main_layout:updateOverState(self.content_data.winMoney,self.content_data.totalFreeWinMoney,delay)
		self.runState = false
		local isAuto = false
		if self.autoCount > 0 then
			isAuto = true
		elseif self.controller.freeCount > 0 and self.main_layout.isFreeBegin then
			isAuto = true
		end
		if isAuto then
			self:autoPlayGame(delay)
		else
			self.main_layout:gameOver()
		end
	end)
	-- table.insert(sequence_array,cc.DelayTime:create(0.2))
	table.insert(sequence_array,callback)
	local quene_action = self:runAction(cc.Sequence:create(sequence_array))
end

function FirecrackerScene:onCleanup()
	SoundsManager.stopAllMusic()
	SoundsManager.stopAllSounds()
	self:removeAllEvent()
	require("src.games.firecracker.data.FirecrackerSoundController").getInstance():roundOver()
	require("src.games.firecracker.data.FirecrackerController").getInstance():init()
	if not self.noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
end

return FirecrackerScene