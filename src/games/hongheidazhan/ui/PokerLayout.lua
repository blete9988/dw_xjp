--[[
*	扑克 层
*	@author：lqh
]]
local PokerLayout = class("PokerLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(D_SIZE.w,150))
end)

function PokerLayout:ctor()
	self:super("ctor")
	
	local blackGroup = require("src.games.hongheidazhan.ui.PokerGroupItem").new()
	self:addChild(Coord.ingap(self,blackGroup,"CR",-50,"CC",15,true))
	
	local redGroup = require("src.games.hongheidazhan.ui.PokerGroupItem").new()
	self:addChild(Coord.ingap(self,redGroup,"CL",50,"CC",15,true))
	
	self.groups = {blackGroup,redGroup}
	
end

--开始发牌
function PokerLayout:beganDeal()
	local cp = cc.p(D_SIZE.hw,90)
	local indexsq = {1,3,2,2,3,1}
	local groupIndex = 0
	for i = 1,6 do
		local card = display.newSprite("poker_bg_back.png")
		card:setScale(0.55)
		card:setPosition( cp )
		card.index = indexsq[i]
		card.groupIndex = groupIndex%2 + 1
		self:addChild(card)
		
		groupIndex = groupIndex + 1
		
		local p = self.groups[card.groupIndex]:getPokerPosInTarget(indexsq[i],self)
		card:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.25*i),
			cc.CallFunc:create(function(t) 
				if not t then return end
				SoundsManager.playSound("hhdz_sendpoker")
			end),
			cc.MoveTo:create(0.4 - 0.12*(math.floor((i - 1)/2)),p),
			cc.CallFunc:create(function(t) 
				if not t then return end
				self.groups[t.groupIndex]:showPoker(t.index)
				t:removeFromParent()
			end),
		}))
	end
end
--初始化显示牌
function PokerLayout:initShowPoker()
	for i = 1,#self.groups do
		for index = 1,3 do
			self.groups[i]:showPoker(index)
		end
	end
end

--翻开所有牌
function PokerLayout:turnPoker()
	local groupsData = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().resultMgr:getGroups()
	for i = 1,#groupsData do
		self.groups[i]:setData(groupsData[i])
	end
	self.groups[1]:turnPoker(function() 
		self.groups[2]:turnPoker(function() 
			local result = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().resultMgr:getCuurentResult()
			if result.blackWin and result.groupType > 4 then
				self.groups[1]:showWinAnim()
			elseif result.groupType > 4 then
				self.groups[2]:showWinAnim()
			end
			CommandCenter:sendEvent(ST.COOMAND_GAMEHHDZ_OPEN_POKER_OVER)
		end)
	end)
end

function PokerLayout:clear()
	self:stopAllActions()
	for i = 1,#self.groups do
		self.groups[i]:clear()
	end
end

function PokerLayout:onCleanup()
	self:stopAllActions()
end
return PokerLayout