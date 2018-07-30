--[[--
 * 水果拉霸数据管理
 * @author GWJ
 * 
]]

local ShuiGuoLaBaController = class("ShuiGuoLaBaController",require("src.base.event.EventDispatch"))
local instance = nil
function ShuiGuoLaBaController:ctor()
	self:init()
end

function ShuiGuoLaBaController:init()
	self.bets_array = {}	--下注集合
	self.oldBets_array = {} --上一把下注
	self.allbetValue = 0	--下注总金额
	self.dropDatas = {}		--已经摇奖的结果
	self.maxBetMoney = 100000000	--最大下注金额限制
	for i=1,9 do
		table.insert(self.dropDatas,Command.random(9))
	end
end

function ShuiGuoLaBaController:getBetDatas()
	local result = false
	if #self.oldBets_array > 0 then
		result = self.oldBets_array
	elseif #self.bets_array > 0 then
		result = self.bets_array
	end
	return result
end

function ShuiGuoLaBaController:hasOldData()
	if #self.oldBets_array > 0 then
		return true
	end
	return false
end

function ShuiGuoLaBaController:cleanOldDatas()
	self.oldBets_array = {}
end

function ShuiGuoLaBaController:setMaxBetMoney(value)
	self.maxBetMoney = value
end

function ShuiGuoLaBaController:reset()
	if #self.bets_array > 0 then
		self.oldBets_array = self.bets_array
	end
	self.bets_array = {}
	self:setBetAllValue(0)
end

--添加下注
function ShuiGuoLaBaController:addBetValue(sid,money)
	if #self.oldBets_array > 0 then
		self.oldBets_array = {}
	end
	local multiple_data = {}
	multiple_data.sid = sid 
	multiple_data.money = money
	table.insert(self.bets_array,multiple_data)
	self:setBetAllValue(self.allbetValue + money)
	self.isBetReset = true
end

function ShuiGuoLaBaController:addDropData(sid)
	table.insert(self.dropDatas,sid)
	if #self.dropDatas > 9 then
		table.remove(self.dropDatas,1)
	end
	self:dispatchEvent("SGLB_DROPLIST_UPDATE")
end

function ShuiGuoLaBaController:setBetAllValue(value)
	self.allbetValue = value
	self:dispatchEvent("SGLB_BETALL_UPDATE")
end

--下注之后的剩余金额
function ShuiGuoLaBaController:getSurplusMoney()
	return Player.gold - self.allbetValue
end

function ShuiGuoLaBaController:getBetAllMoney()
	if #self.oldBets_array > 0 then
		local betvalue = 0
		for i=1,#self.oldBets_array do
			betvalue = betvalue + self.oldBets_array[i].money
		end
		print("betvalue-------------------------",betvalue)
		return betvalue
	end
	print("self.allbetValue-------------------------",self.allbetValue)
	return self.allbetValue
end

function ShuiGuoLaBaController.getInstance()
	if instance == nil then
		instance = ShuiGuoLaBaController.new()
	end
	return instance
end

return ShuiGuoLaBaController