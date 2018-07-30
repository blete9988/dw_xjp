--[[
*	手牌类型 特效
*	@author：lqh
]]
local CardTypeEffect = class("CardTypeEffect",function() 
	return display.newLayout(cc.size(232,232))
end)

function CardTypeEffect:ctor(type)
	self:setAnchorPoint( cc.p(0.5,0.5) )
	--炫光背景
	local dazzleLight = display.newSprite("bjl_ui_1015.png")
	dazzleLight:setScale(1.6)
	self:addChild(Coord.ingap(self,dazzleLight,"CC",0,"CC",0))
	self.m_dazzleLight = dazzleLight
	
	local iconimge
	if type == 0 then
		--对子
		iconimge = display.newSprite("bjl_ui_1033.png")
	else
		--天王
		iconimge = display.newSprite("bjl_ui_1034.png")
	end
	iconimge:setScale(1.2)
	self:addChild(Coord.ingap(self,iconimge,"CC",0,"CC",0))
	self.m_iconimge = iconimge
	self:setVisible(false)
end
function CardTypeEffect:setShow(bool)
	--不显示
	if not bool then return end
	--已经显示不再显示
	if self:isVisible() then return end
	
	self.m_iconimge:setOpacity(0)
	self:setVisible(true)
	self.m_dazzleLight:runAction(cc.RepeatForever:create(
		cc.Sequence:create({
			cc.RotateTo:create(1,180),
			cc.RotateTo:create(1,360),
		})
	))
	self:setScale(0.5)
	self.m_iconimge:runAction(cc.FadeIn:create(0.3))
	self:runAction(cc.Sequence:create({
		cc.ScaleTo:create(0.1,1.6),
		cc.ScaleTo:create(0.1,1),
	}))
end
function CardTypeEffect:hide()
	self:setVisible(false)
	self:stopAllActions()
	self.m_dazzleLight:stopAllActions()
	self.m_iconimge:stopAllActions()
end
return CardTypeEffect