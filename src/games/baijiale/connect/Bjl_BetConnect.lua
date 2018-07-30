--[[
*	百家乐 下注请求
*	端口号：1200
]]
local Bjl_BetConnect = class("Bjl_BetConnect",BaseConnect)
Bjl_BetConnect.port = Port.PORT_BJL
Bjl_BetConnect.type = 2

function Bjl_BetConnect:ctor(money,type,callback)
	self.money = money
	self.areatype = type
	self.callback = callback
end
function Bjl_BetConnect:writeData(data)
	data:writeInt(self.money) 
	data:writeByte(self.areatype)
end

function Bjl_BetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		Player.setGold(data:readLong())
	else
		self:showTips(result)
	end
	self.params = result
end

return Bjl_BetConnect