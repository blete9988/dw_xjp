--[[
 *	特效的显示控件
 *	@author gwj
]]
local GameEffect = class("GameEffect",function() return display.newImage("flzt_element_bg.png") end)

function GameEffect:ctor(data,isfreeState)
	self.blink_action = nil
	self.data=data
	self.isfreeState = isfreeState
	if isfreeState then
		self:loadTexture("flzt_free_element_bg.png",1)
	end
	--元素
	local sprite = display.newSprite(self.data.icon)
	sprite:setAnchorPoint(cc.p(0,0))
	self:addChild(sprite)
	self.sprite = sprite
	--边框
	local rect = display.newImage()
	rect:setAnchorPoint(cc.p(0,0))
	self:addChild(rect)
	self.size=self:getContentSize()
	self.rectSprite = rect
end

function GameEffect:setRect(rectType)
	-- self.rectSprite:setVisible(true)
	self:setVisible(true)
	self.rectSprite:setVisible(true)
	if self.multiple_label then
		self.multiple_label:setVisible(true)
	end
	if rectType < 10 then
		rectType = "0"..rectType
	end
	self.rectSprite:loadTexture("flzt_rect_"..rectType..".png",1)
	self.sprite:stopAllActions()
	self:playPrize()
end

function GameEffect:setMultiple(value)
	if not self.multiple_label then
		--数字
		local multiple_label = ccui.TextAtlas:create(1,"game/feilongzaitian/flzt_number_4.png",42,60,0)
		multiple_label:setScale(0.5)
		multiple_label:setPosition(cc.p(self.size.width/2,self.size.height/2))
		self:addChild(multiple_label)
		self.multiple_label = multiple_label
	end
	self.multiple_label:setString(value)
end


function GameEffect:hideRect()
	self:stopblink()
end

function GameEffect:playPrize()
	-- if self.ani_action or self.blink_action then return end
 	if self.data.action then
 		local ani=resource.getAnimateByKey(self.data.action,true)
 		self.ani_action = self.sprite:runAction(ani)
 		if self.data.sound ~= nil then
			local controller = require("src.games.feilongzaitian.data.FeiLongZaiTianSoundController").getInstance()
			controller:playOnlySoundLong(self.data.sound)
 		end
 	else
 		self.sprite:setSpriteFrame(self.data.icon)
 		self.blink_action = self.sprite:runAction(cc.RepeatForever:create(cc.Blink:create(1,2)))
	end
end

function GameEffect:playBonu(backfunction)
	self.rectSprite:loadTexture("flzt_rect_00.png",1)
	self.rectSprite:setVisible(true)
	self.sprite:runAction(cc.Sequence:create({
		resource.getAnimateByKey(self.data.action),
		cc.CallFunc:create(function(sender)
			self.rectSprite:setVisible(false)
			if backfunction then
				backfunction()
			end
		end)}))
end

function GameEffect:stopblink()
	self:setVisible(false)
	-- if self.blink_action then
	-- 	self:setVisible(false)
		-- self.sprite:stopAction(self.blink_action)
		-- self.blink_action = nil
	-- end
end

function GameEffect:getType()
	if self.tempType then return self.tempType end
	return self.data.sid
end

function GameEffect:stopAnimation()
	self:stopAllActions()
	self.tempType=nil
	self:setVisible(true)
	self.sprite:setSpriteFrame(self.data.icon)
end

function GameEffect:setdata(data)
	self.data=data
	self.sprite:setSpriteFrame(self.data.icon)
	self.size=self:getContentSize()
end

return GameEffect
