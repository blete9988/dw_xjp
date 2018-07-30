--[[--
 * 金沙银沙数据管理
 * @author GWJ
 * 
]]

local JinShaYinShaDataController = class("JinShaYinShaDataController",require("src.base.event.EventDispatch"))
local instance = nil
-- 1 燕子 2孔雀 3鸽子 4老鹰 5 兔致 6 熊猫 7猴子 8狮子
local MULTIPLE_ARRAY = {
	{3,24,12,24,3,24,12,24},
	{4,12,8,24,4,12,8,24},
	{6,8,8,12,6,8,8,12},
	{6,8,6,24,6,8,6,24},
	{6,12,6,12,6,12,6,12}
}

function JinShaYinShaDataController:ctor()
	self.againBet_array = {}
	self.bets_array = {}
	self.allbetValue = 0
	self.winSid = 0
	self.dropDatas = {5,4,2,3,4,8,7,4,5}
	self.againData = {}
	for i=1,11 do
		table.insert(self.bets_array,0)
	end
end

function JinShaYinShaDataController:init(stateTime,state,oldresult,multipleType)
	self.stateTime = stateTime - ServerTimer.time
	self.state = state
	self.dropDatas = oldresult
	self.multipleType = multipleType + 1
	if #self.dropDatas > 9 then
		local temp_table = {}
		local begin_Index = #self.dropDatas - 8
		for i=begin_Index,#self.dropDatas do
			table.insert(temp_table,self.dropDatas[i])
		end
		self.dropDatas = temp_table
	end

	CommandCenter:sendEvent(ST.COMMAND_GAMEJSYS_UPDATEDROP)
	if self.state == 0 then
		CommandCenter:sendEvent(ST.COMMAND_GAMEJSYS_INITWAIT)
	else
		CommandCenter:sendEvent(ST.COMMAND_GAMEJSYS_BETBEGIN)
	end
end

function JinShaYinShaDataController:getMultipe()
	return MULTIPLE_ARRAY[self.multipleType]
end

function JinShaYinShaDataController:addDrop(sid)
	table.insert(self.dropDatas,sid)
	if #self.dropDatas > 9 then
		table.remove(self.dropDatas,1)
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMEJSYS_UPDATEDROP)
end

function JinShaYinShaDataController:betBegin(gameTime,multipleType)
	self.state = 1
	self.multipleType = multipleType + 1
	self.stateTime = gameTime
	print("betBegin.multipleType------------------",self.multipleType)
	CommandCenter:sendEvent(ST.COMMAND_GAMEJSYS_BETBEGIN)
end

function JinShaYinShaDataController:getBetAllMoney( )
	return self.allbetValue
end

function JinShaYinShaDataController:changeMultiple(multiples_money,bet_users)
	self.allbetValue = 0
	for i=1,#multiples_money do
		local temp = multiples_money[i]
		self.bets_array[temp.multipleSid] = temp.money
		self.allbetValue = self.allbetValue + temp.money
	end
	mlog(self.allbetValue,"!!!!!!!!!!!!!!")
	self:dispatchEvent("SGLB_BETALL_UPDATE")
	

	local isContinue = true
	while(isContinue)
	do
		local isHave = false
		for i=1,#bet_users do
			local temp = bet_users[i]
			if temp.userId == Player.id then
				table.remove(bet_users,i)
				isHave = true
				break
			end
		end
		isContinue = isHave
	end

	if #bet_users > 25 then
		local startIndex = #bet_users - 24
		local temp_array = {}
		for i=startIndex,#bet_users do
			table.inert(temp_array,bet_users[i])
		end
		bet_users = temp_array
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMEJSYS_BETCHANGE,bet_users)
end

function JinShaYinShaDataController:setResult(winid,extraSid,self_winMoney,goldShark_multiple,handsel_multipe,lotteryMoney,extraMoney)
	self.state = 0
	self.winSid = winid
	self.extraSid = extraSid
	self.self_winMoney = self_winMoney
	print("self_winMoney-------------",self_winMoney)
	self.goldShark_multiple = goldShark_multiple
	self.handsel_multipe = handsel_multipe
	self.lotteryMoney = lotteryMoney
	print("self.lotteryMoney-------------",self.lotteryMoney)
	self.extraMoney = extraMoney
	if self.winSid == 10 or self.winSid == 9 then
		local temp = 0
		for i=1,#self.againBet_array do
			if self.againBet_array[i].multiplesSid == self.winSid then
				temp = temp + self.againBet_array[i].money
			end
		end
		if self.winSid == 10 then
			self.sharkMoney = temp * self.goldShark_multiple
		else
			self.sharkMoney = temp * 24
		end
	else
		self.sharkMoney = 0
	end


	if #self.againBet_array > 0 then
		self.againData = self.againBet_array
	-- else
	-- 	self.againData = {}
	end
	self.againBet_array = {}
	CommandCenter:sendEvent(ST.COMMAND_GAMEJSYS_BETEND)
end

function JinShaYinShaDataController:getTime()
	return self.stateTime
end

function JinShaYinShaDataController:addBet(value,multiplesSid)
	local data = {}
	data.money = value
	data.multiplesSid = multiplesSid
	table.insert(self.againBet_array,data)
end

function JinShaYinShaDataController:betAgain()
	if #self.againData > 0 then
		for i=1,#self.againData do
			table.insert(self.againBet_array,self.againData[i])
		end
		self.againData = {}
	end
end

function JinShaYinShaDataController:enbaleContinueBet()
	if #self.againData > 0 then
		local betMoney = 0
		for i=1,#self.againData do
			betMoney = betMoney + self.againData[i].money
		end
		if Player.gold >= betMoney then return true end
		return false
	else
		return false
	end
end

function JinShaYinShaDataController.getInstance()
	if instance == nil then
		instance = JinShaYinShaDataController.new()
	end
	return instance
end

return JinShaYinShaDataController