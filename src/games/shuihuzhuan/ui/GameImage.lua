--[[
 *	水浒传控件
 *	@author gwj
]]
local GameImage = class("GameImage",function() return display.newSprite() end)
local element = require("src.games.shuihuzhuan.data.ShuiHuZhuan_element_data")
function GameImage:ctor(id)
	self:updateData(id)
	self.size=self:getContentSize()
end

function GameImage:trun()
	local begin_number = self.data.sid
	local ani_array = {}
	for i=1,9 do
		local sprite_frame = display.getFrameCache():getSpriteFrame("shz_element_turn_"..i..".png")
		table.insert(ani_array,sprite_frame)
		-- begin_number = begin_number + 1
		-- if begin_number > 9 then
		-- 	begin_number = 1
		-- end
	end
	self:stopAllActions()
	self.ani_action = nil
	local animation = cc.Animation:createWithSpriteFrames(ani_array,0.05)
	self.trun_action = self:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
end

function GameImage:stopTrun()
	-- if self.trun_action then
	-- 	self:stopAction(self.trun_action)
	-- 	self.trun_action = nil
	-- end
	self:stopAllActions()
	self.ani_action = nil
end

function GameImage:updateData(sid)
	self.data = element.new(sid)
	self:setSpriteFrame(self.data.icon)
end

function GameImage:setGray()
	self:setSpriteFrame(self.data.gray)
end

function GameImage:setNormal()
	self:stopTrun()
	self:setSpriteFrame(self.data.icon)
end

function GameImage:playAni()
	if self.ani_action then return end
	self.ani_action = self:runAction(resource.getAnimateByKey(self.data.animation))
	require("src.games.shuihuzhuan.data.ShuiHuZhuanSoundController").getInstance():playOnlySound(self.data.sound)
end

function GameImage:getData()
	return self.data
end

return GameImage
