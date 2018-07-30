--[[
*	通比牛牛 游戏玩家
*	@author lqh
]]

local Tbnn_PlayerInfoEx = class("Tbnn_PlayerInfoEx",require("src.app.data.PlayerInfo"))

function Tbnn_PlayerInfoEx:ctor()
	self:super("ctor")
	self.pokerGroup = require("src.games.tongbiniuniu.data.PokerGroup").new()
	self.index = 1
	self.resultGold = 0
	self.readyStatus = ST.TYPE_GAMETBNN_NOT_READY
	self.showdownStatus = ST.TYPE_GAMETBNN_NOT_SHOWDOWN
	--玩家在前端显示的位置
	self.clientIndex = 0
end
--设置在前端的显示位置
function Tbnn_PlayerInfoEx:setClientIndex(index)
	self.clientIndex = index
end
--是否已摊牌
function Tbnn_PlayerInfoEx:isShowdown()
	return self.showdownStatus == ST.TYPE_GAMETBNN_SHOWDOWN
end
--是否已准备
function Tbnn_PlayerInfoEx:isReady()
	return self.readyStatus == ST.TYPE_GAMETBNN_READY
end
function Tbnn_PlayerInfoEx:isWinner()
	return self.resultGold > 0
end
function Tbnn_PlayerInfoEx:setReadyStatus(value)
	self.readyStatus = value
end
function Tbnn_PlayerInfoEx:setShowdownStatus(value)
	self.showdownStatus = value
end
--更新准备状态
function Tbnn_PlayerInfoEx:updateReadyStatus(data)
	self.readyStatus = data:readByte()
end
--更新摊牌状态
function Tbnn_PlayerInfoEx:updateShowdownStatus(data)
	self.showdownStatus = ST.TYPE_GAMETBNN_SHOWDOWN
	self.pokerGroup:bytesRead(data)
end
--发牌序列化
function Tbnn_PlayerInfoEx:pokerBytesRead(data)
	self.pokerGroup:bytesRead(data)
end
--信息变化 序列化
function Tbnn_PlayerInfoEx:updateBytesRead(data)
	self.gold = data:readLong()
end
--收到结果
function Tbnn_PlayerInfoEx:resultBytesRead(data)
	self.resultGold = data:readLong()
	self.gold = data:readLong()
	if self.id == Player.id then
		Player.setGold(self.gold,true)
	end
	self:reset()
end
--详细序列化
function Tbnn_PlayerInfoEx:bytesRead(data)
	self.showdownStatus = ST.TYPE_GAMETBNN_NOT_SHOWDOWN
	self:super("bytesRead",data)
	--座位号
	self.index = data:readByte()
	--状态，是否准备
	self.readyStatus = data:readByte()
	
	return self
end
--重置状态
function Tbnn_PlayerInfoEx:reset()
--	self.readyStatus = ST.TYPE_GAMETBNN_NOT_READY
	self.showdownStatus = ST.TYPE_GAMETBNN_NOT_SHOWDOWN
end

return Tbnn_PlayerInfoEx