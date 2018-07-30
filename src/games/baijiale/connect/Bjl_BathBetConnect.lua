--[[
*	百家乐 批量下注请求
*	端口号：1200
]]
local Bjl_BathBetConnect = class("Bjl_BathBetConnect",BaseConnect)
Bjl_BathBetConnect.port = Port.PORT_BJL
Bjl_BathBetConnect.type = 4

function Bjl_BathBetConnect:ctor(data,callback)
	self.m_data = data
	self.callback = callback
end
function Bjl_BathBetConnect:writeData(data)
	local len = #self.m_data
	data:writeByte(len)
	for i = 1,len do
		data:writeInt(self.m_data[i].value) 
		data:writeByte(self.m_data[i].type)
	end
end

function Bjl_BathBetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		Player.setGold(data:readLong())
	else
		self:showTips(result)
	end
	self.params = result
end

return Bjl_BathBetConnect