--[[
*	扑克牌 类
*	@author lqh
]]

local PokerData = class("PokerData",BaseConfig)
PokerData.samplepath_ = "src.games.baijiale.app.poker_config"

function PokerData:ctor(sid,index)
	self:super("ctor",sid)
	self.index = index
end
function PokerData:isLast()
	return self.index == 3
end
--获取点数
function PokerData:getPoint()
	if self.value >= 10 then
		return 0
	end
	return self.value
end

return PokerData