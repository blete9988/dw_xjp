--[[
*	存款 请求
*	端口号：1100
]]
local DepositConnect = class("DepositConnect",BaseConnect)
DepositConnect.port = Port.PORT_NORMAL
DepositConnect.type = 10

function DepositConnect:ctor(gold,callback)
	self.gold = gold
	self.callback = callback
end
function DepositConnect:writeData(data)
	data:writeLong(self.gold)
end
function DepositConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		Player.moneyBytesRead(data)
		display.showMsg(display.trans("##20016",self.gold))
	end
	self.params = result
end

return DepositConnect