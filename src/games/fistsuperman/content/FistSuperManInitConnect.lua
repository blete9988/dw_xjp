--[[
*	一拳超人初始化
*	端口号：1204
]]
local FistSuperManInitConnect = class("FistSuperManInitConnect",BaseConnect)
FistSuperManInitConnect.port = Port.PORT_FISTSUPERMAN
FistSuperManInitConnect.type = 1

function FistSuperManInitConnect:ctor(callback)
	self.callback = callback
end

function FistSuperManInitConnect:writeData(data)
end

function FistSuperManInitConnect:readData(data)
	mlog("FistSuperManInitConnect:readData "..tostring(data:getTop()))
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
		local controller = require("src.games.fistsuperman.data.FistsupermanController").getInstance()
		controller:updateFreeCount(useFreeCount)
		controller:updateMaxFreeCount(useFreeCount + surplusFreeCount)
		controller:setTotalFreeWinMoney(totalFreeWinMoney)
		controller:setBetinitMoney(betinitMoney)
		controller:updateFreeBetMoney(free_bet_money)
		self.params = true
	end
	
end

return FistSuperManInitConnect