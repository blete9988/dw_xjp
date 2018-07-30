--[[
 *	豪车飘逸倍数控件
 *	@author gwj
]]
local MultipleControl = class("MultipleControl",function() return display.newLayout() end)
local model = require("src.games.haochepiaoyi.data.HaoChePiaoYi_multiple_data")
function MultipleControl:ctor(id)
	local data = model.new(id)
	self.data = data
	local rect = display.newImage(data.rectIcon)
	-- rect:setVisible(false)
	-- rect:setAnchorPoint(cc.p(0,0))
	self:addChild(rect)
	local rect_size = rect:getContentSize()
	self:setContentSize(rect_size)
	self.rect = rect
	if data.FlipX then
		rect:setFlippedX(true)
	end
	if data.FlipY then
		rect:setFlippedY(true)
	end
	rect:setPosition(cc.p(rect_size.width/2,rect_size.height/2))
	rect:setOpacity(0)

	local multiple_image = display.newImage(data.multipleIcon)
	multiple_image:setPosition(data.multipleIconPs)
	self:addChild(multiple_image)
	local sign_image = display.newImage(data.icon)
	sign_image:setPosition(data.iconPs)
	self:addChild(sign_image)
	self.sign_image = sign_image
end

function MultipleControl:getSid()
	return self.data.sid
end

function MultipleControl:getSignPosition()
	return self.data.iconPs
end

function MultipleControl:blink()
	if self.blink_action then return end
	self.blink_action = self.rect:runAction(cc.Sequence:create({
			cc.FadeIn:create(0.2),
			cc.FadeTo:create(0.2,0),
			cc.CallFunc:create(function()
				self.blink_action = nil
			end)
		}))
end

return MultipleControl
