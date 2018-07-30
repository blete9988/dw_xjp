--[[--
 * 鞭炮数据
 * @author GWJ
 * 
]]

local FirecrackerController = class("FirecrackerController")
local COLUMN_COUNT=5
local LINE_COUNT=3
local MAX_TYPE=13
function FirecrackerController:ctor()
	self:init()
end

function FirecrackerController:init()
	self.freeWinMoney = 0 --免费金额累计
	self.action_array = {} --动作管理集合
	self.betinitMoney = 1 --下注初始金额
	self.maxMoney = 0	--最大限制金额
	self.betMoney = 0	--当前下注金额
	self.betMultiple = 1	--当前下注的倍数
	self.freeCount = 0  --总的免费次数
	self.totalFreeWinMoney = 0 --免费赢的钱
	self.free_bet_money = 0	--免费下注金额
end

function FirecrackerController:isFree()
	return self.freeCount > 0
end

function FirecrackerController:byteRead(data)
	self.betinitMoney = data:readInt()	--下注金额
	self.freeCount = data:readUnsignedByte()	--还有多少次免费次数
	local useFreeCount = data:readUnsignedByte()	--已经使用的免费次数
	self.totalFreeWinMoney = data:readLong()		--免费赢的钱
	self.free_bet_money = data:readInt()		--免费投注金额
	self.betMoney = self.betinitMoney
	self.maxMoney = self.betMoney*10
end

function FirecrackerController:setFreeCount(value)
	self.freeCount = value
end

function FirecrackerController:getFreeCount()
	return self.freeCount
end

function FirecrackerController:addBetMoney()
	if self.betMoney >= self.maxMoney then return end
	self.betMoney = self.betMoney + self.betinitMoney
end

function FirecrackerController:cutdownBetMoney()
	if self.betMoney <= self.betinitMoney then return end
	self.betMoney = self.betMoney - self.betinitMoney
end

function FirecrackerController:getBetMoney()
	return self.betMoney
end

function FirecrackerController:getFreeBetMoney()
	return self.free_bet_money
end

function FirecrackerController:addActionHandler(handler)
	table.insert(self.action_array,handler)
end
function FirecrackerController:cleanActionHandler()
	self.action_array = {}
end

local instance = nil
function FirecrackerController.getInstance()
	if instance == nil then
		instance = FirecrackerController.new()
	end
	return instance
end

return FirecrackerController