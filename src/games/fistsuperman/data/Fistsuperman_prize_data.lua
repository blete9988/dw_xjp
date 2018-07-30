--[[
 *	一拳超人连线数据
 *	@author：gwj
]]
local Fistsuperman_prize_data = class("Fistsuperman_prize_data")

function Fistsuperman_prize_data:ctor(sid,number,lineType,isFistBlow)
	self.sid = sid
	self.count = number
	self.lineData = require("src.games.fistsuperman.data.Fistsuperman_line_data").new(lineType)
	self.isFistBlow = isFistBlow
end

function Fistsuperman_prize_data:isExist(column,line)
	if self.count >= column then return true end
	return false
end

function Fistsuperman_prize_data:getId()
	return self.sid
end

return Fistsuperman_prize_data