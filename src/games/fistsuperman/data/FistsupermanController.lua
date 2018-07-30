--[[--
 * 一拳超人数据
 * @author GWJ
 * 
]]

local FistsupermanController = class("FistsupermanController",require("src.base.event.EventDispatch"))
local instance = nil
-- datas
function FistsupermanController:ctor()
	self:init()
end

function FistsupermanController:init()
	self.freeWinMoney = 0 --免费金额累计
	self.action_array = {} --动作管理集合
	self.betinitMoney = 0 --下注初始金额
	self.maxMoney = 0	--最大限制金额
	self.betMoney = 0	--当前下注金额
	self.betMultiple = 1	--当前下注的倍数
	self.freeCountNow = 0	--当前免费次数
	self.maxFreeCount = 0 --总的免费次数
	self.totalFreeWinMoney = 0 --免费赢的钱
	self.free_bet_money = 0
	self:removeAllEventListeners()
end

--是否处于免费状态
function FistsupermanController:isFree()
	if self.maxFreeCount >= self.freeCountNow and self.maxFreeCount > 0 then
		return true
	else
		return false
	end
end

function FistsupermanController:sendFreeState()
	self:dispatchEvent("YQCR_CONTROLLER_FREE_STATE")
end

function FistsupermanController:sendNormalState()
	self:dispatchEvent("YQCR_CONTROLLER_NORMAL_STATE")
end

function FistsupermanController:setTotalFreeWinMoney(value)
	self.totalFreeWinMoney = value
end

function FistsupermanController:setBetinitMoney(value)
	self.betinitMoney = value
	self.betMoney = self.betinitMoney
	self.maxMoney = self.betinitMoney * 10
end

function FistsupermanController:setBetMultiple(value)
	self.betMultiple = value
end

function FistsupermanController:addBetMoney()
	if self.betMoney >= self.maxMoney then return end
	self.betMoney = self.betMoney + self.betinitMoney
end

function FistsupermanController:getBetMoney()
	return self.betMoney * self.betMultiple
end

function FistsupermanController:cutdownBetMoney()
	if self.betMoney <= self.betinitMoney then return end
	self.betMoney = self.betMoney - self.betinitMoney
end

function FistsupermanController:addActionHandler(handler)
	table.insert(self.action_array,handler)
end

function FistsupermanController:cleanActionHandler()
	self.action_array = {}
end

function FistsupermanController:updateFreeBetMoney(value)
	self.free_bet_money = value
end

function FistsupermanController:updateFreeCount(value)
	print("freeCount-------------------",value)
	self.freeCountNow = value
end

function FistsupermanController:updateMaxFreeCount(value)
	print("MaxfreeCount-------------------",value)
	self.maxFreeCount = value
end

function FistsupermanController:addFreeWinMoney(value)
	self.freeWinMoney = self.freeWinMoney + value
end

function FistsupermanController.getInstance()
	if instance == nil then
		instance = FistsupermanController.new()
	end
	return instance
end

return FistsupermanController