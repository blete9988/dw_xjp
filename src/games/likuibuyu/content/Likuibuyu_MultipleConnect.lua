--[[
*	倍数
*	端口号：1210
]]
local Likuibuyu_MultipleConnect = class("Likuibuyu_MultipleConnect",BaseConnect)

local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")
local cmd = "src.games.likuibuyu.content.CMD_LKGame"
local g_var = ExternalFun.req_var

Likuibuyu_MultipleConnect.port = Port.PORT_LIKUIBUYU
Likuibuyu_MultipleConnect.type = g_var(cmd).SUB_C_MULTIPLE

function Likuibuyu_MultipleConnect:ctor(condata)
	self.condata = condata
end
function Likuibuyu_MultipleConnect:writeData(data)
	data:writeInt(self.condata.int1) 
end

function Likuibuyu_MultipleConnect:readData(data)
	local result = data:readUnsignedByte()
	
	self.params = result
end

return Likuibuyu_MultipleConnect