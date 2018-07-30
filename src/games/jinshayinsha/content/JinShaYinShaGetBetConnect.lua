--[[
*	下注
*	端口号：1202
]]
local JinShaYinShaGetBetConnect = class("JinShaYinShaGetBetConnect",BaseConnect)
JinShaYinShaGetBetConnect.port = Port.PORT_JINSHAYINSHA
JinShaYinShaGetBetConnect.type = 2

function JinShaYinShaGetBetConnect:ctor(money,multipleId,callback)
	self.callback = callback
	self.money = money
	self.multipleId = multipleId
end
function JinShaYinShaGetBetConnect:writeData(data)
	data:writeInt(self.money)
	data:writeByte(self.multipleId)
end
function JinShaYinShaGetBetConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local newMoney = data:readLong()	--玩家新的钱
		Player.setGold(newMoney,true)
		self.params = true
	end
	
end

return JinShaYinShaGetBetConnect