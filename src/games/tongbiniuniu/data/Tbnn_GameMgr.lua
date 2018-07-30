--[[
*	通比牛牛游戏管理 类
*	@author lqh
]]

local Tbnn_GameMgr = class("Tbnn_GameMgr")
--单列对象
local instance = nil

function Tbnn_GameMgr:ctor()
	--当前游戏状态
	self.gamestatus = ST.TYPE_GAMETBNN_WAIT
	--房间底注
	self.perBet = 0
	--开牌时间
	self.openStamp = 0
	--彩金池
	self.awardPool = -1
	--我获得的彩金
	self.selfAward = 0
	--当前房间的总战绩
	self.allRecord = 0
	--这一把的战绩
	self.curentRecord = 0
	self.players = {}
end

function Tbnn_GameMgr:initgame()
	--注册推送端口
	ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_TBNN,require("src.games.tongbiniuniu.connect.Tbnn_JbackPort").extend())
	--初始化房间数据
	ConnectMgr.connect("src.games.tongbiniuniu.connect.Tbnn_EntryRoomConnect")
end

--设置房间数据
function Tbnn_GameMgr:setRoom(room)
	self.room = room
end
function Tbnn_GameMgr:isPlaying()
	return self.gamestatus == ST.TYPE_GAMETBNN_PLAYING
end
--自己是否活动彩金
function Tbnn_GameMgr:hadAward()
	if self.awardPool >= 0 and self.selfAward > 0 then
		return true
	end
	return false
end
function Tbnn_GameMgr:getPlayersByResult()
	local newPlayers = self:getPlayers()
	table.sort(newPlayers,function(a,b) 
		return a.resultGold > b.resultGold
	end)
	return newPlayers
end
function Tbnn_GameMgr:getPlayers()
	return table.merge({},self.players)
end
--获取玩家自己的信息
function Tbnn_GameMgr:getMineInfo()
	for k,v in pairs(self.players) do
		if v:isSelf() then 
			return v
		end
	end
	mlog(DEBUG_W,"通比牛牛房间中，没有玩家自己信息!!!!!")
end
--初始化游戏 序列化
function Tbnn_GameMgr:initGameBytesRead(data)
	self.allRecord = 0
	self.curentRecord = 0
	
	self.gamestatus = data:readByte()
	self.openStamp = data:readInt()
	self.awardPool = data:readLong()
	
	self.players = {}
	local len = data:readByte()
	local cls = require("src.games.tongbiniuniu.data.Tbnn_PlayerInfoEx")
	for i = 1,len do
		self.players[i] = cls.new():bytesRead(data)
		if self.gamestatus == ST.TYPE_GAMETBNN_PLAYING then
			--正在牌局中
			self.players[i]:setReadyStatus(ST.TYPE_GAMETBNN_NOT_READY)
			local showdowStatus = data:readByte()
			if showdowStatus == ST.TYPE_GAMETBNN_SHOWDOWN then
				--且已摊牌，序列化牌数据
				self.players[i]:updateShowdownStatus(data)
			end
		end
	end
	
	mlog(string.format("进入通比牛牛房间，房间状态 %s",self.gamestatus))
	CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_ENTRYROOM)
end
--牌局开始序列化
function Tbnn_GameMgr:beganBytesRead(data)
	self.gamestatus = ST.TYPE_GAMETBNN_PLAYING
	self.selfAward = 0
	
	for k,v in pairs(self.players) do
		v:setReadyStatus(ST.TYPE_GAMETBNN_NOT_READY)
	end
	
	self.openStamp = data:readInt()
	self:getMineInfo():pokerBytesRead(data)
	
	CommandCenter:sendEvent(ST.COOMAND_GAMETBNN_BEGAN)
end
--结果序列化
function Tbnn_GameMgr:resultBytesRead(data)
	self.gamestatus = ST.TYPE_GAMETBNN_WAIT
	
	self.selfAward = data:readLong()
	
	local len = data:readByte()
	local index
	for i = 1,len do
		index = data:readByte()
		for k,v in pairs(self.players) do
			if v.index == index then 
				v:resultBytesRead(data)
				if v:isSelf() then
					self.curentRecord = v.resultGold
					self.allRecord = self.allRecord + self.curentRecord
				end
				break
			end
		end
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_RESULT)
end

--有人加入房间
function Tbnn_GameMgr:playerEntryRoom(data)
	local playerInfo = require("src.games.tongbiniuniu.data.Tbnn_PlayerInfoEx").new():bytesRead(data)
	table.insert(self.players,playerInfo)
	CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_PLAYERCHANGE,{type = true,playerInfo = playerInfo})
end

--有人离开房间
function Tbnn_GameMgr:playerLeaveRoom(data)
	local index = data:readByte()
	local id = data:readInt()
	mlog( string.format("<Tbnn_GameMgr>:通比牛牛有玩家离开房间，座位号为 %s ，id为 %s",index,id))
	self:kickPlayer(index,id)
end
function Tbnn_GameMgr:kickPlayer(index,id)
	local playerInfo
	for k,v in pairs(self.players) do
		if v.index == index and v.id == id then
			playerInfo = table.remove(self.players,k)
			break
		end
	end
	
	if playerInfo then
		CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_PLAYERCHANGE,{type = false,playerInfo = playerInfo})
	end
end
--彩金池更新
function Tbnn_GameMgr:updateAwardPool(data)
	self.awardPool = data:readLong()
	
	CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_AWARD_UPDATE)
end
--玩家准备状态改变
function Tbnn_GameMgr:playerReadyStatusUpdate(data)
	local index = data:readByte()
	for k,v in pairs(self.players) do
		if v.index == index then
			v:updateReadyStatus(data)
			break
		end
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_READYSTATUS_UPDATE)
end
--玩家摊牌状态改变
function Tbnn_GameMgr:playerShowdown(data)
	local len = data:readByte()
	local index
	for i = 1,len do
		index = data:readByte()
		for k,v in pairs(self.players) do
			if v.index == index then
				v:updateShowdownStatus(data)
				CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_SHOWDOWN,v)
				break
			end
		end
	end
end


function Tbnn_GameMgr:destory(noNeedClearRes)
	ConnectMgr.connect("gamehall.QuitRoomConnect")
	if not noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
	--移除推送端口
	ConnectMgr.unRegistorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_TBNN)
	
	self.room = nil
	instance = nil
end

--获取单列
function Tbnn_GameMgr.getInstance()
	if not instance then
		instance = Tbnn_GameMgr.new()
	end
	return instance
end

return Tbnn_GameMgr