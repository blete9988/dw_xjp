--[[
*	红黑大战 下注请求
*	端口号：1300
]]
local Hhdz_BetConnect = class("Hhdz_BetConnect",BaseConnect)
Hhdz_BetConnect.port = Port.PORT_HHDZ
Hhdz_BetConnect.type = 2

function Hhdz_BetConnect:ctor(money,type,callback)
	self.money = money
	self.areatype = type
	self.callback = callback
end
function Hhdz_BetConnect:writeData(data)
	data:writeInt(self.money) 
	data:writeByte(self.areatype)
end

function Hhdz_BetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		Player.setGold(data:readLong())
	else
		self:showTips(result)
	end
	self.params = result
end

return Hhdz_BetConnect