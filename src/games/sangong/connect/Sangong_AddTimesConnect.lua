--[[
*	三公 加倍倍数请求
*	端口号：1210
]]
local Sangong_AddTimesConnect = class("Sangong_AddTimesConnect",BaseConnect)
Sangong_AddTimesConnect.port = Port.PORT_SANGONG
Sangong_AddTimesConnect.type = 6

function Sangong_AddTimesConnect:ctor(value,callback)
	self.callback = callback
	self.value = value
end
function Sangong_AddTimesConnect:writeData(data)
	data:writeByte(self.value)
end

function Sangong_AddTimesConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = result
end

return Sangong_AddTimesConnect