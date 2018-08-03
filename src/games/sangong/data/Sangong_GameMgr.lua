--[[
*	三公游戏管理 类
*	@author lqh
]]

local Sangong_GameMgr = class("Sangong_GameMgr")
--单列对象
local instance = nil

function Sangong_GameMgr:ctor()
	--当前游戏状态
	self.gamestatus = ST.TYPE_GAMESANGONG_WAIT
	--游戏开始后子状态
	self.playStatus = ST.TYPE_GAMESANGONG_PLAYSTATUS_MASTER
	--房间底注
	self.perBet = 0
	--开牌时间
	self.openStamp = 0
	--倒计时时间戳
	self.cdStamp = 0
	--当前房间的总战绩
	self.allRecord = 0
	--这一把的战绩
	self.curentRecord = 0
	self.players = {}
end

function Sangong_GameMgr:initgame()
	--注册推送端口
	ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_SANGONG,require("src.games.sangong.connect.Sangong_JbackPort").extend())
	--初始化房间数据
	ConnectMgr.connect("src.games.sangong.connect.Sangong_EntryRoomConnect")
end

function Sangong_GameMgr:removeSangong()
	self._sangongscene:onCleanup()
end

function Sangong_GameMgr:setSangongSelf(sangong_self)
	self._sangongscene = sangong_self
end

--设置房间数据
function Sangong_GameMgr:setRoom(room)
	self.room = room
end
function Sangong_GameMgr:isPlaying()
	return self.gamestatus == ST.TYPE_GAMESANGONG_PLAYING and self.playStatus == ST.TYPE_GAMESANGONG_PLAYSTATUS_PLAYING
end
function Sangong_GameMgr:getPlayers()
	return table.merge({},self.players)
end
--重置所有玩家数据
function Sangong_GameMgr:resetPlayers()
	for k,v in pairs(self.players) do
		v:reset()
	end
end
--通过座位号获取玩家信息
function Sangong_GameMgr:getPlayerByIndex(index)
	for k,v in pairs(self.players) do
		if v.index == index then 
			return v
		end
	end
end
--获取庄家信息
function Sangong_GameMgr:getMaster()
	for k,v in pairs(self.players) do
		if v.masterTimesValue > 0 then 
			return v
		end
	end
	mlog(DEBUG_W,"三公房间中，没有庄家信息!!!!!")
end
--获取玩家自己的信息
function Sangong_GameMgr:getMineInfo()
	for k,v in pairs(self.players) do
		if v:isSelf() then 
			return v
		end
	end
	mlog(DEBUG_W,"三公房间中，没有玩家自己信息!!!!!")
end
--初始化游戏 序列化
function Sangong_GameMgr:initGameBytesRead(data)
	self.allRecord = 0
	self.curentRecord = 0
	
	self.gamestatus = data:readByte()
	self.playStatus = data:readByte()
	
	if self.gamestatus == ST.TYPE_GAMESANGONG_PLAYING and self.playStatus ~= ST.TYPE_GAMESANGONG_PLAYSTATUS_PLAYING then
		self.cdStamp = data:readInt()
	else
		self.openStamp = data:readInt()
	end
	
	self.players = {}
	local len = data:readByte()
	local cls = require("src.games.sangong.data.Sangong_PlayerInfoEx")
	for i = 1,len do
		self.players[i] = cls.new():bytesRead(data)
		if self.gamestatus == ST.TYPE_GAMESANGONG_PLAYING then
			--正在牌局中
			self.players[i]:setReadyStatus(ST.TYPE_GAMESANGONG_NOT_READY)
			local showdowStatus = data:readByte()
			if showdowStatus == ST.TYPE_GAMESANGONG_SHOWDOWN then
				--且已摊牌，序列化牌数据
				self.players[i]:updateShowdownStatus(data)
			end
			
			if self.playStatus ~= ST.TYPE_GAMESANGONG_PLAYSTATUS_MASTER then
				--已抢过庄，设置庄家
				if self.players[i].masterTimesValue > 0 then
					self.players[i]:setMasterTimesValue(self.players[i].masterTimesValue,true)
				end
			end
		end
	end
	
	mlog(string.format("进入三公房间，房间状态 %s",self.gamestatus))
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_ENTRYROOM)
end
--开始抢庄
function Sangong_GameMgr:beganGetMasterBytesRead(data)
	self.gamestatus = ST.TYPE_GAMESANGONG_PLAYING
	self.playStatus = ST.TYPE_GAMESANGONG_PLAYSTATUS_MASTER
	for k,v in pairs(self.players) do
		v:setReadyStatus(ST.TYPE_GAMESANGONG_NOT_READY)
	end
	self.cdStamp = data:readInt()
	
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_BEGAN_GET_MASTER)
end
--抢庄倍数推送
function Sangong_GameMgr:masterTimesBytesRead(data)
	local len = data:readByte()
	local index,id,value,player
	for i = 1, len do
		id = data:readInt()
		index = data:readByte()
		value = data:readByte()
		local player = self:getPlayerByIndex(index)
		if player and player.id == id then
			player:setMasterTimesValue(value)
		end
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_MASTER_VALUE)
end
--开始加倍
function Sangong_GameMgr:beganAddTimesBytesRead(data)
	self.playStatus = ST.TYPE_GAMESANGONG_PLAYSTATUS_ADDTIMES
	self.cdStamp = data:readInt()
	
	local id = data:readInt()
	local index = data:readByte()
	local value = data:readByte()
	for k,player in pairs(self.players) do
		if player.index ~= index then
			player:clearMasterTimesValue()
		elseif player.id == id then
			player:setMasterTimesValue(value,true)
		end
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_BEGAN_ADD_TIMES)
end
--加倍倍数推送
function Sangong_GameMgr:addTimesBytesRead(data)
	local len = data:readByte()
	local index,id,value,player
	for i = 1, len do
		id = data:readInt()
		index = data:readByte()
		value = data:readByte()
		local player = self:getPlayerByIndex(index)
		if player and player.id == id then
			player:setAddTimesValue(value)
		end
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_TIMES_VALUE)
end
--牌局开始序列化
function Sangong_GameMgr:beganBytesRead(data)
	self.playStatus = ST.TYPE_GAMESANGONG_PLAYSTATUS_PLAYING
	
	self.openStamp = data:readInt()
	self:getMineInfo():pokerBytesRead(data)
	
	CommandCenter:sendEvent(ST.COOMAND_GAMESANGONG_BEGAN)
end
--结果序列化
function Sangong_GameMgr:resultBytesRead(data)
	self.gamestatus = ST.TYPE_GAMESANGONG_WAIT
	
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
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_RESULT)
end

--有人加入房间
function Sangong_GameMgr:playerEntryRoom(data)
	local playerInfo = require("src.games.sangong.data.Sangong_PlayerInfoEx").new():bytesRead(data)
	table.insert(self.players,playerInfo)
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_PLAYERCHANGE,{type = true,playerInfo = playerInfo})
end

--有人离开房间
function Sangong_GameMgr:playerLeaveRoom(data)
	local index = data:readByte()
	local id = data:readInt()
	mlog( string.format("<Sangong_GameMgr>:三公有玩家离开房间，座位号为 %s ，id为 %s",index,id))
	self:kickPlayer(index,id)
end
function Sangong_GameMgr:kickPlayer(index,id)
	local playerInfo
	for k,v in pairs(self.players) do
		if v.index == index and v.id == id then
			playerInfo = table.remove(self.players,k)
			break
		end
	end
	
	if playerInfo then
		CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_PLAYERCHANGE,{type = false,playerInfo = playerInfo})
	end
end
--玩家准备状态改变
function Sangong_GameMgr:playerReadyStatusUpdate(data)
	local index = data:readByte()
	for k,v in pairs(self.players) do
		if v.index == index then
			v:updateReadyStatus(data)
			break
		end
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_READYSTATUS_UPDATE)
end
--玩家摊牌状态改变
function Sangong_GameMgr:playerShowdown(data)
	local len = data:readByte()
	local index
	for i = 1,len do
		index = data:readByte()
		for k,v in pairs(self.players) do
			if v.index == index then
				v:updateShowdownStatus(data)
				CommandCenter:sendEvent(ST.COMMAND_GAMESANGONG_SHOWDOWN,v)
				break
			end
		end
	end
end


function Sangong_GameMgr:destory(noNeedClearRes)
	ConnectMgr.connect("gamehall.QuitRoomConnect")
	if not noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
	--移除推送端口
	ConnectMgr.unRegistorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_SANGONG)
	
	self.room = nil
	instance = nil
end

--获取单列
function Sangong_GameMgr.getInstance()
	if not instance then
		instance = Sangong_GameMgr.new()
	end
	return instance
end

return Sangong_GameMgr