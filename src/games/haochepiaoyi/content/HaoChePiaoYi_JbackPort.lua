--[[
*	豪车漂移推送端口
* 
*	@author：gwj
]]
local HaoChePiaoYi_JbackPort = {}
function HaoChePiaoYi_JbackPort.extend(data)
	local player = Player
	local dataController = require("src.games.haochepiaoyi.data.HaoChePiaoYiDataController").getInstance()
	local handler = function(data)
		local tp = data:readUnsignedShort()
		mlog(string.format("<HaoChePiaoYi_JbackPort> receive JBack message , type = %s",tp))
		if tp == 1 then					--开始下注,返回时间
			local gameTime = data:readInt()
			local banker_id = data:readInt()
			local banker_name = data:readString()
			local banker_moeney = data:readLong()
			print("banker_name------------------------------------",banker_name)
			print("banker_moeney------------------------------------",banker_moeney)
			local apply_number = data:readUnsignedByte()
			local term_count = data:readUnsignedByte()
			dataController:updateBanker(banker_id,banker_name,banker_moeney,apply_number,term_count)
			dataController:betBegin(gameTime)
		elseif tp == 2 then				--下注数据
			local multiples_money = {}
			local length = data:readUnsignedByte()
			for i=1,length do
				local model = {}
				model.multipleSid = data:readUnsignedByte()
				model.money = data:readLong()
				table.insert(multiples_money,model)
			end
			local bet_users = {}
			length = data:readUnsignedShort()
			for i=1,length do
				local model = {}
				model.money = data:readInt()
				model.multipleSid = data:readUnsignedByte()
				model.userId = data:readInt()
				table.insert(bet_users,model)
			end
			dataController:changeMultiple(multiples_money,bet_users)
		elseif tp == 3 then            --推送结果
			local gameTime = data:readInt()			--下轮开始下注的时间
			local winSid = data:readUnsignedByte()	--结果的SID
			local bankerResultMoney = data:readLong()	--庄家输赢金额
			local self_winMoney = data:readLong()			--自己的输赢
			local playMoney = data:readLong()	--玩家新的钱
			print("playMoney------------------------",playMoney)
			Player.setGold(playMoney,true)
			local length = data:readUnsignedByte()
			local userdatas = {}
			for i=1,length do
				local userid = data:readInt()
				if userid > 0 then
					local model = {}
					model.id = userid
					model.name = data:readString()
					model.userResultMoney = data:readLong()
					table.insert(userdatas,model)
				end
			end
			dataController:setResult(winSid,bankerResultMoney,self_winMoney,userdatas)
		elseif tp == 4 then
			local apply_number = data:readUnsignedByte() --庄家等待人数改变
			dataController:updateApply(apply_number)
		elseif tp == 5 then
			--庄家轮换
		elseif tp == 6 then
			--庄家被下庄
		elseif tp == 7 then
			--本局结束
		end
	end
	return handler
end
return HaoChePiaoYi_JbackPort
