--[[
*	抢庄牛牛 加倍倍数请求
*	端口号：1210
]]
local Qznn_AddTimesConnect = class("Qznn_AddTimesConnect",BaseConnect)
Qznn_AddTimesConnect.port = Port.PORT_QZNN
Qznn_AddTimesConnect.type = 6

function Qznn_AddTimesConnect:ctor(value,callback)
	self.callback = callback
	self.value = value
end
function Qznn_AddTimesConnect:writeData(data)
	data:writeByte(self.value)
end

function Qznn_AddTimesConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = result
end

return Qznn_AddTimesConnect