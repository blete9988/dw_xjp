--[[
*	三公 游戏玩家
*	@author lqh
]]

local Sangong_PlayerInfoEx = class("Sangong_PlayerInfoEx",require("src.app.data.PlayerInfo"))

function Sangong_PlayerInfoEx:ctor()
	self:super("ctor")
	self.pokerGroup = require("src.games.qiangzhuangniuniu.data.PokerGroup").new()
	self.index = 1
	self.resultGold = 0
	--抢庄倍数
	self.masterTimesValue = -1
	--加倍倍数
	self.addTimesValue = -1
	self.ismaster = false
	
	self.readyStatus = ST.TYPE_GAMESANGONG_NOT_READY
	self.showdownStatus = ST.TYPE_GAMESANGONG_NOT_SHOWDOWN
	--玩家在前端显示的位置
	self.clientIndex = 0
end
--设置在前端的显示位置
function Sangong_PlayerInfoEx:setClientIndex(index)
	self.clientIndex = index
end
--清除抢庄倍数
function Sangong_PlayerInfoEx:clearMasterTimesValue()
	self.masterTimesValue = -1
end
--设置抢庄倍数
function Sangong_PlayerInfoEx:setMasterTimesValue(value,ismaster --[[=false]])
	self.masterTimesValue = value
	self.ismaster = tobool(ismaster)
end

--设置加倍倍数
function Sangong_PlayerInfoEx:setAddTimesValue(value)
	self.addTimesValue = value
end
--是否已摊牌
function Sangong_PlayerInfoEx:isShowdown()
	return self.showdownStatus == ST.TYPE_GAMESANGONG_SHOWDOWN
end
--是否已准备
function Sangong_PlayerInfoEx:isReady()
	return self.readyStatus == ST.TYPE_GAMESANGONG_READY
end
function Sangong_PlayerInfoEx:isWinner()
	return self.resultGold > 0
end
function Sangong_PlayerInfoEx:setReadyStatus(value)
	self.readyStatus = value
end
function Sangong_PlayerInfoEx:setShowdownStatus(value)
	self.showdownStatus = value
end
--更新准备状态
function Sangong_PlayerInfoEx:updateReadyStatus(data)
	self.readyStatus = data:readByte()
end
--更新摊牌状态
function Sangong_PlayerInfoEx:updateShowdownStatus(data)
	self.showdownStatus = ST.TYPE_GAMESANGONG_SHOWDOWN
	self.pokerGroup:bytesRead(data)
end
--发牌序列化
function Sangong_PlayerInfoEx:pokerBytesRead(data)
	self.pokerGroup:bytesRead(data)
end
--信息变化 序列化
function Sangong_PlayerInfoEx:updateBytesRead(data)
	self.gold = data:readLong()
end
--收到结果
function Sangong_PlayerInfoEx:resultBytesRead(data)
	self.resultGold = data:readLong()
	self.gold = data:readLong()
	if self.id == Player.id then
		Player.setGold(self.gold,true)
	end
end
--详细序列化
function Sangong_PlayerInfoEx:bytesRead(data)
	self.showdownStatus = ST.TYPE_GAMESANGONG_NOT_SHOWDOWN
	self:super("bytesRead",data)
	--座位号
	self.index = data:readByte()
	--抢庄倍数
	self.masterTimesValue = data:readByte()
	--加倍倍数
	self.addTimesValue = data:readByte()
	--状态，是否准备
	self.readyStatus = data:readByte()
	return self
end
--重置状态
function Sangong_PlayerInfoEx:reset()
	self.showdownStatus = ST.TYPE_GAMESANGONG_NOT_SHOWDOWN
	self.masterTimesValue = -1
	self.addTimesValue = -1
	self.ismaster = false
end

return Sangong_PlayerInfoEx