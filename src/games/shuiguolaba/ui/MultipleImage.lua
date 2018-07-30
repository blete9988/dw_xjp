--[[
 *	水果拉霸倍数控件
 *	@author gwj
]]
local MultipleImage = class("MultipleImage",function() return display.newImage() end)
function MultipleImage:ctor(sid)
	self.sid = sid
	self:loadTexture("sglb_bet_"..sid..".png",1)
	local total_value_label = ccui.TextAtlas:create(0,"game/shuiguolaba/sglb_number_3.png",14,21,0)
	self:addChild(total_value_label)
	total_value_label:setPosition(cc.p(81,103))
	self.total_value_label = total_value_label

	local rect = display.newSprite()
	rect:setScaleX(1.5)
	rect:setScaleY(1.35)
	Coord.ingap(self,rect,"CC",0,"CC",0)
	self:addChild(rect)
	self.rect = rect
	self.rect:setVisible(false)
end

function MultipleImage:setTotalValue(value)
	self.total_value_label:setString(value)
end

function MultipleImage:addTotalValue(value)
	local oldvalue = tonum(self.total_value_label:getString())
	self.total_value_label:setString(oldvalue + value)
end

function MultipleImage:getSid()
	return self.sid
end

function MultipleImage:playEffect()
	self.rect:setVisible(true)
	self.rect:runAction(resource.getAnimateByKey("sglb_action_bet",true))
end

function MultipleImage:removeEffect()
	self.rect:setVisible(false)
	self.rect:stopAllActions()
end

return MultipleImage
