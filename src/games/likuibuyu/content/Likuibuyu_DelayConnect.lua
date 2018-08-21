--[[
*	开火
*	端口号：1210
]]
local Likuibuyu_DelayConnect = class("Likuibuyu_DelayConnect",BaseConnect)

local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")
local cmd = "src.games.likuibuyu.content.CMD_LKGame"
local g_var = ExternalFun.req_var

Likuibuyu_DelayConnect.port = Port.PORT_LIKUIBUYU
Likuibuyu_DelayConnect.type = g_var(cmd).SUB_C_DELAY

function Likuibuyu_DelayConnect:ctor()
	
end
function Likuibuyu_DelayConnect:writeData(data)
	
end

function Likuibuyu_DelayConnect:readData(data)
	local result = data:readUnsignedByte()
	
	self.params = result
end

return Likuibuyu_DelayConnect