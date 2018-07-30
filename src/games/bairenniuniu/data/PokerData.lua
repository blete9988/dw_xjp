--[[
*	扑克牌 类
*	@author lqh
]]

local PokerData = class("PokerData",BaseConfig)
PokerData.samplepath_ = "src.games.bairenniuniu.app.poker_config"

function PokerData:ctor(sid,index)
	self:super("ctor",sid)
end

return PokerData