--[[
 *	特效的显示控件
 *	@author gwj
]]
local GameEffect = class("GameEffect",function() return display.newLayout(cc.size(182,140)) end)

function GameEffect:ctor(data,isfreeState)
	self.size = self:getContentSize()
	self:setAnchorPoint(cc.p(0.5,0.5))
	self.blink_action = nil
	self.isblow = false
	self.data=data
	self.isfreeState = isfreeState
	--元素
	local sprite = display.newSprite()
	-- sprite:setAnchorPoint(cc.p(0,0))
	sprite:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self:addChild(sprite)
	self.sprite = sprite
	if self.isfreeState and self.data.freeIcon ~= nil then
		self.sprite:setSpriteFrame(self.data.freeIcon)
	else
		self.sprite:setSpriteFrame(self.data.icon)
	end
end

function GameEffect:setRect()
	if self.multiple_label then
		self.multiple_label:setVisible(true)
	end
	-- self:stopAllActions()
	self:playPrize()
end

function GameEffect:setMultiple(value)
	if not self.multiple_label then
		--数字
		local multiple_label = ccui.TextAtlas:create(1,"game/baodaren/bdr_number_4.png",42,60,0)
		multiple_label:setScale(0.5)
		multiple_label:setPosition(cc.p(self.size.width/2,self.size.height/2))
		self:addChild(multiple_label)
		self.multiple_label = multiple_label
	end
	self.multiple_label:setString(value)
end


function GameEffect:hideRect()
	-- self:stopAllActions()
	if self.blink_action then
		self:stopAction(self.blink_action)
		self.blink_action = nil
	end
	if self.multiple_label then
		self.multiple_label:setVisible(false)
	end
end

function GameEffect:playPrize()
	if self.ani_action then return end
	-- if self.ani_action or self.blink_action then return end
 	if self.data.action then
 		local ani = nil
 		if self.isfreeState and self.data.freeIcon ~= nil then
 			ani=resource.getAnimateByKey(self.data.freeaction,true)
 			if self.data.freesound ~= nil then
 				local controller = require("src.games.baodaren.data.BaoDaRenSoundController").getInstance()
 				controller:playOnlySoundChiLe(self.data.freesound)
 			end
 		else
 			ani=resource.getAnimateByKey(self.data.action,true)
 		end
 		self.ani_action = self.sprite:runAction(ani)
 	else
 		-- self.sprite:setSpriteFrame(self.data.icon)
 		self.blink_action = self.sprite:runAction(cc.RepeatForever:create(cc.Blink:create(1,2)))
	end
end

function GameEffect:playBonu(backfunction)
	self.sprite:runAction(cc.Sequence:create({
		resource.getAnimateByKey(self.data.action),
		cc.CallFunc:create(function(sender)
			if backfunction then
				backfunction()
			end
		end)}))
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
