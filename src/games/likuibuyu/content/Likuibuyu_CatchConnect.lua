--[[
*	抢庄牛牛 加入房间请求
*	端口号：1210
]]
local Likuibuyu_CatchConnect = class("Likuibuyu_CatchConnect",BaseConnect)

local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")
local cmd = "src.games.likuibuyu.content.CMD_LKGame"
local g_var = ExternalFun.req_var

Likuibuyu_CatchConnect.port = Port.PORT_LIKUIBUYU
Likuibuyu_CatchConnect.type = g_var(cmd).SUB_C_CATCH_FISH

function Likuibuyu_CatchConnect:ctor(index,request)
	self.index = index
	self.request = request
end
function Likuibuyu_CatchConnect:writeData(data)
	data:writeInt(self.index) 
	for i=1,5 do
		mlog(DEBUG_W,self.request[i],"====")
		data:writeInt(self.request[i]) 
	end
end

function Likuibuyu_CatchConnect:readData(data)
	local result = data:readUnsignedByte()
	
	self.params = result
end

return Likuibuyu_CatchConnect