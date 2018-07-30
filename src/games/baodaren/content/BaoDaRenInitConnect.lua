--[[
*	包大人初始化
*	端口号：1205
]]
local BaoDaRenInitConnect = class("BaoDaRenInitConnect",BaseConnect)
BaoDaRenInitConnect.port = Port.PORT_BAODAREN
BaoDaRenInitConnect.type = 1

function BaoDaRenInitConnect:ctor(callback)
	self.callback = callback
end

function BaoDaRenInitConnect:writeData(data)
end

function BaoDaRenInitConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local betinitMoney = data:readInt()	--下注金额
		local surplusFreeCount = data:readUnsignedByte()	--还有多少次免费次数
		local useFreeCount = data:readUnsignedByte()	--已经使用的免费次数
		local totalFreeWinMoney = data:readLong()		--免费赢的钱
		local free_bet_money = data:readInt()		--免费投注金额
		local free_multiple = data:readUnsignedByte()	--免费倍数
		local controller = require("src.games.baodaren.data.BaoDaRenController").getInstance()
		controller:updateMaxFreeCount(useFreeCount + surplusFreeCount)
		controller:updateFreeCount(useFreeCount)
		controller:setTotalFreeWinMoney(totalFreeWinMoney)
		controller:setBetinitMoney(betinitMoney)
		controller:updateFreeBetMoney(free_bet_money)
		controller:updateFreeMultiple(free_multiple)
		self.params = true
	end
end

return BaoDaRenInitConnect