--[[
*	三公 准备/取消准备 请求
*	端口号：1210
]]
local Sangong_ReadyStatusConnect = class("Sangong_ReadyStatusConnect",BaseConnect)
Sangong_ReadyStatusConnect.port = Port.PORT_SANGONG

--[[
*	@param type 2：表示准备，3：表示取消准备
]]
function Sangong_ReadyStatusConnect:ctor(type,callback)
	self.type = type
	self.callback = callback
end
function Sangong_ReadyStatusConnect:writeData(data)
	
end

function Sangong_ReadyStatusConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = result
end

return Sangong_ReadyStatusConnect