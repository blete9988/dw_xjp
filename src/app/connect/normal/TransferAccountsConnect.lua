--[[
*	转账 请求
*	端口号：1100
]]
local TransferAccountsConnect = class("TransferAccountsConnect",BaseConnect)
TransferAccountsConnect.port = Port.PORT_NORMAL
TransferAccountsConnect.type = 13

function TransferAccountsConnect:ctor(gold,psw,targetid,callback)
	self.targetid = targetid
	self.gold = gold
	self.psw = psw
	self.callback = callback
end
function TransferAccountsConnect:writeData(data)
	data:writeInt(self.targetid) 
	data:writeLong(self.gold)
	data:writeString(self.psw)
end
function TransferAccountsConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		Player.setGold(data:readLong())
	end
	self.params = result
end

return TransferAccountsConnect