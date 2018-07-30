--[[
*	牌组对象
*	@author lqh
]]

local PokerGroup = class("PokerGroup")

function PokerGroup:ctor()
	self.pokers = {}
	self.groupType = 4
end
--获取牌型对应的图片
function PokerGroup:getTypePic()
	return string.format("poker_type_%s.png",self.groupType)
end
function PokerGroup:getTypeSound()
	return string.format("hhdz_grouptype_%s",self.groupType)
end
--获取所有扑克数据
function PokerGroup:getPokers()
	return self.pokers
end

function PokerGroup:bytesRead(data)
	self.pokers = {}
	self.groupTypeValue = nil
	
	local sid
	for i = 1,3 do
		sid = data:readUnsignedShort()
		self.pokers[i] = require("src.games.hongheidazhan.data.PokerData").new(sid)
	end
	--牌型
	self.groupType = data:readByte()
end

return PokerGroup