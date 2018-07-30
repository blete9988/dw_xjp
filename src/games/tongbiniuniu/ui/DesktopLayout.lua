--[[
*	桌面  层
*	@author：lqh
]]
local DesktopLayout = class("DesktopLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
end)

--座位坐标配置
local posconfig = {
	--头像坐标，扑克组坐标，准备图标坐标
	{cc.p(520,205)	,cc.p(780,205),cc.p(645,285),},
	{cc.p(1205,415)	,cc.p(1030,415),cc.p(1080,415)},
	{cc.p(1035,595)	,cc.p(860,610),cc.p(910,525)},
	{cc.p(330,595)	,cc.p(505,610),cc.p(455,525)},
	{cc.p(160,415)	,cc.p(335,415),cc.p(290,415)},
}
	
function DesktopLayout:ctor()
	self:super("ctor")
	self.index = 0
	
	local item
	local playerItems = {}
	local pokerGroups = {}
	for i = 1,5 do
		item = require("src.games.tongbiniuniu.ui.PokerGroupItem").new()
		if i > 1 then
			item:setNotself()
		end
		item:setPosition(posconfig[i][2])
		self:addChild(item)
		pokerGroups[i] = item
		--第一个为玩家自己
		item = require("src.games.tongbiniuniu.ui.Tbnn_PlayerItem").new(i)
		item:setPosition(posconfig[i][1])
		item:setReadyPicPos(item:convertToNodeSpace(posconfig[i][3]))
		self:addChild(item)
		playerItems[i] = item
		
	end
	
	self.m_playerItems = playerItems
	self.m_pokerGroups = pokerGroups
	
end
--初始化玩家
function DesktopLayout:initPlayers()
	local gameMgr = require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance()
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
		index = (index + 1)%ST.TYPE_GAMETBNN_MAX_PLAYERS
	end
end

--开始发牌
function DesktopLayout:beganDeal()
	--重置扑克
	self:resetPoker()
	--更新玩家准备状态
	self:updatePlayersReadyStatus()
	
	local gameMgr = require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance()
	local countdown = gameMgr.openStamp - ServerTimer.time
	
	local pokergroup = gameMgr:getMineInfo().pokerGroup
	--设置自己的手牌
	self.m_pokerGroups[1]:setData(pokergroup)
	self.index = 0
	self:runAction(cc.Sequence:create({
		cc.Repeat:create(cc.Sequence:create({
			cc.CallFunc:create(function(t) 
				if not t then return end
				self.index = self.index + 1 
				self:m_sendCard()
			end),
			cc.DelayTime:create(1),
		}),5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			for i = 1,#self.m_playerItems do
				self.m_playerItems[i]:beganCountdown(countdown)
			end
			CommandCenter:sendEvent(ST.COOMAND_GAMETBNN_SEND_OVER)
		end),
	}))
end

--发牌
function DesktopLayout:m_sendCard()
	local index = self.m_firstIndex
	local len = 0
	local flycard
	for i = 1,ST.TYPE_GAMETBNN_MAX_PLAYERS do
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
					SoundsManager.playSound("tbnn_send_card")
				end),
				cc.Spawn:create({
					cc.MoveTo:create(0.2,target:getPokerWorldPos(self.index)),
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
		index = (index%ST.TYPE_GAMETBNN_MAX_PLAYERS) + 1
	end
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
--摊牌
function DesktopLayout:showdownPoker(playerInfo)
	local index = playerInfo.clientIndex
	self.m_playerItems[index]:beganCountdown(0)
	self.m_pokerGroups[index]:showdown(playerInfo.pokerGroup)
end
--更新所有玩家的准备状态
function DesktopLayout:updatePlayersReadyStatus()
	for i = 1,#self.m_playerItems do
		self.m_playerItems[i]:updateReadyStatus()
	end
end
--延迟清理
function DesktopLayout:delayClear(callback)
	--更新玩家信息
	self:updateAllPlayers()
	
	self:delayTimer(function() 
		self:resetPoker()
		self:updatePlayersReadyStatus()
		if callback then callback() end
	end,3)
end
--更新玩家信息
function DesktopLayout:updateAllPlayers()
	for i = 1,#self.m_playerItems do
		self.m_playerItems[i]:updateInfo()
		self.m_playerItems[i]:beganCountdown(0)
	end
end
--显示胜利者动画
function DesktopLayout:showWinnerEffect()
	for i = 1,#self.m_playerItems do
		self.m_playerItems[i]:showWinnerEffect()
	end
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(2),
		cc.CallFunc:create(function(t) 
			if not t then return end
			CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_SHOWDOWN_OVER)
		end)
	}))
end
function DesktopLayout:resetPoker()
	for i = 1,#self.m_pokerGroups do
		self.m_pokerGroups[i]:clear()
	end
	self.index = 0
end
function DesktopLayout:clear()
	self:stopAllActions()
	self:resetPoker()
	for i = 1,#self.m_playerItems do
		self.m_playerItems[i]:setPlayerInfo()
	end
end

function DesktopLayout:onCleanup()
	self:stopAllActions()
end
return DesktopLayout