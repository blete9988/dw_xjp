--[[
*	扑克 层
*	@author：lqh
]]
local PokerLayout = class("PokerLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
end)

function PokerLayout:ctor()
	self:super("ctor")
	--牌盒子
	local pokerBox = display.newImage("ui_brnn_1059.png")
	self:addChild(Coord.ingap(self,pokerBox,"RR",-200,"TT",-90))
	local temp = display.newImage("ui_brnn_1060.png")
	temp:setLocalZOrder(1)
	pokerBox:addChild(Coord.ingap(pokerBox,temp,"CC",-37,"CC",-5))
	self.m_pokerBox = pokerBox
	
	self.groups = {}
	local item,temp
	for i = 1,4 do
		item = require("src.games.bairenniuniu.ui.PokerGroupItem").new()
		if not temp then
			self:addChild(Coord.ingap(self,item,"CR",-265,"CT",-65))
		else
			self:addChild(Coord.outgap(temp,item,"RL",46,"CC",0))
		end
		self.groups[i] = item
		temp = item
	end
	
	item = require("src.games.bairenniuniu.ui.PokerGroupItem").new()
	self:addChild(Coord.ingap(self,item,"CC",70,"TT",-5))
	table.insert(self.groups,item)
	self.index = 0
end

--开始发牌
function PokerLayout:beganDeal()
	local datas = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().resultMgr:getGroups()
	for i = 1,#datas do
		self.groups[i]:setData(datas[i])
	end
	self:runAction(cc.Sequence:create({
		cc.Repeat:create(cc.Sequence:create({
			cc.CallFunc:create(function(t) 
				if not t then return end
				self:m_sendCard()
			end),
			cc.DelayTime:create(1),
		}),5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:m_seeLastPoker()
		end),
	}))
end

--发牌
function PokerLayout:m_sendCard()
	self.index = self.index + 1
	if self.index > 5 then return end
	local flycard
	for i = 1,5 do
		local target = self.groups[i]
		flycard = display.newSprite("ui_brnn_1061.png")
		self.m_pokerBox:addChild(Coord.ingap(self.m_pokerBox,flycard,"CC",-37,"CC",-11))
		flycard:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.15*(i - 1)),
			cc.CallFunc:create(function(t) 
				if not t then return end
				SoundsManager.playSound("brnn_send_card")
			end),
			cc.MoveTo:create(0.1,cc.p(-15,-30)),
			cc.CallFunc:create(function(t) 
				if not t then return end
				t:removeFromParent(true)
				self:m_playFlyEffect(target)
			end)
		}))
	end
end
--播放飞牌动画
function PokerLayout:m_playFlyEffect(target)
	local targetpos = cc.p(target:getPokerWorldPos(self.index))
	
	local distance = math.sqrt(math.pow(targetpos.x - 1015,2) + math.pow(targetpos.y - 543,2))
	
	local tm = distance/2500
	local tempcard = display.newSprite("card_back.png")
	tempcard:setScale(0.3)
	tempcard:setOpacity(100)
	tempcard:setPosition( cc.p(1015,543) )
	tempcard:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.MoveTo:create(tm,targetpos),
			cc.FadeTo:create(tm,230),
			cc.ScaleTo:create(tm,0.8),
			cc.Repeat:create(cc.Sequence:create({
				cc.RotateTo:create(tm/8,180),
				cc.RotateTo:create(tm/8,360)
			}),4)
		}),
		cc.CallFunc:create(function(t) 
			if not t then return end
			t:removeFromParent(true)
			
			target:showPoker()
		end)
	}))
	self:addChild(tempcard)
end
--看最后一张牌
function PokerLayout:m_seeLastPoker(index)
	index = index or 1
	self.groups[index]:seeLastPoker(function() 
		if index < 5 then
			self:m_seeLastPoker(index + 1)
		else
			self:m_showGroupResult()
		end
	end)
end
--显示每组牌的结果
function PokerLayout:m_showGroupResult()
	local index = 0
	self:runAction(cc.Sequence:create({
		cc.Repeat:create(cc.Sequence:create({
			cc.CallFunc:create(function(t) 
				if not t then return end
				index = index + 1
				self.groups[index]:showGroupType()
			end),
			cc.DelayTime:create(0.5),
		}),5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			CommandCenter:sendEvent(ST.COMMAND_GAMEBRNN_POKER_OVER)
		end),
	}))
end

function PokerLayout:clear()
	if self.index == 0 then return end
	self.index = 0
	self:stopAllActions()
	for i = 1,#self.groups do
		self.groups[i]:clear()
	end
end

function PokerLayout:onCleanup()
	self:stopAllActions()
end
return PokerLayout