--[[
*	百人牛牛游戏管理 类
*	@author lqh
]]

local Brnn_GameMgr = class("Brnn_GameMgr")
--单列对象
local instance = nil

function Brnn_GameMgr:ctor()
	--当前选中的筹码数据结构
	self.currentBet = {}
	--本局下注记录
	self.betRecord = {
		previous = {},
		current = {}
	}
	--当前游戏状态
	self.gamestatus = 0
	--开牌时间
	self.openStamp = 0
	--开始时间
	self.beganStamp = 0
	--进入房间时的游戏状态
	self.initstatus = 0
	--前一个庄家id
	self.previousMasterID = 0
	--是否已申请上庄
	self.alreadyApply = false
	--上庄最低金币限制
	self.masterGoldLimit = 0
	--当局下注的总额度
	self.betLimit = 0
	--上庄申请人数
	self.applyNum = 0
	--庄家
	self.master = require("src.app.data.PlayerInfo").new()
	--连庄次数
	self.continueCount = 0
	--桌面显示的4个玩家
	self.desktopPlayers = {}
	
	--牌局结果管理
	self.resultMgr = require("src.games.bairenniuniu.data.ResultMgr").new()
end

function Brnn_GameMgr:initgame()
	--注册推送端口
	ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_BRNN,require("src.games.bairenniuniu.connect.Brnn_JbackPort").extend())
	--初始化房间数据
	ConnectMgr.connect("src.games.bairenniuniu.connect.Brnn_RoomDetailedConnect")
end
--检查是否能申请上庄
function Brnn_GameMgr:checkApplyMaster()
	if self.alreadyApply or self.master.id == Player.id then
		return false
	else
		return true
	end
end
--自己是否是庄家
function Brnn_GameMgr:isMaster()
	return self.master:isSelf()
end
--是否正在下注中
function Brnn_GameMgr:isOnBeting()
	return self.gamestatus == ST.TYPE_GAMEBRNN_ON_BET or self.initstatus == ST.TYPE_GAMEBRNN_ON_BET
end
--设置是否已经申请上庄
function Brnn_GameMgr:setAlreadyApply(bool)
	self.alreadyApply = bool
end
--是否能续投
function Brnn_GameMgr:enbaleContinueBet()
	local record = self.betRecord.previous
	local len = #record
	if len <= 0 then 
		return false
	end
	
	local allcost = 0
	for i = 1,len do
		allcost = allcost + record[i].value
	end
	return Player.gold*0.1 >= allcost
end
--获取上一局的投注记录
function Brnn_GameMgr:getBetRecord()
	return self.betRecord.previous
end
--添加下注纪录
function Brnn_GameMgr:addBetRecord(type,value,pos)
	table.insert(self.betRecord.current,{type = type,value = value,pos = pos})
end
--清除下注记录
function Brnn_GameMgr:clearBetRecord()
	if next(self.betRecord.current) then
		self.betRecord.previous = {}
		self.betRecord.previous = self.betRecord.current
		self.betRecord.current = {}
	end
end

--设置当前选中的赌注
function Brnn_GameMgr:setCurrentBet(value,pos)
	self.currentBet.value 	= value
	self.currentBet.pos		= pos
end
--设置房间数据
function Brnn_GameMgr:setRoom(room)
	self.room = room
end
--初始化游戏 序列化
function Brnn_GameMgr:initGameBytesRead(data)
	--时间戳
	local date = data:readInt()
	--游戏初始状态
	self.initstatus = data:readByte()
	self.masterGoldLimit = data:readLong()
	self.applyNum = data:readByte()
	--是否已申请上庄
	self.alreadyApply = data:readBoolean()
	
	self.resultMgr:resultListBytesRead(data)
	
	self.master:bytesRead(data)
	
	if self.master:isSelf() then
		self:setAlreadyApply(false)
	end
	self:desktopPlayersBytesRead(data)
	
	if self.initstatus == ST.TYPE_GAMEBRNN_ON_BET then
		self.openStamp = date
	else
		self.beganStamp = date
	end
	
	mlog(string.format("进入百人牛牛房间， 房间状态 %s，时间戳 %s ",self.initstatus,self.date))
	CommandCenter:sendEvent(ST.COMMAND_GAMEBRNN_INITROOM)
end
--上庄申请人数序列化
function Brnn_GameMgr:applyNumberBytesRead(data)
	self.applyNum = data:readByte()
	
	CommandCenter:sendEvent(ST.COMMAND_GAMEBRNN_APPLYNUM_UPDATE)
end
--庄家轮换序列化
function Brnn_GameMgr:masterUpdateBytesRead(data)
	self.previousMasterID = self.master.id
	self.master:bytesRead(data)
	if self.master:isSelf() then
		self:setAlreadyApply(false)
	end
	self.betLimit = data:readLong()
	self.continueCount = data:readUnsignedByte()
	
	CommandCenter:sendEvent(ST.COMMAND_GAMEBRNN_MASTER_UPDATE)
end
--牌局开始序列化
function Brnn_GameMgr:beganBytesRead(data)
	self.gamestatus = ST.TYPE_GAMEBRNN_ON_BET
	self:clearBetRecord()
	
	--下注倒计时
	local countdown = data:readInt()
	self.applyNum = data:readByte()
	
	self.openStamp = ServerTimer.time + countdown
	
	mlog(string.format("百人牛牛开始下注： 倒计时 %s",countdown))
	CommandCenter:sendEvent(ST.COOMAND_GAMEBRNN_BEGANBET)
end
--结果序列化
function Brnn_GameMgr:resultBytesRead(data)
	self.initstatus = ST.TYPE_GAMEBRNN_WAIT
	self.gamestatus = ST.TYPE_GAMEBRNN_WAIT
	
	self.master:bytesRead(data)
	if self.master:isSelf() then
		self:setAlreadyApply(false)
	end
	self.applyNum = data:readByte()
	
	--开始时间戳
	self.beganStamp = data:readInt()
	
	self.resultMgr:bytesRead(data)
	
	CommandCenter:sendEvent(ST.COMMAND_GAMEBRNN_RESULT)
end
--下注序列化
function Brnn_GameMgr:betBytesRead(data)
	--进入游戏时已经开始，则抛弃该消息
	if self.initstatus == ST.TYPE_GAMEBRNN_ON_BET then return end
	
	local betlist = {}
	--每个区域的总下注金额
	local areaAllGolds = {}
	local len = data:readByte()
	local index,value
	local tempall = 0
	for i = 1, len do
		index = data:readByte()
		value = data:readLong()
		tempall = tempall + value
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
	CommandCenter:sendEvent(ST.COMMAND_GAMEBRNN_BET,{
		betlist = betlist,
		areaAllGolds = areaAllGolds,
	})
end
--桌面玩家更新
function Brnn_GameMgr:desktopPlayersBytesRead(data)
	local len = data:readByte()
	self.desktopPlayers = {}
	for i = 1,len do
		self.desktopPlayers[i] = require("src.app.data.PlayerInfo").new():bytesRead(data)
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMEBRNN_DESKTOPPLAYERS_UPDATE)
end

function Brnn_GameMgr:destory(noNeedClearRes)
	if not noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
	--移除推送端口
	ConnectMgr.unRegistorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_BRNN)
	
	self.room = nil
	instance = nil
end

--获取单列
function Brnn_GameMgr.getInstance()
	if not instance then
		instance = Brnn_GameMgr.new()
	end
	return instance
end

return Brnn_GameMgr