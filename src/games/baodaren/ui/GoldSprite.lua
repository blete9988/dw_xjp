--[[
 *	金币控件
 *	@author gwj
]]
local GoldSprite = class("GoldSprite",function() return display.newSprite("bdr_action_6_01.png") end)

function GoldSprite:ctor()
	self:runAction(resource.getAnimateByKey("bdr_action_yuanbao",true))
	--创建刚体
    self:setPhysicsBody(cc.PhysicsBody:createCircle(0.1))
    --摩擦力
    self:getPhysicsBody():setLinearDamping(0.2)
end

return GoldSprite
