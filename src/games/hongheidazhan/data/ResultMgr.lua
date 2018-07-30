--[[
*	红黑大战 结果管理
*	@author lqh
]]

local ResultMgr = class("ResultMgr")
--结果结构体
local ResultStruct = class("ResultStruct")

function ResultMgr:ctor()
	self.resultDatas = {}
	--当前这把我的总输赢
	self.winGold = 0
	--真实金钱
	self.mineRealGold = 0
	
	self.currentResult = nil
	
	self.groups = {}
	for i = 1,2 do
		self.groups[i] = require("src.games.hongheidazhan.data.PokerGroup").new()
	end
end
function ResultMgr:getGroups()
	return table.merge({},self.groups)
end
function ResultMgr:pushCuurentResultToCache()
	if not self.currentResult then return end
	table.insert(self.resultDatas,self.currentResult)
	self.currentResult = nil
end
function ResultMgr:getCuurentResult()
	return self.currentResult
end
function ResultMgr:getResults()
	return table.merge({},self.resultDatas)
end

--序列化每轮结果
function ResultMgr:bytesRead(data)
	for i = 1,2 do
		self.groups[i]:bytesRead(data)
	end
	
	local resultValue = data:readByte()
	self.winGold = data:readLong()
	self.mineRealGold = data:readLong()
	
	self.currentResult = ResultStruct.new():setResultValue(resultValue)
	if self.currentResult.blackWin then
		self.currentResult:setGroupType(self.groups[1].groupType)
	else
		self.currentResult:setGroupType(self.groups[2].groupType)
	end
	Player.setGold(self.mineRealGold,true)
end

function ResultMgr:resultListBytesRead(data)
	local len = data:readUnsignedByte()
	self.resultDatas 	= {}
	for i = 1,len do
		self.resultDatas[i] = ResultStruct.new():bytesRead(data)
	end
end

-- ------------------------------class ResultStruct-------------------------------
function ResultStruct:ctor()
	self.resultValue = 0
	--胜利牌型
	self.groupType = 4
	
	self.blackWin = false
	self.redWin = false
end
function ResultStruct:setResultValue(value)
	self.resultValue = value
	if math.band(self.resultValue,math.pow(2,ST.TYPE_GAMEHHDZ_BET_BLACK)) ~= 0 then
		self.blackWin = true
		self.redWin = false
	else
		self.blackWin = false
		self.redWin = true
	end
	
	return self
end
function ResultStruct:setGroupType(value)
	self.groupType = value
end
function ResultStruct:isWin(type)
	return math.band(self.resultValue,math.pow(2,type)) ~= 0
end
function ResultStruct:bytesRead(data)
	self.resultValue = data:readByte()
	self.groupType = data:readByte()
	
	self:setResultValue(self.resultValue)
	
	return self
end
-- -------------------------------------------------------------------------------
return ResultMgr