--[[
 *	一拳超人连线数据
 *	@author：gwj
]]
local BaoDaRen_prize_data = class("BaoDaRen_prize_data")

function BaoDaRen_prize_data:ctor(sid,number,lineType,isFistBlow)
	self.sid = sid
	self.count = number
	self.lineData = require("src.games.baodaren.data.BaoDaRen_line_data").new(lineType)
	self.isFistBlow = isFistBlow
end

function BaoDaRen_prize_data:isExist(column,line)
	if self.count >= column then return true end
	return false
end

function BaoDaRen_prize_data:getId()
	return self.sid
end

return BaoDaRen_prize_data