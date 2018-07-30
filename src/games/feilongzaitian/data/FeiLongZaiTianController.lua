--[[--
 * 飞龙在天数据
 * @author GWJ
 * 
]]

local FeiLongZaiTianController = class("FeiLongZaiTianController")
local instance = nil
-- datas
function FeiLongZaiTianController:ctor()
	self:init()
end

function FeiLongZaiTianController:init()
	self.freeWinMoney = 0 --免费金额累计
	self.action_array = {} --动作管理集合
	self.betinitMoney = 0 --下注初始金额
	self.maxMoney = 0	--最大限制金额
	self.betMoney = 0	--当前下注金额
	self.betMultiple = 1	--当前下注的倍数
	self.freeCountNow = 0	--当前免费次数
	self.maxFreeCount = 0 --总的免费次数
	self.totalFreeWinMoney = 0 --免费赢的钱
	self.free_bet_money = 0	--免费下注金额
	self.dragon_ball = 0	--龙珠数量
end

--是否处于免费状态
function FeiLongZaiTianController:isFree()
	if self.maxFreeCount >= self.freeCountNow and self.maxFreeCount > 0 then
		return true
	else
		return false
	end
end

function FeiLongZaiTianController:setTotalFreeWinMoney(value)
	self.totalFreeWinMoney = value
end

function FeiLongZaiTianController:setBetinitMoney(value)
	self.betinitMoney = value
	self.betMoney = self.betinitMoney
	self.maxMoney = self.betinitMoney * 10
end

function FeiLongZaiTianController:setBetMultiple(value)
	self.betMultiple = value
end

function FeiLongZaiTianController:addBetMoney()
	if self.betMoney >= self.maxMoney then return end
	self.betMoney = self.betMoney + self.betinitMoney
end

function FeiLongZaiTianController:getBetMoney()
	return self.betMoney * self.betMultiple
end

function FeiLongZaiTianController:cutdownBetMoney()
	if self.betMoney <= self.betinitMoney then return end
	self.betMoney = self.betMoney - self.betinitMoney
end

function FeiLongZaiTianController:addActionHandler(handler)
	table.insert(self.action_array,handler)
end

function FeiLongZaiTianController:cleanActionHandler()
	self.action_array = {}
end

function FeiLongZaiTianController:updateFreeBetMoney(value)
	self.free_bet_money = value
end

function FeiLongZaiTianController:updateFreeCount(value)
	print("freeCount-------------------",value)
	self.freeCountNow = value
end

function FeiLongZaiTianController:updateMaxFreeCount(value)
	print("MaxfreeCount-------------------",value)
	self.maxFreeCount = value
end

function FeiLongZaiTianController:updateDragonBall(value)
	self.dragon_ball = value
end

function FeiLongZaiTianController:addFreeWinMoney(value)
	self.freeWinMoney = self.freeWinMoney + value
end

function FeiLongZaiTianController.getInstance()
	if instance == nil then
		instance = FeiLongZaiTianController.new()
	end
	return instance
end

return FeiLongZaiTianController