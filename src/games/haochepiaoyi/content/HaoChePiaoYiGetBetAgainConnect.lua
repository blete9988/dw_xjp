--[[
*	下注
*	端口号：1203
]]
local HaoChePiaoYiGetBetAgainConnect = class("HaoChePiaoYiGetBetAgainConnect",BaseConnect)
HaoChePiaoYiGetBetAgainConnect.port = Port.PORT_HAOCHEPIAOYI
HaoChePiaoYiGetBetAgainConnect.type = 4

function HaoChePiaoYiGetBetAgainConnect:ctor(betdatas,callback)
	self.callback = callback
	self.betdatas = betdatas
end
function HaoChePiaoYiGetBetAgainConnect:writeData(data)
	data:writeByte(#self.betdatas)
	for i=1,#self.betdatas do
		local model = self.betdatas[i]
		data:writeInt(model.money)
		data:writeByte(model.multiplesSid)
	end
end
function HaoChePiaoYiGetBetAgainConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local newMoney = data:readLong()	--更新玩家金额
		Player.setGold(newMoney,true)
		self.params = true
	end
	
end

return HaoChePiaoYiGetBetAgainConnect