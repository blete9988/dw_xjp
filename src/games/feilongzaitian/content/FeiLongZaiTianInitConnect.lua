--[[
*	飞龙在天初始化
*	端口号：1206
]]
local FeiLongZaiTianInitConnect = class("FeiLongZaiTianInitConnect",BaseConnect)
FeiLongZaiTianInitConnect.port = Port.PORT_FEILONGZAITIAN
FeiLongZaiTianInitConnect.type = 1

function FeiLongZaiTianInitConnect:ctor(callback)
	self.callback = callback
end

function FeiLongZaiTianInitConnect:writeData(data)
end

function FeiLongZaiTianInitConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		print("PlayerID--------------------------",Player.id)
		local betinitMoney = data:readInt()	--下注金额
		local surplusFreeCount = data:readUnsignedByte()	--还有多少次免费次数
		local useFreeCount = data:readUnsignedByte()	--已经使用的免费次数
		local totalFreeWinMoney = data:readLong()		--免费赢的钱
		local free_bet_money = data:readInt()		--免费投注金额
		local dragon_ball = data:readUnsignedByte()		--龙珠
		print("initdata----------------------------",betinitMoney,surplusFreeCount,useFreeCount,totalFreeWinMoney,free_bet_money,dragon_ball)
		local controller = require("src.games.feilongzaitian.data.FeiLongZaiTianController").getInstance()
		controller:updateFreeCount(useFreeCount)
		controller:updateMaxFreeCount(useFreeCount + surplusFreeCount)
		controller:setTotalFreeWinMoney(totalFreeWinMoney)
		controller:setBetinitMoney(betinitMoney)
		controller:updateFreeBetMoney(free_bet_money)
		controller:updateDragonBall(dragon_ball)
		self.params = true
	end
	
end

return FeiLongZaiTianInitConnect