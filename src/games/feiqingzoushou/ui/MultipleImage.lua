--[[
 *	飞禽走兽控件
 *	@author gwj
]]
local MultipleImage = class("MultipleImage",function() return display.newImage("fqzs-fly-main-gold-box.png") end)
function MultipleImage:ctor(id,size,position)
	display.setS9(self,cc.rect(10,10,23,16),size)
	local bet_img = display.newImage("fqzs-fly-center-icon-"..id..".png")
	bet_img:setAnchorPoint(cc.p(0,0))
	bet_img:setPosition(position)
	self:addChild(bet_img)
	self.bet_img = bet_img

	self.rect = display.newImage("fqzs-fly-main-button-lottery-select.png")
	display.setS9(self.rect,cc.rect(20,20,60,60),bet_img:getContentSize())
	self.rect:setAnchorPoint(cc.p(0,0))
	self.rect:setPosition(position)
	self.rect:setVisible(false)
	self:addChild(self.rect)
end

function MultipleImage:blink()
	self.rect:setVisible(true)
	self.rect:runAction(cc.RepeatForever:create(
		cc.Sequence:create({
			cc.FadeTo:create(1,50),
			cc.FadeIn:create(1)
		})))
end

function MultipleImage:getBetImage()
	return self.bet_img
end

function MultipleImage:disappear()
	self.rect:stopAllActions()
	self.rect:setVisible(false)
	self.rect:setOpacity(255)
end

return MultipleImage
