--[[
*	CCLayerExtend.new(target) target不为空则使用该对象，否则默认创建一个Layout对象
]]
local CCLayerExtend = class("CCLayerExtend", require("src.base.extend.CCNodeExtend"),
	function(target --[[ = nil ]]) 
		return target or ccui.Layout:create()
	end
)

function CCLayerExtend.extend(target)
    setmetatableex(target,CCLayerExtend)
	target:setNodeEventEnabled(true,nil)
    return target
end
function CCLayerExtend:ctor()
	self:setNodeEventEnabled(true)
end
return CCLayerExtend
