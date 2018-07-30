--[[
*	如果new的时候传入显示对象则使用该对象，否则默认创建一个Sprite对象
]]
local CCSpriteExtend = class("CCSpriteExtend", require("src.base.extend.CCNodeExtend"),function(target) 
	return target or cc.Sprite:create()
end)

function CCSpriteExtend.extend(target)
    setmetatableex(target,CCSpriteExtend)
    return target
end

function CCSpriteExtend:playAnimationOnce(animation, removeWhenFinished, onComplete, delay)
end

function CCSpriteExtend:playAnimationForever(animation, delay)
end

return CCSpriteExtend