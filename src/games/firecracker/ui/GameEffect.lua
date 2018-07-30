--[[
 *	特效的显示控件
 *	@author gwj
]]
local GameEffect = class("GameEffect",function() return display.newLayout(cc.size(192,162)) end)

function GameEffect:ctor(data)
	self.data = data
	self.size = self:getContentSize()
	--元素
	local sprite = display.newSprite(self.data.icon)
	sprite:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self:addChild(sprite)
	self.sprite = sprite
end

function GameEffect:playPrize()
 	if self.data.prize and self.data.prize ~= "" then
 		local ani = resource.getAnimateByKey(self.data.prize,true)
 		self.sprite:runAction(ani)
 	else
 		self.sprite:setSpriteFrame(self.data.icon)
 		self.sprite:runAction(cc.RepeatForever:create(cc.Blink:create(1,2)))
	end
end

function GameEffect:playBonu(number)
	self.sprite:stopAllActions()
	if number == 1 then
		self.sprite:runAction(resource.getAnimateByKey("action_fk_13",true))
	elseif number == 2 then
		self.sprite:runAction(resource.getAnimateByKey("action_fk_13p",true))
	else
		self.sprite:runAction(resource.getAnimateByKey("action_fk_13tp",true))
	end
end

function GameEffect:getType()
	if self.tempType then return self.tempType end
	return self.data.sid
end

function GameEffect:setdata(data)
	self.data=data
	self.sprite:setSpriteFrame(self.data.icon)
	self.size=self:getContentSize()
end

return GameEffect
