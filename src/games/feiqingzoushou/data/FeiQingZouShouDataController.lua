--[[--
 * 飞禽走兽数据管理
 * @author GWJ
 * 
]]

local FeiQingZouShouDataController = class("FeiQingZouShouDataController")
local instance = nil
function FeiQingZouShouDataController:ctor()
	self.againBet_array = {}
	self.bets_array = {}
	self.allbetValue = 0
	self.winSid = 0
	self.againData = {}
	for i=1,11 do
		table.insert(self.bets_array,0)
	end
end

function FeiQingZouShouDataController:init(stateTime,state,oldresult,banker_id,banker_name,banker_money,apply_number,is_banker)
	self.stateTime = stateTime - ServerTimer.time
	self.state = state
	self.dropDatas = oldresult
	self.banker_id = banker_id
	self.banker_name = banker_name
	self.banker_money = banker_money
	self.apply_number = apply_number
	self.term_count = 0
	self:setIsbanker(is_banker)
	if #self.dropDatas > 9 then
		local temp_table = {}
		local begin_Index = #self.dropDatas - 8
		for i=begin_Index,#self.dropDatas do
			table.insert(temp_table,self.dropDatas[i])
		end
		self.dropDatas = temp_table
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_UPDATEDROP)
	if self.state == 0 then
		CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_INITWAIT)
	else
		CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_BETBEGIN)
		CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_UPDATEAPPLY)
		CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_UPDATEBANKER,false)
	end
end

function FeiQingZouShouDataController:setIsbanker(value)
	self.is_banker = value
	CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_UPBANKERSTATE)
end

function FeiQingZouShouDataController:updateApply(value)
	self.apply_number = value
	CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_UPDATEAPPLY)
end

function FeiQingZouShouDataController:updateBanker(banker_id,banker_name,banker_money,apply_number,term_count)
	local isChange =  self.banker_id ~= banker_id
	self.banker_id = banker_id
	if isChange then
		self:setIsbanker(self:playerIsBanker())
	end
	self.banker_name = banker_name
	self.banker_money = banker_money
	self.apply_number = apply_number
	self.term_count = term_count
	CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_UPDATEAPPLY)
	CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_UPDATEBANKER,isChange)
end

function FeiQingZouShouDataController:playerIsBanker()
	if Player.id == self.banker_id then return true end
	return false
end

function FeiQingZouShouDataController:addDrop(sid)
	table.insert(self.dropDatas,sid)
	if #self.dropDatas > 9 then
		table.remove(self.dropDatas,1)
	end
	CommandCenter:sendEfent(ST.COMMAND_GAMEFQZS_UPDATEDROP)
end

function FeiQingZouShouDataController:betBegin(gameTime)
	self.state = 1
	self.stateTime = gameTime
	print("self.stateTime----------------"..gameTime)
	CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_BETBEGIN)
end

function FeiQingZouShouDataController:changeMultiple(multiples_money,bet_users)
	self.allbetValue = 0
	for i=1,#multiples_money do
		local temp = multiples_money[i]
		self.bets_array[temp.multipleSid] = temp.money
		self.allbetValue = self.allbetValue + temp.money
	end
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
	CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_BETCHANGE,bet_users)
end

function FeiQingZouShouDataController:setResult(winid,bankerResultMoney,self_winMoney,userdatas)
	self.state = 0
	self.winSid = winid
	self.self_winMoney = self_winMoney
	print("self_winMoney--------------",self.self_winMoney)
	self.bankerResultMoney = bankerResultMoney
	self.userdatas = userdatas
	if #self.againBet_array > 0 then
		self.againData = self.againBet_array
	-- else
	-- 	self.againData = {}
	end
	self.againBet_array = {}
	CommandCenter:sendEvent(ST.COMMAND_GAMEFQZS_BETEND)
end

function FeiQingZouShouDataController:getTime()
	return self.stateTime
end

function FeiQingZouShouDataController:addBet(value,multiplesSid)
	local data = {}
	data.money = value
	data.multiplesSid = multiplesSid
	table.insert(self.againBet_array,data)
end

function FeiQingZouShouDataController:betAgain()
	if #self.againData > 0 then
		for i=1,#self.againData do
			table.insert(self.againBet_array,self.againData[i])
		end
		self.againData = {}
	end
end

function FeiQingZouShouDataController:enbaleContinueBet()
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

function FeiQingZouShouDataController.getInstance()
	if instance == nil then
		instance = FeiQingZouShouDataController.new()
	end
	return instance
end

return FeiQingZouShouDataController