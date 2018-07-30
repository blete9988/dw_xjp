--[[
*	游戏玩家
*	@author lqh
]]

local PlayerInfo = class("PlayerInfo")
PlayerInfo.id 	= 0
PlayerInfo.name = "placeholder"
PlayerInfo.pic	= ""
PlayerInfo.gold	= 0
--vip等级
PlayerInfo.level = 0

function PlayerInfo:setBriefInfo(id,name,gold)
	self.id = id
	self.name = name
	self.gold = gold
end
--是否是自己
function PlayerInfo:isSelf()
	return self.id == Player.id
end
--简要信息序列化
function PlayerInfo:briefBytesRead(data)
	self.name = data:readString()
	self.gold = data:readLong()
	return self
end

function PlayerInfo:m_setHeadIndex(index)
	self.headIndex = index
	self.pic = string.format("res/images/icons/head/head_icon_%s.png",index)
end
function PlayerInfo:normalBytesRead(data)
	self.id = data:readInt()
	self:m_setHeadIndex(data:readByte())
	self.name = data:readString()
	self.gold = data:readLong()
	return self
end
--排行榜序列化
function PlayerInfo:leaderBoardBytesRead(data,rank)
	self.rankIndex = rank
	self:normalBytesRead(data)
	return self
end

--详细序列化 
function PlayerInfo:bytesRead(data)
	self.id = data:readInt()
	self.name = data:readString()
	self.gold = data:readLong()
	self:m_setHeadIndex(data:readByte())
	return self
end

return PlayerInfo