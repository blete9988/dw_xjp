--[[
*	百人牛牛 申请上庄
*	端口号：1208
]]
local Brnn_ShangZhuangConnect = class("Brnn_ShangZhuangConnect",BaseConnect)
Brnn_ShangZhuangConnect.port = Port.PORT_BRNN
Brnn_ShangZhuangConnect.type = 5

function Brnn_ShangZhuangConnect:ctor(callback)
	self.callback = callback
end
function Brnn_ShangZhuangConnect:writeData(data)
	
end

function Brnn_ShangZhuangConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = result
end

return Brnn_ShangZhuangConnect