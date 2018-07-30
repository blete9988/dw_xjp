--[[
*	红黑大战 游戏管理 类
*	@author lqh
]]

local Hhdz_GameMgr = class("Hhdz_GameMgr")
--单列对象
local instance = nil

function Hhdz_GameMgr:ctor()
	--当前选中的筹码数据结构
	self.currentBet = {}
	--本局下注记录
	self.betRecord = {
		previous = {},
		current = {}
	}
	--当前游戏状态
	self.gamestatus = 0
	--进入房间时的游戏状态
	self.initstatus = 0
	--开牌时间
	self.openStamp = 0
	
	self.resultMgr = require("src.games.hongheidazhan.data.ResultMgr").new()
end

function Hhdz_GameMgr:initgame()
	--注册推送端口
	ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_HHDZ,require("src.games.hongheidazhan.connect.Hhdz_JbackPort").extend())
	--初始化房间数据
	ConnectMgr.connect("src.games.hongheidazhan.connect.Hhdz_RoomDetailedConnect")
end
--是否正在下注中
function Hhdz_GameMgr:isOnBeting()
	return self.gamestatus == ST.TYPE_GAMEHHDZ_ON_BET or self.initstatus == ST.TYPE_GAMEHHDZ_ON_BET
end
--是否能续投
function Hhdz_GameMgr:enbaleContinueBet()
	local record = self.betRecord.previous
	local len = #record
	if len <= 0 then 
		return false
	end
	
	local allcost = 0
	for i = 1,len do
		allcost = allcost + record[i].value
	end
	return Player.gold >= allcost
end
--获取上一局的投注记录
function Hhdz_GameMgr:getBetRecord()
	return self.betRecord.previous
end
--添加下注纪录
function Hhdz_GameMgr:addBetRecord(type,value,pos)
	table.insert(self.betRecord.current,{type = type,value = value,pos = pos})
end
--清除下注记录
function Hhdz_GameMgr:clearBetRecord()
	if next(self.betRecord.current) then
		self.betRecord.previous = {}
		self.betRecord.previous = self.betRecord.current
		self.betRecord.current = {}
	end
end

--设置当前选中的赌注
function Hhdz_GameMgr:setCurrentBet(value,pos)
	self.currentBet.value 	= value
	self.currentBet.pos		= pos
end
--设置房间数据
function Hhdz_GameMgr:setRoom(room)
	self.room = room
end
--初始化游戏 序列化
function Hhdz_GameMgr:initGameBytesRead(data)
	--游戏初始状态
	self.initstatus = data:readByte()
	self.resultMgr:resultListBytesRead(data)
	
	mlog(string.format("进入红黑大战房间， 房间状态 %s ",self.initstatus))
	CommandCenter:sendEvent(ST.COMMAND_GAMEHHDZ_INITROOM)
end
--牌局开始序列化
function Hhdz_GameMgr:beganBytesRead(data)
	self.gamestatus = ST.TYPE_GAMEHHDZ_ON_BET
	self:clearBetRecord()
	self.resultMgr:pushCuurentResultToCache()
	
	--下注倒计时
	self.openStamp = data:readInt()
	
	mlog(string.format("红黑大战开始下注： 倒计时 %s",self.openStamp))
	CommandCenter:sendEvent(ST.COOMAND_GAMEHHDZ_BEGAN)
end
--结果序列化
function Hhdz_GameMgr:resultBytesRead(data)
	self.initstatus = ST.TYPE_GAMEHHDZ_WAIT
	self.gamestatus = ST.TYPE_GAMEHHDZ_WAIT
	
	self.resultMgr:bytesRead(data)
	
	CommandCenter:sendEvent(ST.COOMAND_GAMEHHDZ_OVER)
end
--下注序列化
function Hhdz_GameMgr:betBytesRead(data)
	--进入游戏时已经开始，则抛弃该消息
	if self.initstatus == ST.TYPE_GAMEHHDZ_ON_BET then return end
	
	local betlist = {}
	--每个区域的总下注金额
	local areaAllGolds = {}
	local len = data:readByte()
	local index,value
	for i = 1, len do
		index = data:readByte()
		value = data:readLong()
		areaAllGolds[index] = value
	end
	
	len = data:readShort()
	local playerid = Player.id
	local money,type,id
	for i = 1,len do
		money = data:readInt()
		type = data:readByte()
		id = data:readInt()
		if id ~= playerid then
			if not betlist[type] then
				betlist[type] = {}
			end
			table.insert(betlist[type],money)
		end
	end
	--排序，将大的下注额放前面
	for k,v in pairs(betlist) do
		table.sort(v,function(a,b) 
			return a > b
		end)
	end
	CommandCenter:sendEvent(ST.COOMAND_GAMEHHDZ_BET,{
		betlist = betlist,
		areaAllGolds = areaAllGolds,
	})
end

function Hhdz_GameMgr:destory(noNeedClearRes)
	if not noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
	--移除推送端口
	ConnectMgr.unRegistorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_HHDZ)
	
	self.room = nil
	instance = nil
end

--获取单列
function Hhdz_GameMgr.getInstance()
	if not instance then
		instance = Hhdz_GameMgr.new()
	end
	return instance
end

return Hhdz_GameMgr