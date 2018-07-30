--[[
*	抢庄牛牛 准备/取消准备 请求
*	端口号：1210
]]
local Qznn_ReadyStatusConnect = class("Qznn_ReadyStatusConnect",BaseConnect)
Qznn_ReadyStatusConnect.port = Port.PORT_QZNN

--[[
*	@param type 2：表示准备，3：表示取消准备
]]
function Qznn_ReadyStatusConnect:ctor(type,callback)
	self.type = type
	self.callback = callback
end
function Qznn_ReadyStatusConnect:writeData(data)
	
end

function Qznn_ReadyStatusConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = result
end

return Qznn_ReadyStatusConnect