--[[
*	金鲨银鲨推送端口
* 
*	@author：gwj
]]
local JinShaYinSha_JbackPort = {}
function JinShaYinSha_JbackPort.extend(data)
	local player = Player
	local dataController = require("src.games.jinshayinsha.data.JinShaYinShaDataController").getInstance()
	local handler = function(data)
		local tp = data:readUnsignedShort()
		mlog(string.format("<JinShaYinSha_JbackPort> receive JBack message , type = %s",tp))
		if tp == 1 then					--开始下注,返回时间
			local gameTime = data:readInt()
			local multipleType = data:readUnsignedByte()
			dataController:betBegin(gameTime,multipleType)
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
			local extraSid = data:readUnsignedByte()	--额外的结果
			print("extraSid ---------------------- "..extraSid)
			local self_winMoney = data:readLong()	--自己的奖金
			print("self_winMoney ---------------------- "..self_winMoney)
			local goldShark_multiple = data:readUnsignedByte()	--金鲨倍数
			print("goldShark_multiple ---------------------- "..goldShark_multiple)
			local handsel_multipe = data:readUnsignedByte()		--彩金倍数
			print("handsel_multipe ---------------------- "..handsel_multipe)
			local lotteryMoney = data:readLong()		--彩金赢钱
			print("lotteryMoney ---------------------- "..lotteryMoney)
			local extraMoney = data:readLong()			--额外转动赢钱
			print("extraMoney ---------------------- "..extraMoney)
			local playMoney = data:readLong()	--玩家新的钱
			print("playMoney ---------------------- "..playMoney)
			Player.setGold(playMoney,true)
			dataController:setResult(winSid,extraSid,self_winMoney,goldShark_multiple,handsel_multipe,lotteryMoney,extraMoney)
		elseif tp == 4 then
			--玩家更新
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
return JinShaYinSha_JbackPort
