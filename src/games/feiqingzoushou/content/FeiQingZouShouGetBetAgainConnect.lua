--[[
*	下注
*	端口号：1201
]]
local FeiQingZouShouGetBetAgainConnect = class("FeiQingZouShouGetBetAgainConnect",BaseConnect)
FeiQingZouShouGetBetAgainConnect.port = Port.PORT_FEIQINGZOUSHOU
FeiQingZouShouGetBetAgainConnect.type = 4

function FeiQingZouShouGetBetAgainConnect:ctor(betdatas,callback)
	self.callback = callback
	self.betdatas = betdatas
end
function FeiQingZouShouGetBetAgainConnect:writeData(data)
	data:writeByte(#self.betdatas)
	for i=1,#self.betdatas do
		local model = self.betdatas[i]
		data:writeInt(model.money)
		print("sid------------------",model.multiplesSid)
		print("money------------------",model.money)
		data:writeByte(model.multiplesSid)
	end
end
function FeiQingZouShouGetBetAgainConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local newMoney = data:readLong()	--更新玩家金额
		print("playerMoney------------------------------------------------",newMoney)
		Player.setGold(newMoney,true)
		self.params = true
	end
	
end

return FeiQingZouShouGetBetAgainConnect