--[[
*	水果拉霸初始化
*	端口号：1209
]]
local ShuiGuoLaBaGambleConnect = class("ShuiGuoLaBaGambleConnect",BaseConnect)
ShuiGuoLaBaGambleConnect.port = Port.PORT_SHUIGUOLABA
ShuiGuoLaBaGambleConnect.type = 3

function ShuiGuoLaBaGambleConnect:ctor(choosetype,callback)
	self.choosetype = choosetype
	self.callback = callback
end

function ShuiGuoLaBaGambleConnect:writeData(data)
	data:writeByte(self.choosetype)
end

function ShuiGuoLaBaGambleConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local gamble = data:readUnsignedByte() --结果 1:大 0：小
		local winMoney = data:readLong()		--输赢
		local playMoney = data:readLong()	--玩家金币
		Player.setGold(playMoney)
		print("BaGamble winMoney--------------------------",winMoney)
		mlog(gamble,"返回大小！")
		mlog(winMoney,"输赢")
		local result_data = {}
		result_data.gamble = gamble
		result_data.winMoney = winMoney

		self.params = result_data
	end
end

return ShuiGuoLaBaGambleConnect