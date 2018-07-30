--[[
*	百家乐 结果管理
*	@author lqh
]]

local ResultMgr = class("ResultMgr")
--结果结构体
local ResultStruct = class("ResultStruct")

function ResultMgr:ctor(config)
	self.index = 1
	self.round = 1
	--闲家手牌
	self.player1_handler = {}
	--庄家手牌
	self.player2_handler = {}
	--所有结果结合
	self.resultList = {}
	self.resultDatas = {}
	--本局输赢
	self.winGold = 0
	--赢钱榜
	self.winLeaderBroad = {}
end
--获取当前局数
function ResultMgr:geInnings()
	return #self.resultList + 1
end
--获取所有的结果数据结构
function ResultMgr:getResultDatas()
	return table.merge({},self.resultDatas)
end
--获取最后一次结果数据结构
function ResultMgr:getLastResultData()
	return self.resultDatas[#self.resultDatas]
end
--获取一张手牌
function ResultMgr:getHandCard()
	local index = self.index
	
	local poker 
	if index%2 == 1 then
		poker = self.player1_handler[math.ceil(index/2)]
	else
		poker = self.player2_handler[math.ceil(index/2)]
	end
	
	return poker
end
function ResultMgr:goNext()
	self.index = self.index + 1
end
--进入下一轮
function ResultMgr:nextRound()
	self:goNext()
	self.round = self.round + 1
end
--获取当轮手牌总点数
function ResultMgr:getCardPoint(playerIndex)
	local handcards = self.player1_handler
	if playerIndex == 1 then
		handcards = self.player2_handler
	end
	
	local len = 2
	if self.round == 2 then len = 3 end
	if len > #handcards then len = #handcards end
	
	local point = 0
	for i = 1,len do
		point = point + handcards[i]:getPoint()
	end
	return point%10
end

--判断结果
function ResultMgr:judgeResult(type,resulttype --[[=nil]])
	resulttype = resulttype or self.currentResult
	if math.band(resulttype,math.pow(2,type)) ~= 0 then
		--是该结果
		return true
	end
	return false
end
--序列化每轮结果
function ResultMgr:bytesRead(data)
	--当轮结果
	self.currentResult = data:readInt()
	table.insert(self.resultList,self.currentResult)
	local len = #self.resultDatas
	if len > 0 then
		self.resultDatas[len]:isLast(false)
	end
	self.resultDatas[len + 1] = ResultStruct.new(self.currentResult)
	self.resultDatas[len + 1]:isLast(true)
	
	self.index,self.round = 1,1
	self.player1_handler,self.player2_handler = {},{}
	
	local sid 
	for i = 1,3 do
		sid = data:readUnsignedShort()
		if sid ~= 0 then
			self.player1_handler[i] = require("src.games.baijiale.data.PokerData").new(sid,i)
		end
	end
	
	for i = 1,3 do
		sid = data:readUnsignedShort()
		if sid ~= 0 then
			self.player2_handler[i] = require("src.games.baijiale.data.PokerData").new(sid,i)
		end
	end
	
	self.winGold = data:readLong()
	Player.setGold(data:readLong(),true)
	
	local len = data:readByte()
	local id,playerinfo
	self.winLeaderBroad = {}
	for i = 1,len do
		id = data:readInt()
		if id ~= 0 then
			playerinfo = require("src.app.data.PlayerInfo").new()
			playerinfo:setBriefInfo(id,data:readString(),data:readLong())
			table.insert(self.winLeaderBroad,playerinfo)
		end
	end
end

function ResultMgr:resultListBytesRead(data)
	local len = data:readUnsignedByte()
	self.resultList 	= {}
	self.resultDatas 	= {}
	for i = 1,len do
		self.resultList[i] = data:readInt()
		self.resultDatas[i] = ResultStruct.new(self.resultList[i])
		if i == len then
			self.resultDatas[i]:isLast(true)
		end
	end
end

function ResultMgr:clear()
	self.resultList = {}
	self.resultDatas = {}
end
-- ------------------------------class ResultStruct-------------------------------
function ResultStruct:ctor(result)
	--结果组合数值
	self.resultValue 	= result
	--庄赢
	self.zhuangWin 		= false
	--闲赢
	self.xianWin 		= false
	--平
	self.ping			= false
	--庄平
	self.zhuangDouble	= false
	--闲平
	self.xianDouble		= false
	--庄天王
	self.zhuangKing		= false
	--闲天王
	self.xianKing		= false
	
	self.islast			= false
	if ResultMgr:judgeResult(ST.TYPE_GAMEBJL_RESULT_7,result) then
		--庄赢
		self.zhuangWin 	= true
	elseif ResultMgr:judgeResult(ST.TYPE_GAMEBJL_RESULT_6,result) then
		--闲赢
		self.xianWin 	= true
	else
		--平
		self.ping		= true
	end
	
	--庄天王
	self.zhuangKing		= ResultMgr:judgeResult(ST.TYPE_GAMEBJL_RESULT_5,result)
	--闲天王
	self.xianKing		= ResultMgr:judgeResult(ST.TYPE_GAMEBJL_RESULT_4,result)
	--庄对
	self.zhuangDouble	= ResultMgr:judgeResult(ST.TYPE_GAMEBJL_RESULT_3,result)
	--闲对
	self.xianDouble		= ResultMgr:judgeResult(ST.TYPE_GAMEBJL_RESULT_2,result)
end
function ResultStruct:isLast(bool)
	if self.islast == bool then return end
	self.islast = bool
	if self.display then
		self.display:setShining(bool)
	end
end
function ResultStruct:setDisplay(target)
	self.display = target
end
-- -------------------------------------------------------------------------------
return ResultMgr