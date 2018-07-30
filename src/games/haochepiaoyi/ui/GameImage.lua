--[[
 *	好车飘逸控件
 *	@author gwj
]]
local GameImage = class("GameImage",function() return display.newImage() end)
function GameImage:ctor(sid)
	self.sid = sid
	local rect = nil
	local data_image = display.newImage("fcpy_car_"..sid..".png")
	if sid > 4 then
		self:loadTexture("fcpy_icon_19.png",1)
		rect = display.newImage("fcpy_icon_20.png")
	else
		self:loadTexture("fcpy_icon_37.png",1)
		rect = display.newImage("fcpy_icon_38.png")
	end
	self.size=self:getContentSize()
	rect:setPosition(cc.p(self.size.width/2,self.size.height/2))
	rect:setVisible(false)
	self:addChild(rect,1)
	self:addChild(data_image,2)
	self.rect = rect
	data_image:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self.data_image = data_image
end

function GameImage:showEffect()
	local effect_1 = display.newImage("fcpy_icon_36.png")
	effect_1:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self:addChild(effect_1,0)

	local effect_2 = display.newImage("fcpy_icon_35.png")
	effect_2:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self:addChild(effect_2,2)

	local effect_List = {effect_1,effect_2}
	for i=1,2 do
		effect_List[i]:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,35)))
		effect_List[i]:runAction(cc.ScaleTo:create(1,2))
		effect_List[i]:runAction(cc.Sequence:create({
			cc.FadeTo:create(1,0),
			cc.CallFunc:create(function(sender)
				sender:removeFromParent(true)
			end)
		}))
	end
end

function GameImage:blink()
	self.rect:setVisible(true)
end

function GameImage:disappear()
	self.rect:setVisible(false)
end

function GameImage:setRectOpacity(value)
	self:setOpacity(value)
end

function GameImage:getSid()
	return self.sid
end

return GameImage
