--[[
 *	金沙银沙倍数控件
 *	@author gwj
]]
local MultipleImage = class("MultipleImage",function() return display.newImage() end)
function MultipleImage:ctor(sid)
	self.sid = sid
	self:loadTexture("jsys_multiple_"..sid..".png",1)
	local total_value_label = ccui.TextAtlas:create("","game/jinshayinsha/jsys_number_2.png",11,20,0)
	self:addChild(total_value_label)
	total_value_label:setPosition(cc.p(58,122))
	self.total_value_label = total_value_label
	local self_value_label = ccui.TextAtlas:create("","game/jinshayinsha/jsys_number_7.png",11,20,0)
	self:addChild(self_value_label)
	self_value_label:setPosition(cc.p(58,13))
	self.self_value_label = self_value_label
	local multiple_value_label = ccui.TextAtlas:create("","game/jinshayinsha/jsys_number_1.png",23,30,0)
	self:addChild(multiple_value_label)
	multiple_value_label:setAnchorPoint(cc.p(0,0.5))
	multiple_value_label:setPosition(cc.p(11,43))
	self.multiple_value_label = multiple_value_label

	-- self.rect = display.newImage("jsys_panel_6.png")
	-- display.setS9(self.rect,cc.rect(20,20,60,60),self:getContentSize())
	-- self.rect:setAnchorPoint(cc.p(0,0))
	-- -- self.rect:setPosition(position)
	-- self.rect:setVisible(false)
	-- self:addChild(self.rect)
end

-- function MultipleImage:blink()
-- 	self.rect:setVisible(true)
-- 	self.rect:runAction(cc.RepeatForever:create(
-- 		cc.Sequence:create({
-- 			cc.FadeTo:create(1,50),
-- 			cc.FadeIn:create(1)
-- 		})))
-- end

function MultipleImage:setTotalValue(value)
	local oldvalue = tonum(self.total_value_label:getString())
	if oldvalue > value or value == 0 then return end
	self.total_value_label:setString(value)
end
function MultipleImage:setSelfValue(value)
	local oldvalue = tonum(self.self_value_label:getString())
	if oldvalue > value or value == 0 then return end
	self.self_value_label:setString(value)
end

function MultipleImage:setMultipleValue(value)
	self.multiple_value_label:setString(value)
end

function MultipleImage:getMultipleValue()
	return self.multiple_value_label:getString()
end

function MultipleImage:cleanValue()
	self.self_value_label:setString("")
	self.total_value_label:setString("")
	self.multiple_value_label:setString("")
end

function MultipleImage:addSelfValue(value)
	local oldvalue = tonum(self.self_value_label:getString())
	self.self_value_label:setString(oldvalue + value)
end

function MultipleImage:addTotalValue(value)
	local oldvalue = tonum(self.total_value_label:getString())
	self.total_value_label:setString(oldvalue + value)
end

function MultipleImage:getSid()
	return self.sid
end

-- function MultipleImage:disappear()
-- 	self.rect:stopAllActions()
-- 	self.rect:setVisible(false)
-- 	self.rect:setOpacity(255)
-- end

return MultipleImage
