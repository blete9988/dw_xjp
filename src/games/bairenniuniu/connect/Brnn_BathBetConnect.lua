--[[
*	百人牛牛 批量下注请求
*	端口号：1208
]]
local Brnn_BathBetConnect = class("Brnn_BathBetConnect",BaseConnect)
Brnn_BathBetConnect.port = Port.PORT_BRNN
Brnn_BathBetConnect.type = 4

function Brnn_BathBetConnect:ctor(data,callback)
	self.m_data = data
	self.callback = callback
end
function Brnn_BathBetConnect:writeData(data)
	local len = #self.m_data
	data:writeByte(len)
	for i = 1,len do
		data:writeInt(self.m_data[i].value) 
		data:writeByte(self.m_data[i].type)
	end
end

function Brnn_BathBetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		Player.setGold(data:readLong())
	else
		self:showTips(result)
	end
	self.params = result
end

return Brnn_BathBetConnect