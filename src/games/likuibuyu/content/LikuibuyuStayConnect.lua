--[[
*	李逵捕鱼初始化
*	端口号：1205
]]
local LikuibuyuStayConnect = class("LikuibuyuStayConnect",BaseConnect)

local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")
local cmd = "src.games.likuibuyu.content.models.CMD_LKGame"
local g_var = ExternalFun.req_var

LikuibuyuStayConnect.port = Port.PORT_LIKUIBUYU
LikuibuyuStayConnect.type = cmd.SUB_S_STAY_FISH

function LikuibuyuStayConnect:ctor(callback)
	self.callback = callback
end

function LikuibuyuStayConnect:writeData(data)
end

function LikuibuyuStayConnect:readData(data)
	mlog("李逵捕鱼停留鱼120收到数据返回！")

	-- local result = data:readUnsignedByte()
	-- if result ~= 0 then
	-- 	self:showTips(result)
	-- 	self.params = false
	-- else
	-- 	local betinitMoney = data:readInt()	--下注金额
	-- 	local surplusFreeCount = data:readUnsignedByte()	--还有多少次免费次数
	-- 	local useFreeCount = data:readUnsignedByte()	--已经使用的免费次数
	-- 	local totalFreeWinMoney = data:readLong()		--免费赢的钱
	-- 	local free_bet_money = data:readInt()		--免费投注金额
	-- 	local free_multiple = data:readUnsignedByte()	--免费倍数
	-- 	local controller = require("src.games.baodaren.data.BaoDaRenController").getInstance()
	-- 	controller:updateMaxFreeCount(useFreeCount + surplusFreeCount)
	-- 	controller:updateFreeCount(useFreeCount)
	-- 	controller:setTotalFreeWinMoney(totalFreeWinMoney)
	-- 	controller:setBetinitMoney(betinitMoney)
	-- 	controller:updateFreeBetMoney(free_bet_money)
	-- 	controller:updateFreeMultiple(free_multiple)
	-- 	self.params = true
	-- end
end

return LikuibuyuStayConnect