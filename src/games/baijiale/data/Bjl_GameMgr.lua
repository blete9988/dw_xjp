--[[
*	百家乐游戏管理 类
*	@author lqh
]]

local Bjl_GameMgr = class("Bjl_GameMgr")
--单列对象
local instance = nil

function Bjl_GameMgr:ctor()
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
	--开始时间
	self.beganStamp = 0
	
	--牌局结果管理
	self.resultMgr = require("src.games.baijiale.data.ResultMgr").new()
end

function Bjl_GameMgr:initgame()
	--注册推送端口
	ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_BJL,require("src.games.baijiale.connect.Bjl_JbackPort").extend())
	--初始化房间数据
	ConnectMgr.connect("src.games.baijiale.connect.Bjl_RoomDetailedConnect")
end
--是否能续投
function Bjl_GameMgr:enbaleContinueBet()
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
function Bjl_GameMgr:getBetRecord()
	return self.betRecord.previous
end
--添加下注纪录
function Bjl_GameMgr:addBetRecord(type,value,pos)
	table.insert(self.betRecord.current,{type = type,value = value,pos = pos})
end
--清除下注记录
function Bjl_GameMgr:clearBetRecord()
	if next(self.betRecord.current) then
		self.betRecord.previous = {}
		self.betRecord.previous = self.betRecord.current
		self.betRecord.current = {}
	end
end

--设置当前选中的赌注
function Bjl_GameMgr:setCurrentBet(value,pos)
	self.currentBet.value 	= value
	self.currentBet.pos		= pos
end
--设置房间数据
function Bjl_GameMgr:setRoom(room)
	self.room = room
end
--初始化游戏 序列化
function Bjl_GameMgr:initGameBytesRead(data)
	--时间戳
	local date = data:readInt()
	--游戏初始状态
	self.initstatus = data:readByte()
	
	self.resultMgr:resultListBytesRead(data)
	
	if self.initstatus == ST.TYPE_GAMEBJL_ON_BET then
		self.openStamp = date
	else
		self.beganStamp = date
	end
	
	mlog(string.format("进入百家乐房间， 房间状态 %s，时间戳 %s ",self.initstatus,self.date))
	CommandCenter:sendEvent(ST.COMMAND_GAMEBJL_INITROOM)
end
--牌局开始序列化
function Bjl_GameMgr:beganBytesRead(data)
	self.gamestatus = ST.TYPE_GAMEBJL_ON_BET
	self:clearBetRecord()
	
	--下注倒计时
	local countdown = data:readInt()
	--false为正常开局,true就是牌发完了的开局
	self.isnormal = data:readBoolean()
	if self.isnormal then
		--清除所有数据
		self.resultMgr:clear()
	end
	
	self.openStamp = ServerTimer.time + countdown
	
	mlog(string.format("百家乐开始下注： 倒计时 %s , 状态 %s",countdown,self.isnormal))
	CommandCenter:sendEvent(ST.COOMAND_GAMEBJL_BEGANBET)
end
--结果序列化
function Bjl_GameMgr:resultBytesRead(data)
	self.initstatus = ST.TYPE_GAMEBJL_WAIT
	
	self.gamestatus = ST.TYPE_GAMEBJL_WAIT
	
	--开始时间戳
	self.beganStamp = data:readInt()
	
	self.resultMgr:bytesRead(data)
	
	CommandCenter:sendEvent(ST.COMMAND_GAMEBJL_RESULT)
end
--下注序列化
function Bjl_GameMgr:betBytesRead(data)
	--进入游戏时已经开始，则抛弃该消息
	if self.initstatus == ST.TYPE_GAMEBJL_ON_BET then return end
	
	local betlist = {}
	--每个区域的总下注金额
	local areaAllGolds = {}
	local len = data:readByte()
	for i = 1, len do
		areaAllGolds[data:readByte()] = data:readLong()
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
	
	CommandCenter:sendEvent(ST.COMMAND_GAMEBJL_BET,{
		betlist = betlist,
		areaAllGolds = areaAllGolds,
	})
end

function Bjl_GameMgr:destory(noNeedClearRes)
	if not noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
	--移除推送端口
	ConnectMgr.unRegistorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_BJL)
	
	self.room = nil
	instance = nil
end

--获取单列
function Bjl_GameMgr.getInstance()
	if not instance then
		instance = Bjl_GameMgr.new()
	end
	return instance
end

return Bjl_GameMgr