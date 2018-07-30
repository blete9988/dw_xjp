--[[
*	项目工具
]]
local tools = {__newindex = function(t,k,v) 
	error(string.format("<tools> attempt to read undeclared variable <%s>",k))
end}

setmetatable(tools,tools)

Gbv.tools = tools

return tools