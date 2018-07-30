--[[
*	抢庄牛牛 抢庄倍数请求
*	端口号：1210
]]
local Qznn_GetMasterConnect = class("Qznn_GetMasterConnect",BaseConnect)
Qznn_GetMasterConnect.port = Port.PORT_QZNN
Qznn_GetMasterConnect.type = 5

function Qznn_GetMasterConnect:ctor(value,callback)
	self.callback = callback
	self.value = value
end
function Qznn_GetMasterConnect:writeData(data)
	data:writeByte(self.value)
end

function Qznn_GetMasterConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = result
end

return Qznn_GetMasterConnect