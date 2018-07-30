--[[
*	手牌组 item
*	@author：lqh
]]
local PokerGroupItem = class("PokerGroupItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(420,182))
end)

function PokerGroupItem:ctor()
	self:super("ctor")
	
	self:setAnchorPoint( cc.p(0.5,0.5) )
	self:setScale(0.55)
	
	self.m_pokerItems = {}
	
	local item,temp
	for i = 1,3 do
		item = require("src.games.hongheidazhan.ui.PokerItem").new()
		if temp then
			self:addChild(Coord.outgap(temp,item,"RL",20,"CC",0))
		else
			self:addChild(Coord.ingap(self,item,"LL",0,"CC",0))
		end
		temp = item
		self.m_pokerItems[i] = item
	end
	
	local typePic = display.newImage()
	typePic:setScale(2.3)
	self:addChild(Coord.ingap(self,typePic,"CC",0,"BC",20))
	self.m_typePic = typePic
end
--设置数据
function PokerGroupItem:setData(data)
	self.m_data = data
	local pokers = data:getPokers()
	
	for i = 1,#self.m_pokerItems do
		self.m_pokerItems[i]:setPoker(pokers[i])
	end
end
--获取扑克的世界坐标
function PokerGroupItem:getPokerPosInTarget(index,target)
	local p = target:convertToNodeSpace(self:convertToWorldSpace(cc.p(self.m_pokerItems[index]:getPosition())))
	return p
end
--显示一张牌
function PokerGroupItem:showPoker(index)
	self.m_pokerItems[index]:show()
end
--翻牌
function PokerGroupItem:turnPoker(callback)
	local index = 1
	self:runAction(cc.Sequence:create({
		cc.Repeat:create(cc.Sequence:create({
			cc.CallFunc:create(function(t) 
				if not t then return end
				self.m_pokerItems[index]:turnPoker(index == 3)
				index = index + 1
			end),
			cc.DelayTime:create(0.3),
		}),3),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:showGroupType()
		end),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			if callback then callback() end
		end)
	}))
end
--显示牌型
function PokerGroupItem:showGroupType()
	self.m_typePic:setOpacity(0)
	self.m_typePic:loadTexture(self.m_data:getTypePic(),1)
	self.m_typePic:runAction(cc.FadeIn:create(0.5))
	
	SoundsManager.playSound(self.m_data:getTypeSound())
end
function PokerGroupItem:showWinAnim()
	local anim = display.newParticle("game/hongheidazhan/particle/star01.plist")
	anim:setPosition(cc.p(210,40))
	anim:setScale(1.4)
	self:addChild(anim)
	anim:runAction(cc.Sequence:create({
		cc.DelayTime:create(1.5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			t:removeFromParent()
		end)
	}))
end
function PokerGroupItem:clear()
	self:stopAllActions()
	self.m_typePic:stopAllActions()
	self.m_typePic:setOpacity(0)
	for i = 1,#self.m_pokerItems do
		self.m_pokerItems[i]:clear()
	end
end

return PokerGroupItem