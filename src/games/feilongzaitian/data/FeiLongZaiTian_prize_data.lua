--[[
 *	一拳超人连线数据
 *	@author：gwj
]]
local FeiLongZaiTian_prize_data = class("FeiLongZaiTian_prize_data")

function FeiLongZaiTian_prize_data:ctor(sid,number,lineType,isFistBlow)
	self.sid = sid
	self.count = number
	self.lineData = require("src.games.feilongzaitian.data.FeiLongZaiTian_line_data").new(lineType)
	self.isFistBlow = isFistBlow
end

function FeiLongZaiTian_prize_data:isExist(column,line)
	if self.count >= column then return true end
	return false
end

function FeiLongZaiTian_prize_data:getId()
	return self.sid
end

return FeiLongZaiTian_prize_data