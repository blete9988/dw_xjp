--[[
 *	显示的单项控件
 *	@author gwj
]]
local GameImage = class("GameImage",function() return cc.Sprite:create() end)

function GameImage:ctor(data)
	self.data=data
	self:setSpriteFrame(self.data.icon)
	self.size=self:getContentSize()
	self.controller = require("src.games.fistsuperman.data.FistsupermanController").getInstance()
	self.controller:addEventListener("YQCR_CONTROLLER_NORMAL_STATE",function(event,eventtype,parms)
		self.isFree = false
		self:updateIcon()
	end)
	self.controller:addEventListener("YQCR_CONTROLLER_FREE_STATE",function(event,eventtype,parms)
		self.isFree = true
		self:updateIcon()
	end)
end

function GameImage:updateIcon()
	if self.controller:isFree() and self.data.freeIcon ~= nil and self.isFree then
		self:setSpriteFrame(self.data.freeIcon)
	else
		self:setSpriteFrame(self.data.icon)
	end
end

function GameImage:playPrize()
	if self.data.prize~="" then
		local ani=resource.getAnimateByKey(self.data.prize,true)
 		self:runAction(ani)
 	else
 		self:runAction(cc.RepeatForever:create(cc.Blink:create(1,2)))
	end
end

function GameImage:playNormal()
	if self.data.normal~="" then
		local ani=resource.getAnimateByKey(self.data.normal,true)
 		self:runAction(ani)
	end
end

function GameImage:playTopprize()
	if self.data.topprize~="" then
		local ani=resource.getAnimateByKey(self.data.topprize,true)
 		self:runAction(ani)
	end
end

function GameImage:getType()
	if self.tempType then return self.tempType end
	return self.data.sid
end

function GameImage:stopAnimation()
	self:stopAllActions()
	self.tempType=nil
	self:setVisible(true)
	self:setSpriteFrame(self.data.icon)
end

-- function gameImage:changeGametype(gametype)
-- 	local effect=cc.Sprite:create()
-- 	effect:setPosition(cc.p(self.size.width/2,self.size.height/2))
-- 	effect:setScale(2.5)
-- 	self:addChild(effect)
-- 	local array={}
-- 	table.insert(array,Command.getAnimateByKey("football_bomb",false))
-- 	table.insert(array,CCCallFuncN:create(
-- 		function(sender)
-- 			self:stopAllActions()
-- 			sender:getParent():removeChild(sender,true)
-- 			self:setTexture("res/images/icon/football_icon_"..gametype..".png")
-- 			self.tempType=gametype
-- 		end))
-- 	effect:runAction(cc.Sequence:create(array))
-- end

function GameImage:setdata(data)
	self.data=data
	self:updateIcon()
	self.size=self:getContentSize()
end

function GameImage:onCleanup()
end

return GameImage
