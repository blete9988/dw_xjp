--[[
*	命令批分
]]
local function parse(cmd)
	if not Player then return end
	local pos,cmdparse = 1, {}
	
    for st,sp in function() return string.find(cmd, "[,，]", pos) end do
        table.insert(cmdparse, tonumber(string.sub(cmd, pos, st - 1)))
        pos = sp + 1
    end
    table.insert(cmdparse,  tonumber(string.sub(cmd, pos)))
    require("src.app.connect.gamehall.PrivateCMConnect").new(cmdparse):connect()
    
end
return parse