--[[
*	下注
*	端口号：1203
]]
local HaoChePiaoYiGetBetConnect = class("FeiQingZouShouGetBetConnect",BaseConnect)
HaoChePiaoYiGetBetConnect.port = Port.PORT_HAOCHEPIAOYI
HaoChePiaoYiGetBetConnect.type = 2

function HaoChePiaoYiGetBetConnect:ctor(money,multipleId,callback)
	self.callback = callback
	self.money = money
	self.multipleId = multipleId
end
function HaoChePiaoYiGetBetConnect:writeData(data)
	data:writeInt(self.money)
	data:writeByte(self.multipleId)
	print("betmoney---------------------------------",self.money)
end
function HaoChePiaoYiGetBetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local newMoney = data:readLong()	--玩家新的钱
		print("newMoney------------------------",newMoney)
		Player.setGold(newMoney,true)
		self.params = true
	end
	
end

return HaoChePiaoYiGetBetConnect