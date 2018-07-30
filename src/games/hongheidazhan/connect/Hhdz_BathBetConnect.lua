--[[
*	红黑大战 批量下注请求
*	端口号：1300
]]
local Hhdz_BathBetConnect = class("Hhdz_BathBetConnect",BaseConnect)
Hhdz_BathBetConnect.port = Port.PORT_HHDZ
Hhdz_BathBetConnect.type = 4

function Hhdz_BathBetConnect:ctor(data,callback)
	self.m_data = data
	self.callback = callback
end
function Hhdz_BathBetConnect:writeData(data)
	local len = #self.m_data
	data:writeByte(len)
	for i = 1,len do
		data:writeInt(self.m_data[i].value) 
		data:writeByte(self.m_data[i].type)
	end
end

function Hhdz_BathBetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		Player.setGold(data:readLong())
	else
		self:showTips(result)
	end
	self.params = result
end

return Hhdz_BathBetConnect