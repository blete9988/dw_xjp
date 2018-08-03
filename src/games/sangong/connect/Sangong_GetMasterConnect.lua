--[[
*	三公 抢庄倍数请求
*	端口号：1210
]]
local Sangong_GetMasterConnect = class("Sangong_GetMasterConnect",BaseConnect)
Sangong_GetMasterConnect.port = Port.PORT_SANGONG
Sangong_GetMasterConnect.type = 5

function Sangong_GetMasterConnect:ctor(value,callback)
	self.callback = callback
	self.value = value
end
function Sangong_GetMasterConnect:writeData(data)
	data:writeByte(self.value)
end

function Sangong_GetMasterConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = result
end

return Sangong_GetMasterConnect