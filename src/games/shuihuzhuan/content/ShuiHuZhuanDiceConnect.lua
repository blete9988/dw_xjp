--[[
*	水浒传
*	端口号：1207
]]
local ShuiHuZhuanDiceConnect = class("ShuiHuZhuanDiceConnect",BaseConnect)
ShuiHuZhuanDiceConnect.port = Port.PORT_SHUIHUZHUAN
ShuiHuZhuanDiceConnect.type = 3

function ShuiHuZhuanDiceConnect:ctor(choosetype,choose,callback)
	self.choosetype = choosetype	--半比 全比
	self.choose = choose  --0和，1大，2小
	self.callback = callback
end

function ShuiHuZhuanDiceConnect:writeData(data)
	print("choose--------------------",self.choose)
	print("choosetype--------------------",self.choosetype)
	data:writeByte(self.choose)
	data:writeByte(self.choosetype)
end

function ShuiHuZhuanDiceConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local choosedata = {}
		choosedata.chooseResult = data:readUnsignedByte()	--0和，1大，2小
		choosedata.isWin = data:readBoolean()	--是否赢了
		choosedata.diceI = data:readUnsignedByte()	--第一个骰子
		choosedata.diceII = data:readUnsignedByte()	--第二个骰子
		choosedata.multiples = data:readUnsignedByte()	--赢的倍数
		local playMoney = data:readLong()	--玩家金币
		Player.updateGold(playMoney)	
		self.params = choosedata
	end
end

return ShuiHuZhuanDiceConnect