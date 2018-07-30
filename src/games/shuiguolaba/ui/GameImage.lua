--[[
 *	旋转控件
 *	@author gwj
]]
local GameImage = class("GameImage",function() return display.newLayout(cc.size(160,122)) end)
local element = require("src.games.shuiguolaba.data.ShuiGuoLaBa_element_data")
function GameImage:ctor(sid)
	self.data = element.new(sid)
	self.size = self:getContentSize()
	self.rect = display.newSprite("sglb_icon_4.png")
	self.rect:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self.rect:setVisible(false)
	self:addChild(self.rect)
end

function GameImage:blink()
	self.rect:setVisible(true)
end

function GameImage:setRetain()
	self.isRetain = true
end

function GameImage:removeRetain()
	self.isRetain = false
end

function GameImage:disappear()
	self.rect:setVisible(false)
end

function GameImage:playRectAni()
	self.rect:setVisible(true)
	self.rect:runAction(cc.Sequence:create({
			cc.ScaleTo:create(0.2,1.2),
			cc.ScaleTo:create(0.2,1),
			cc.CallFunc:create(function()
				local sprite = display.newSprite()
				sprite:setScale(1.49)
				sprite:setPosition(cc.p(self.size.width/2,self.size.height/2))
				sprite:runAction(resource.getAnimateByKey("sglb_action_element",true))
				sprite:runAction(cc.Sequence:create({
					cc.DelayTime:create(1),
					cc.CallFunc:create(function(sender)
						sender:removeFromParent(true)
					end)}))
				self:addChild(sprite)
			end)
		}))
end

--免费奖励时特效
function GameImage:playFreeAni()
	self.rect:setVisible(true)
	local sprite = display.newSprite()
	sprite:setScale(1.49)
	sprite:setPosition(cc.p(self.size.width/2,self.size.height/2))
	sprite:runAction(resource.getAnimateByKey("sglb_action_element",true))
	sprite:runAction(cc.Sequence:create({
		cc.DelayTime:create(1),
		cc.CallFunc:create(function(sender)
			sender:removeFromParent(true)
		end)}))
	self:addChild(sprite)
end

function GameImage:breathAction()
	self.rect:setVisible(true)
	self.fade_action = self.rect:runAction(cc.RepeatForever:create(
		cc.Sequence:create({
				cc.FadeTo:create(0.5,50),
				cc.FadeTo:create(0.5,255)
				})
		))
	self:runAction(cc.Sequence:create({
				cc.DelayTime:create(3),
				cc.CallFunc:create(function(sender)
						self:stopAction(self.fade_action)
						self.fade_action = nil
						self.rect:setOpacity(255)
					end)
				}))
end

function GameImage:stopRectAni()
	self.rect:stopAllActions()
end

function GameImage:getData()
	return self.data
end

return GameImage
