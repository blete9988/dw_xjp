--[[
*	通比牛牛 准备/取消准备 请求
*	端口号：1209
]]
local Tbnn_ReadyStatusConnect = class("Tbnn_ReadyStatusConnect",BaseConnect)
Tbnn_ReadyStatusConnect.port = Port.PORT_TBNN

--[[
*	@param type 2：表示准备，3：表示取消准备
]]
function Tbnn_ReadyStatusConnect:ctor(type,callback)
	self.type = type
	self.callback = callback
end
function Tbnn_ReadyStatusConnect:writeData(data)
	
end

function Tbnn_ReadyStatusConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		if self.type == 2 then
--			require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance():getMineInfo():setReadyStatus(ST.TYPE_GAMETBNN_READY)
		else
--			require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance():getMineInfo():setReadyStatus(ST.TYPE_GAMETBNN_NOT_READY)
		end
	end
	self.params = result
end

return Tbnn_ReadyStatusConnect