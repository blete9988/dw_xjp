--[[
*	续下注
*	端口号：1202
]]
local JinShaYinShaGetBetAgainConnect = class("JinShaYinShaGetBetAgainConnect",BaseConnect)
JinShaYinShaGetBetAgainConnect.port = Port.PORT_JINSHAYINSHA
JinShaYinShaGetBetAgainConnect.type = 4

function JinShaYinShaGetBetAgainConnect:ctor(betdatas,callback)
	self.callback = callback
	self.betdatas = betdatas
end
function JinShaYinShaGetBetAgainConnect:writeData(data)
	data:writeByte(#self.betdatas)
	for i=1,#self.betdatas do
		local model = self.betdatas[i]
		data:writeInt(model.money)
		print("sid------------------",model.multiplesSid)
		print("money------------------",model.money)
		data:writeByte(model.multiplesSid)
	end
end
function JinShaYinShaGetBetAgainConnect:readData(data)
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

return JinShaYinShaGetBetAgainConnect