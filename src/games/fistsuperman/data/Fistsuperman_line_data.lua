--[[
 *	一拳超人连线数据
 *	@author：gwj
]]
local Fistsuperman_line_data = class("Fistsuperman_line_data",BaseConfig)
Fistsuperman_line_data.samplepath_ = "src.games.fistsuperman.data.Fistsuperman_line_config"

function Fistsuperman_line_data:ctor(id,count,multiple)
	self:super("ctor",id)
	self.count = count
	self.multiple = multiple
	self.blowState = false
end

function Fistsuperman_line_data:getId()
	return self.sid
end

function Fistsuperman_line_data:getLocationByColumn(column)
	return self.locations[column]
end

function Fistsuperman_line_data:setBlowState(value)
	self.blowState = value
end

function Fistsuperman_line_data:getBlowState()
	return self.blowState
end

return Fistsuperman_line_data