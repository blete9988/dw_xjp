--[[
*	扑克
*	@author：lqh
]]
local PokerItem = class("PokerItem",require("src.base.extend.CCLayerExtend"),function() 
	local layout = display.newLayout(cc.size(144,176))
	layout:setAnchorPoint( cc.p(0.5,0.5) )
	return layout
end)

function PokerItem:ctor()
	self:super("ctor")
--	local cardPic = display.newSprite("card_large_38.png")
	local cardPic = display.newSprite()
	self:addChild(Coord.ingap(self,cardPic,"CC",0,"CC",0))
	self.m_cardPic = cardPic
end

--设置牌数据
function PokerItem:setPoker(pokerdata)
	self.m_data = pokerdata 
end
--显示牌
function PokerItem:show(showface)
	self.m_cardPic:setSpriteFrame("card_back.png")
	if showface then
		self:m_turnPoker()
	end
end
--显示牌正面
function PokerItem:showFace(pokerdata)
	self:setPoker(pokerdata)
	self.m_cardPic:setSpriteFrame(pokerdata.pic)
end

--翻牌
function PokerItem:m_turnPoker()
	self.m_cardPic:runAction(cc.Sequence:create({
		cc.OrbitCamera:create(0.2,1,0,0,90,0,0),
		cc.CallFunc:create(function(target) 
			if not target then return end
			--设置牌正面
			self.m_cardPic:setSpriteFrame(self.m_data.pic)
--			target:setSpriteFrame("card_large_38.png")
		end),
		cc.OrbitCamera:create(0.2,1,0,270,90,0,0),
		cc.CallFunc:create(function(target) 
			if self.m_callback then
				local callback = self.m_callback
				self.m_callback = nil
				callback()
			end
		end),
	}))
end

--清除
function PokerItem:clear()
	self.m_cardPic:setTexture("")
	self.m_cardPic:stopAllActions()
	self.m_cardPic:setRotation(0)
	
	self.m_callback = nil
	self.m_data = nil
end
function PokerItem:onCleanup()
	self:clear()
end
return PokerItem