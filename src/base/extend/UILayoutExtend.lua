--[[
*	UILayoutExtend.new(target)	target不为空则使用该对象，否则默认创建一个Layout对象
]]
local UILayoutExtend = class("UILayoutExtend", require("src.base.extend.UIWidgetExtend"),
	function(target --[[ = nil ]]) 
		return target or ccui.Layout:create()
	end
)
function UILayoutExtend.extend(target)
    setmetatableex(target,UILayoutExtend)
    target:setNodeEventEnabled(true)
    return target
end
function UILayoutExtend:ctor()
	self:setNodeEventEnabled(true)
end
return UILayoutExtend