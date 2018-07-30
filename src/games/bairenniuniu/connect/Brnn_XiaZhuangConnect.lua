--[[
*	百人牛牛 申请下庄
*	端口号：1208
]]
local Brnn_XiaZhuangConnect = class("Brnn_XiaZhuangConnect",BaseConnect)
Brnn_XiaZhuangConnect.port = Port.PORT_BRNN
Brnn_XiaZhuangConnect.type = 6

function Brnn_XiaZhuangConnect:ctor(callback)
	self.callback = callback
end
function Brnn_XiaZhuangConnect:writeData(data)
	
end

function Brnn_XiaZhuangConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = result
end

return Brnn_XiaZhuangConnect