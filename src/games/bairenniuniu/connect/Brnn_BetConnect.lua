--[[
*	百人牛牛 下注请求
*	端口号：1208
]]
local Brnn_BetConnect = class("Brnn_BetConnect",BaseConnect)
Brnn_BetConnect.port = Port.PORT_BRNN
Brnn_BetConnect.type = 2

function Brnn_BetConnect:ctor(money,type,callback)
	self.money = money
	self.areatype = type
	self.callback = callback
end
function Brnn_BetConnect:writeData(data)
	data:writeInt(self.money) 
	data:writeByte(self.areatype)
end

function Brnn_BetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		Player.setGold(data:readLong())
	else
		self:showTips(result)
	end
	self.params = result
end

return Brnn_BetConnect