--[[
*	扑克牌 类
*	@author lqh
]]

local PokerData = class("PokerData",BaseConfig)
PokerData.samplepath_ = "src.games.sangong.app.poker_config"

function PokerData:ctor(sid)
	self:super("ctor",sid)
end

return PokerData