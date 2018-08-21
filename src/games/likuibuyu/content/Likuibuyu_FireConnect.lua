--[[
*	开火
*	端口号：1210
]]
local Likuibuyu_FireConnect = class("Likuibuyu_FireConnect",BaseConnect)

local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")
local cmd = "src.games.likuibuyu.content.CMD_LKGame"
local g_var = ExternalFun.req_var

Likuibuyu_FireConnect.port = Port.PORT_LIKUIBUYU
Likuibuyu_FireConnect.type = g_var(cmd).SUB_C_FIRE

function Likuibuyu_FireConnect:ctor(condata)
	self.condata = condata
end
function Likuibuyu_FireConnect:writeData(data)
	data:writeInt(self.condata.int1) 
	data:writeInt(self.condata.int2) 
	data:writeInt(self.condata.int3) 

	data:writeShort(self.condata.short1) 
	data:writeShort(self.condata.short2) 
	
end

function Likuibuyu_FireConnect:readData(data)
	local result = data:readUnsignedByte()
	
	self.params = result
end

return Likuibuyu_FireConnect