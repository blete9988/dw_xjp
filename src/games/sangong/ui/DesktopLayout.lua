--[[
*	桌面  层
*	@author：lqh
]]
local DesktopLayout = class("DesktopLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
end)

--座位坐标配置
local posconfig = {
	--头像坐标，扑克组坐标，准备图标坐标，加倍数图标
	{cc.p(520,205)	,cc.p(780,205),cc.p(645,285),cc.p(520,325),},
	{cc.p(1205,415)	,cc.p(1030,430),cc.p(1080,415),cc.p(1080,345),},
	{cc.p(1035,595)	,cc.p(860,610),cc.p(910,525),cc.p(910,525),},
	{cc.p(330,595)	,cc.p(505,610),cc.p(455,525),cc.p(455,525),},
	{cc.p(160,415)	,cc.p(335,430),cc.p(290,415),cc.p(290,345),},
}
	
function DesktopLayout:ctor()
	self:super("ctor")
	
	local item
	local playerItems = {}
	local pokerGroups = {}
	for i = 1,5 do
		item = require("src.games.sangong.ui.PokerGroupItem").new()
		if i > 1 then
			item:setNotself()
		end
		item:setPosition(posconfig[i][2])
		self:addChild(item)
		pokerGroups[i] = item
		--第一个为玩家自己
		item = require("src.games.sangong.ui.Sangong_PlayerItem").new(i)
		item:setPosition(posconfig[i][1])
		item:setReadyPicPos(item:convertToNodeSpace(posconfig[i][3]))
		item:setTimesPicPos(item:convertToNodeSpace(posconfig[i][4]))
		self:addChild(item)
		playerItems[i] = item
	end
	
	self.m_playerItems = playerItems
	self.m_pokerGroups = pokerGroups
end
function DesktopLayout:init()
	local gameMgr = require("src.games.sangong.data.Sangong_GameMgr").getInstance()
	self:initPlayers()
	if gameMgr.gamestatus == ST.TYPE_GAMESANGONG_PLAYING then
		if gameMgr.playStatus == ST.TYPE_GAMESANGONG_PLAYSTATUS_MASTER then
			--正在抢庄
			self:showTimesOperateBtn(true)
		elseif  gameMgr.playStatus == ST.TYPE_GAMESANGONG_PLAYSTATUS_ADDTIMES then
			--正在加倍
			self:showTimesOperateBtn()
		end
	end
end
--初始化玩家
function DesktopLayout:initPlayers()
	local gameMgr = require("src.games.sangong.data.Sangong_GameMgr").getInstance()
	local players = gameMgr:getPlayers()
	
	--先找出玩家自己的位置
	local index
	for i = 1,#players do
		if players[i]:isSelf() then
			index = players[i].index
			break
		end
	end
	if not index then mlog(DEBUG_E,"<DesktopLayout>:没有玩家自己的座位号") end
	self.m_firstIndex = nil
	local startIndex
	
	local playerItem,pokerGroupItem
	for i = 1,#self.m_playerItems do
		playerItem = self.m_playerItems[i]
		pokerGroupItem = self.m_pokerGroups[i]
		--清除桌面
		pokerGroupItem:clear()
		--先置空
		playerItem:setPlayerInfo()
		
		for k,v in pairs(players) do
			if v.index == index then
				--查找对应座位的玩家，并设置
				playerItem:setPlayerInfo(v)
				playerItem:showMasterIcon(true)
				mlog(string.format("<DesktopLayout>:座位号 %s，玩家id %s，玩家名字 %s",index,v.id,v.name))
				if gameMgr:isPlaying() then
					if v:isShowdown() then
						pokerGroupItem:initPoker(v.pokerGroup)
					else
						pokerGroupItem:initPoker()
						playerItem:beganCountdown(gameMgr.openStamp - ServerTimer.time)
					end
				end
				if not startIndex or index < startIndex then
					startIndex = index
					self.m_firstIndex = i
					mlog(string.format("<DesktopLayout>:发牌第一个玩家座位号 %s，名字 %s，前端显示位置 %s",index,v.name,i))
				end
				break
			end
		end
		index = (index + 1)%ST.TYPE_GAMESANGONG_MAX_PLAYERS
	end
end

--开始发牌
function DesktopLayout:beganDeal()
	self:removeTimesLayout()
	--重置扑克
	self:resetPoker()
	--更新玩家准备状态
	self:updatePlayersReadyStatus()
	
	local gameMgr = require("src.games.sangong.data.Sangong_GameMgr").getInstance()
	local countdown = gameMgr.openStamp - ServerTimer.time
	local pokergroup = gameMgr:getMineInfo().pokerGroup
	local index = 0
	self.m_pokerGroups[1]:setData(pokergroup)
	self:runAction(cc.Sequence:create({
		cc.Repeat:create(cc.Sequence:create({
			cc.CallFunc:create(function(t) 
				if not t then return end
				index = index + 1 
				self:m_sendCard(index)
			end),
			cc.DelayTime:create(1),
		}),5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			for i = 1,#self.m_playerItems do
				self.m_playerItems[i]:beganCountdown(countdown)
			end
			CommandCenter:sendEvent(ST.COOMAND_GAMESANGONG_SEND_OVER)
		end),
	}))
end

--[[
*	发牌
*	@param pokerIndex 第几张牌
]]
function DesktopLayout:m_sendCard(pokerIndex)
	local index = require("src.games.sangong.data.Sangong_GameMgr").getInstance():getMaster().clientIndex
	local len = 0
	local flycard
	for i = 1,ST.TYPE_GAMESANGONG_MAX_PLAYERS do
		if self.m_playerItems[index].playerInfo then
			--有玩家执行发牌
			local target = self.m_pokerGroups[index]
			
			flycard = display.newSprite("card_back.png")
			flycard:setScale(0.3)
			flycard:setOpacity(0)
			self:addChild(Coord.ingap(self,flycard,"CC",0,"CC",0))
			flycard:runAction(cc.Sequence:create({
				cc.DelayTime:create(0.15*len),
				cc.CallFunc:create(function(t) 
					if not t then return end
					SoundsManager.playSound("qznn_send_card")
				end),
				cc.Spawn:create({
					cc.MoveTo:create(0.2,target:getPokerWorldPos(pokerIndex)),
					cc.FadeIn:create(0.2),
					cc.ScaleTo:create(0.2,target:getScale()),
					cc.Repeat:create(cc.Sequence:create({
						cc.RotateTo:create(0.05,180),
						cc.RotateTo:create(0.05,360)
					}),2)
				}),
				cc.CallFunc:create(function(t) 
					if not t then return end
					t:removeFromParent(true)
					
					target:addPoker()
				end)
			}))
			len = len + 1
		end
		index = (index%ST.TYPE_GAMESANGONG_MAX_PLAYERS) + 1
	end
end
--移除加倍操作弹层
function DesktopLayout:removeTimesLayout()
	if not self.m_timeslayout then return end
	self.m_timeslayout:removeFromParent()
	self.m_timeslayout = nil
end
--[[
*	显示加倍操作按钮
*	@param ismaster 是否是抢庄
]]
function DesktopLayout:showTimesOperateBtn(ismaster)
	self:removeTimesLayout()
	
	local layout = display.newLayout(cc.size(680,90))
	display.extend("CCNodeExtend",layout)
	self:addChild(Coord.ingap(self,layout,"CC",0,"CB",-30))
	self.m_timeslayout = layout
	
	--倍率配置
	local config
	local mineInfo = require("src.games.sangong.data.Sangong_GameMgr").getInstance():getMineInfo()
	local selfIsMaster = false
	if ismaster then
		config = {0,1,2,4}
	else
		selfIsMaster = mineInfo.masterTimesValue > 0
		config = {5,10,15,20}
	end
	
	--倒计时显示
	local cdbg = display.newImage("qznn_panel_1002.png")
	if ismaster then
		cdbg:addChild(Coord.ingap(cdbg,display.newText(display.trans("##7010"),26),"LL",30,"CC",0))
		display.setS9(cdbg,cc.rect(20,15,120,10),cc.size(180,42))
		layout:addChild(Coord.ingap(layout,cdbg,"CC",0,"TB",30))
	else
		if selfIsMaster then
			cdbg:addChild(Coord.ingap(cdbg,display.newText(display.trans("##7016"),26),"LL",30,"CC",0))
			display.setS9(cdbg,cc.rect(20,15,120,10),cc.size(320,42))
			layout:addChild(Coord.ingap(layout,cdbg,"CC",0,"CC",15))
		else
			cdbg:addChild(Coord.ingap(cdbg,display.newText(display.trans("##7011"),26),"LL",30,"CC",0))
			display.setS9(cdbg,cc.rect(20,15,120,10),cc.size(180,42))
			layout:addChild(Coord.ingap(layout,cdbg,"CC",0,"TB",30))
		end
	end
	
	local targetTimeStamp = require("src.games.sangong.data.Sangong_GameMgr").getInstance().cdStamp
	local cdTxt = display.newText(targetTimeStamp - ServerTimer.time,26)
	cdbg:addChild(Coord.ingap(cdbg,cdTxt,"RR",-30,"CC",0))
	layout:onTimer(function(t) 
		if not t then return end
		local cd = targetTimeStamp - ServerTimer.time
		cdTxt:setString(cd)
		if cd < 0 then
			self:removeTimesLayout()
		end
	end,0.2)
	
	if ismaster then
		if mineInfo.masterTimesValue > 0 then
			--已经抢过庄，不能再次进行抢庄
			return
		end
	else
		if selfIsMaster or mineInfo.addTimesValue > 0 then
			--已经是庄家或者已经加倍，不能再次进行加倍
			return
		end
	end
	
	local btnLayout = display.newLayout(cc.size(680,90))
	layout:addChild(Coord.ingap(layout,btnLayout,"CC",0,"CC",0))
	
	local function btncallback(t,e)
		if e ~= ccui.TouchEventType.ended then return end
		local path
		if ismaster then
			path = "src.games.sangong.connect.Sangong_GetMasterConnect"
		else
			path = "src.games.sangong.connect.Sangong_AddTimesConnect"
		end
		ConnectMgr.connect(path , t.timesValue,function(result) 
			if result ~= 0 then return end
			btnLayout:removeFromParent()
		end)
	end
	local btn,temp
	for i = 1,#config do
		if config[i] == 0 then
			btn = display.newButton("qznn_ui_1009.png","qznn_ui_1009.png")
		else
			btn = display.newButton("qznn_ui_1010.png","qznn_ui_1010.png")
		end
		btn:addTouchEventListener(btncallback)
		if i == 1 then
			btnLayout:addChild(Coord.ingap(btnLayout,btn,"LL",10,"CC",0))
		else
			btnLayout:addChild(Coord.outgap(temp,btn,"RL",25,"CC",0))
		end
		
		btn:setPressedActionEnabled(true)
		btn.timesValue = config[i]
		btn:addChild(Coord.ingap(btn, display.newImage(string.format("qznn_btn_times_%s.png",config[i])),"CC",0,"CC",3))
		temp = btn
	end
end
--摊牌
function DesktopLayout:showdownPoker(playerInfo)
	local index = playerInfo.clientIndex
	self.m_playerItems[index]:beganCountdown(0)
	self.m_pokerGroups[index]:showdown(playerInfo.pokerGroup)
end
--添加玩家
function DesktopLayout:addPlayer(playerInfo)
	if not self.m_firstIndex then return end
	local index = (self.m_firstIndex + playerInfo.index - 1)%5 + 1
	self.m_playerItems[index]:setPlayerInfo(playerInfo)
end
--移除玩家
function DesktopLayout:removePlayer(playerInfo)
	local index = playerInfo.clientIndex
	self.m_playerItems[index]:setPlayerInfo()
end
--更新所有玩家的准备状态
function DesktopLayout:updatePlayersReadyStatus()
	for i = 1,#self.m_playerItems do
		self.m_playerItems[i]:updateReadyStatus()
	end
end
--更新所有玩家的加倍显示
function DesktopLayout:updatePlayersTimesStatus(showmaster)
	for i = 1,#self.m_playerItems do
		self.m_playerItems[i]:updateTimesStatus()
		if showmaster then
			self.m_playerItems[i]:showMasterIcon()
		end
	end
end
--重置桌面
function DesktopLayout:resetDesktop()
	require("src.games.sangong.data.Sangong_GameMgr").getInstance():resetPlayers()
	
	self:resetPoker()
	for i = 1,#self.m_playerItems do
		self.m_playerItems[i]:updateInfo()
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_RESULT_OVER)
end
--显示结果动画
function DesktopLayout:showResultEffect()
	local players = require("src.games.sangong.data.Sangong_GameMgr").getInstance():getPlayers()
	self:delayTimer(function() 
		for i = 1,#self.m_playerItems do
			self.m_playerItems[i]:updateGold()
			self.m_playerItems[i]:beganCountdown(0)
			self.m_playerItems[i]:showResult()
		end
		local masterItem
		for k,v in pairs(players) do
			if v.ismaster then
				table.remove(players,k)
				masterItem = self.m_playerItems[v.clientIndex]
				break
			end
		end
		for k,v in pairs(players) do
			if v.resultGold > 0 then
				if v.id == Player.id then
					SoundsManager.playSound("qznn_win")
				end
				self:playGoldChangeAnim(self.m_playerItems[v.clientIndex],masterItem)
			elseif v.resultGold < 0 then
				if v.id == Player.id then
					SoundsManager.playSound("qznn_fail")
				end
				self:playGoldChangeAnim(masterItem,self.m_playerItems[v.clientIndex])
			end
		end
		self:delayTimer(function() self:resetDesktop() end,3)
	end,1)
end

--播放金币变化动画
function DesktopLayout:playGoldChangeAnim(winner,loster)
	local wx,wy = winner:getPosition()
	local lx,ly = loster:getPosition()
	
	local count = math.random(14,20)
	local f = math.cos(math.pi*90/180)
	local duration = 0
	local startPos,endPos = cc.p(0,0),cc.p(0,0)
	local p1,p2 = cc.p(0,0),cc.p(0,0)
	local goldicon
	for i = 1,count do
		startPos.x = math.random(lx - 40,lx + 40)
		startPos.y = math.random(ly - 40,ly + 40)
		
		endPos.x = math.random(wx - 40,wx + 40) - startPos.x
		endPos.y = math.random(wy - 40,wy + 40) - startPos.y
		
		duration = math.sqrt(math.pow(endPos.x,2) + math.pow(endPos.y,2))/1200
		
		p1.x = endPos.x/4.0
		p1.y = f*p1.x
		
		p2.x = endPos.x/2.0
		p2.y = f*p2.x
		
		goldicon = display.newSprite("qznn_ui_1024.png")
		goldicon:setOpacity(0)
		goldicon:setPosition(startPos)
		goldicon:runAction(cc.Sequence:create({
			cc.DelayTime:create((i - 1)*0.06),
			cc.FadeIn:create(0.2),
			cc.BezierBy:create(duration,{p1,p2,endPos}),
			cc.Spawn:create({
				cc.ScaleTo:create(0.2,0.4),
				cc.FadeOut:create(0.2)
			}),
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function(t) 
				if not t then return end
				t:removeFromParent()
			end)
		}))
		self:addChild(goldicon)
	end
	SoundsManager.playSound("qznn_getgold")
end

function DesktopLayout:resetPoker()
	for i = 1,#self.m_pokerGroups do
		self.m_pokerGroups[i]:clear()
	end
end
function DesktopLayout:clear()
	self:stopAllActions()
	self:removeTimesLayout()
	self:resetPoker()
	for i = 1,#self.m_playerItems do
		self.m_playerItems[i]:setPlayerInfo()
	end
end

function DesktopLayout:onCleanup()
	self:stopAllActions()
end
return DesktopLayout