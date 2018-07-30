--[[
 *	特效的显示控件
 *	@author gwj
]]
local GameEffect = class("GameEffect",function() return display.newImage("FP_bg_1.png") end)

function GameEffect:ctor(data,isfreeState)
	self.blink_action = nil
	self.isblow = false
	self.data=data
	self.isfreeState = isfreeState
	if isfreeState then
		self:loadTexture("FP_bg_4.png",1)
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

function GameEffect:setRect(rectType,isblow)
	-- self.rectSprite:setVisible(true)
	self.isblow = isblow
	self:setVisible(true)
	self.rectSprite:setVisible(true)
	if self.multiple_label then
		self.multiple_label:setVisible(true)
	end
	self.rectSprite:loadTexture("FS_Rect_"..rectType..".png",1)
	-- if not self.isblow then
	self.sprite:stopAllActions()
	self:playPrize()
	-- end
end

function GameEffect:setMultiple(value)
	if not self.multiple_label then
		--数字
		local multiple_label = ccui.TextAtlas:create(1,"game/fistsuperman/fontnumber_42X60.png",42,60,0)
		multiple_label:setScale(0.5)
		multiple_label:setPosition(cc.p(self.size.width/2,self.size.height/2))
		self:addChild(multiple_label)
		self.multiple_label = multiple_label
	end
	self.multiple_label:setString(value)
end


function GameEffect:hideRect()
	-- self.rectSprite:setVisible(false)
	-- if self.isblow then
	-- 	self.rectSprite:setVisible(false)
	-- 	if self.multiple_label then
	-- 		self.multiple_label:setVisible(false)
	-- 	end
	-- else
		self:stopblink()
	-- end
end

function GameEffect:playPrize()
	-- if self.ani_action or self.blink_action then return end
	if self.isblow then
		self.sprite:runAction(resource.getAnimateByKey("action_FS_11_2",true))
 	elseif self.data.action then
 		local ani=resource.getAnimateByKey(self.data.action,true)
 		self.ani_action = self.sprite:runAction(ani)
 		if self.data.sound then
			require("src.games.fistsuperman.data.FistsupermanSoundController").getInstance():playOnlySoundADDX(self.data.sound)
		end
 	else
 		self.sprite:setSpriteFrame(self.data.icon)
 		self.blink_action = self.sprite:runAction(cc.RepeatForever:create(cc.Blink:create(1,2)))
	end
end

function GameEffect:playBonu(backfunction)
	self.rectSprite:loadTexture("FS_Rect_50.png",1)
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

function GameEffect:playBigPrizeI()
	self.isblow = true
	self.ani_action = self.sprite:runAction(cc.Sequence:create({
			resource.getAnimateByKey("action_FS_11_1"),
			cc.CallFunc:create(function(sender)
				sender:setSpriteFrame("fsp_11_41.png")
			end)
		}))
end

function GameEffect:playBigPrizeII()
	self.sprite:stopAllActions()
	self.ani_action = self.sprite:runAction(resource.getAnimateByKey("action_FS_11_2",true))
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
