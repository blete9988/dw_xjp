--[[
*	自定义样式
*	##必须返回一个显示对象
]]
local custom = {
	["test"] = function() 
		return display.newImage("p_ui_1088.png")
	end 
}
return custom
