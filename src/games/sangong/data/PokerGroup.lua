--[[
*	牌组对象
*	@author lqh
]]

local PokerGroup = class("PokerGroup")

function PokerGroup:ctor()
	self.pokers = {}
	self.groupType = 9
end
--获取牌型对应的图片
function PokerGroup:getTypePic()
	mlog("获取牌型对应的图片")
	if self.groupTypeValue then
		return string.format("sangong_type_5%s.png",self.groupTypeValue)
	else
		return string.format("sangong_type_%s.png",self.groupType)
	end
end
function PokerGroup:getTypeSound()
	if self.groupType == 3 then
		return "qznn_pokertype_3"
	elseif self.groupType == 4 then
		return "qznn_pokertype_4"
	elseif self.groupType == 2 then
		return "qznn_pokertype_2"
	else
		return "qznn_pokertype_5" .. self.groupTypeValue
	end
end
--牌是否大于等于牛牛大
function PokerGroup:isLargeNiuNiu()
	if self.groupTypeValue or self.groupType <= 4 then return false end
	return true
end
--获取所有扑克数据
function PokerGroup:getPokers()
	return self.pokers
end
--获取牌组合的结构数组
function PokerGroup:getGroupSplit()
	local proker_count = 3
	local splits = {}
	for i = 1,proker_count do
		splits[i] = math.band(self.gruopValue,math.pow(2,(i - 1)))
	end
	return splits
end

function PokerGroup:bytesRead(data)
	self.pokers = {}
	self.groupTypeValue = nil
	local proker_count = 3
	local sid
	for i = 1,proker_count do
		sid = data:readUnsignedShort()
		mlog("发牌SID:",sid)
		self.pokers[i] = require("src.games.sangong.data.PokerData").new(sid)
	end
	--组合的值
	self.gruopValue = data:readUnsignedByte()
	--牌型
	self.groupType = data:readByte()

	mlog("组合的值:",self.gruopValue)
	mlog("牌型：",self.groupType)
	
-- 	大三公，小三公，混三公，点牌
-- 对应4，3，2，1
	if self.groupType == 1 then
		--有牛
		self.groupTypeValue = data:readByte()
		mlog("点数：",self.groupTypeValue)
	end
	
	return self
end

return PokerGroup