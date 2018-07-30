--[[
*	百人牛牛 结果管理
*	@author lqh
]]

local ResultMgr = class("ResultMgr")
--结果结构体
local ResultStruct = class("ResultStruct")

function ResultMgr:ctor()
	self.resultDatas = {}
	--庄家输赢
	self.zhuangGold = 0
	--当前这把我的下注输赢
	self.mineGoldlist = {}
	--当前这把我的总输赢
	self.mineAllGold = 0
	--真实金钱
	self.mineRealGold = 0
	--是否参与
	self.hadin = false
	--当前这把前10玩家
	self.top10 = {}
	--当日数据
	self.dayResult = {
		allRound	= 1,
		heiWinCount	= 1,
		heiLostCount	= 1,
		hongWinCount	= 1,
		hongLostCount	= 1,
		yingWinCount	= 1,
		yingLostCount	= 1,
		fangWinCount	= 1,
		fangLostCount	= 1,
	}
	
	self.groups = {}
	for i = 1,5 do
		self.groups[i] = require("src.games.bairenniuniu.data.PokerGroup").new()
	end
end
function ResultMgr:getGroups()
	return table.merge({},self.groups)
end
function ResultMgr:getCuurentResult()
	return self.resultDatas[#self.resultDatas]
end
function ResultMgr:getResults()
	return table.merge({},self.resultDatas)
end
--记录当天的结果
function ResultMgr:recordDayResult(resultdata)
	self.dayResult.allRound = self.dayResult.allRound + 1
	if resultdata.heiWin then
		self.dayResult.heiWinCount = self.dayResult.heiWinCount + 1
	else
		self.dayResult.heiLostCount = self.dayResult.heiLostCount + 1
	end
	if resultdata.hongWin then
		self.dayResult.hongWinCount = self.dayResult.hongWinCount + 1
	else
		self.dayResult.hongLostCount = self.dayResult.hongLostCount + 1
	end
	if resultdata.yingWin then
		self.dayResult.yingWinCount = self.dayResult.yingWinCount + 1
	else
		self.dayResult.yingLostCount = self.dayResult.yingLostCount + 1
	end
	if resultdata.fangWin then
		self.dayResult.fangWinCount = self.dayResult.fangWinCount + 1
	else
		self.dayResult.fangLostCount = self.dayResult.fangLostCount + 1
	end
end

--序列化每轮结果
function ResultMgr:bytesRead(data)
	for i = 1,5 do
		self.groups[i]:bytesRead(data)
	end
	--当轮结果
	local resultdata = ResultStruct.new(data:readByte())
	self:recordDayResult(resultdata)
	table.insert(self.resultDatas,resultdata)
	
	self.zhuangGold = data:readLong()
	self.hadin = false
	self.mineAllGold = 0
	for i = 1,4 do
		local gold = data:readLong()
		if gold ~= 0 then self.hadin = true end
		self.mineGoldlist[i] = gold
		self.mineAllGold = self.mineAllGold + gold
	end
	
	self.mineRealGold = data:readLong()
	Player.setGold(self.mineRealGold,true)
	mlog(string.format("百人牛牛金币结果，牌面显示金币 %s，真实金币变化 %s",self.mineAllGold,self.mineRealGold - Player.gold))
	self.top10 = {}
	local len = data:readByte()
	for i = 1,len do
		self.top10[i] = require("src.app.data.PlayerInfo").new():briefBytesRead(data)
	end
end

function ResultMgr:resultListBytesRead(data)
	local len = data:readUnsignedByte()
	self.resultDatas 	= {}
	for i = 1,len do
		self.resultDatas[i] = ResultStruct.new(data:readByte())
	end
	
	self.dayResult.allRound 		= data:readShort()
	self.dayResult.heiWinCount 		= data:readShort()
	self.dayResult.heiLostCount 	= data:readShort()
	self.dayResult.hongWinCount 	= data:readShort()
	self.dayResult.hongLostCount 	= data:readShort()
	self.dayResult.yingWinCount	 	= data:readShort()
	self.dayResult.yingLostCount 	= data:readShort()
	self.dayResult.fangWinCount 	= data:readShort()
	self.dayResult.fangLostCount 	= data:readShort()
end

-- ------------------------------class ResultStruct-------------------------------
function ResultStruct:ctor(result)
	self.heiWin = math.band(result,math.pow(2,ST.TYPE_GAMEBRNN_PLAYER_HEI)) ~= 0 
	self.hongWin = math.band(result,math.pow(2,ST.TYPE_GAMEBRNN_PLAYER_HONG)) ~= 0 
	self.yingWin = math.band(result,math.pow(2,ST.TYPE_GAMEBRNN_PLAYER_YING)) ~= 0 
	self.fangWin = math.band(result,math.pow(2,ST.TYPE_GAMEBRNN_PLAYER_FANG)) ~= 0 
end
-- -------------------------------------------------------------------------------
return ResultMgr