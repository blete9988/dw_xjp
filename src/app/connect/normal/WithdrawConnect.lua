--[[
*	取款 请求
*	端口号：1100
]]
local WithdrawConnect = class("WithdrawConnect",BaseConnect)
WithdrawConnect.port = Port.PORT_NORMAL
WithdrawConnect.type = 11

function WithdrawConnect:ctor(gold,psw,callback)
	self.gold = gold
	self.psw = psw
	self.callback = callback
end
function WithdrawConnect:writeData(data)
	data:writeLong(self.gold)
	data:writeString(self.psw)
end
function WithdrawConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		Player.moneyBytesRead(data)
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_BANK_GOLD_UPDATE,Player.gold,true)
		display.showMsg(display.trans("##20017",self.gold))
	end
	self.params = result
end

return WithdrawConnect