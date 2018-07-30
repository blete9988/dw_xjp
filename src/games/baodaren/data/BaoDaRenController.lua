--[[--
 * 包大人数据管理
 * @author GWJ
 * 
]]

local BaoDaRenController = class("BaoDaRenController",require("src.base.event.EventDispatch"))
local instance = nil
-- datas
function BaoDaRenController:ctor()
	self:init()
end

function BaoDaRenController:init()
	self.freeWinMoney = 0 --免费金额累计
	self.action_array = {} --动作管理集合
	self.betinitMoney = 0 --下注初始金额
	self.maxMoney = 0	--最大限制金额
	self.betMoney = 0	--当前下注金额
	self.betMultiple = 1	--当前下注的倍数
	self.freeCountNow = 0	--当前免费次数
	self.maxFreeCount = 0 --总的免费次数
	self.totalFreeWinMoney = 0 --免费赢的钱
	self.free_bet_money = 0	--免费投注金额
	self.free_multiple = 0	--免费倍数
	self:removeAllEventListeners()
end

--是否处于免费状态
function BaoDaRenController:isFree()
	if self.maxFreeCount >= self.freeCountNow and self.maxFreeCount > 0 then
		return true
	else
		return false
	end
end

function BaoDaRenController:setTotalFreeWinMoney(value)
	self.totalFreeWinMoney = value
end

function BaoDaRenController:setBetinitMoney(value)
	self.betinitMoney = value
	self.betMoney = self.betinitMoney
	self.maxMoney = self.betinitMoney * 10
end

function BaoDaRenController:setBetMultiple(value)
	self.betMultiple = value
end

function BaoDaRenController:addBetMoney()
	if self.betMoney >= self.maxMoney then return end
	self.betMoney = self.betMoney + self.betinitMoney
end

function BaoDaRenController:getBetMoney()
	return self.betMoney * self.betMultiple
end

function BaoDaRenController:cutdownBetMoney()
	if self.betMoney <= self.betinitMoney then return end
	self.betMoney = self.betMoney - self.betinitMoney
end

function BaoDaRenController:addActionHandler(handler)
	table.insert(self.action_array,handler)
end

function BaoDaRenController:cleanActionHandler()
	self.action_array = {}
end
function BaoDaRenController:updateFreeCount(value)
	print("freeCount-------------------",value)
	self.freeCountNow = value
end

function BaoDaRenController:sendFreeState()
	self:dispatchEvent("BDR_CONTROLLER_FREE_STATE")
end

function BaoDaRenController:sendNormalState()
	self:dispatchEvent("BDR_CONTROLLER_NORMAL_STATE")
end

function BaoDaRenController:updateMaxFreeCount(value)
	print("MaxfreeCount-------------------",value)
	self.maxFreeCount = value
end

function BaoDaRenController:updateFreeBetMoney(value)
	self.free_bet_money = value
end

function BaoDaRenController:updateFreeMultiple(value)
	self.free_multiple = value
end

function BaoDaRenController:addFreeWinMoney(value)
	self.freeWinMoney = self.freeWinMoney + value
end

function BaoDaRenController.getInstance()
	if instance == nil then
		instance = BaoDaRenController.new()
	end
	return instance
end

return BaoDaRenController