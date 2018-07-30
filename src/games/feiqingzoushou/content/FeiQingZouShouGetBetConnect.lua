--[[
*	下注
*	端口号：1201
]]
local FeiQingZouShouGetBetConnect = class("FeiQingZouShouGetBetConnect",BaseConnect)
FeiQingZouShouGetBetConnect.port = Port.PORT_FEIQINGZOUSHOU
FeiQingZouShouGetBetConnect.type = 2

function FeiQingZouShouGetBetConnect:ctor(money,multipleId,callback)
	self.callback = callback
	self.money = money
	self.multipleId = multipleId
end
function FeiQingZouShouGetBetConnect:writeData(data)
	data:writeInt(self.money)
	data:writeByte(self.multipleId)
end
function FeiQingZouShouGetBetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local newMoney = data:readLong()	--玩家新的钱
		print("playerMoney------------------------------------------------",newMoney)
		Player.setGold(newMoney,true)
		self.params = true
	end
	
end

return FeiQingZouShouGetBetConnect