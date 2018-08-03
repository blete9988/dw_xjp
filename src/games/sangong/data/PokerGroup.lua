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
	if self.groupTypeValue then
		return string.format("ui_qznn_result_%s%s.png",self.groupType,self.groupTypeValue)
	else
		return string.format("ui_qznn_result_%s.png",self.groupType)
	end
end
function PokerGroup:getTypeSound()
	if self.groupType == 3 then
		return "qznn_pokertype_3"
	elseif self.groupType ~= 4 then
		return "qznn_pokertype_5"
	else
		return "qznn_pokertype_4" .. self.groupTypeValue
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
	local splits = {}
	for i = 1,5 do
		splits[i] = math.band(self.gruopValue,math.pow(2,(i - 1)))
	end
	return splits
end

function PokerGroup:bytesRead(data)
	self.pokers = {}
	self.groupTypeValue = nil
	
	local sid
	for i = 1,5 do
		sid = data:readUnsignedShort()
		self.pokers[i] = require("src.games.sangong.data.PokerData").new(sid)
	end
	--组合的值
	self.gruopValue = data:readUnsignedByte()
	--牌型
	self.groupType = data:readByte()
	
	if self.groupType == 4 then
		--有牛
		self.groupTypeValue = data:readByte()
	end
	
	return self
end

return PokerGroup