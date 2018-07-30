--[[
 *	一拳超人配置
 *	@author：gwj
]]
local Fistsuperman_element_data = class("Fistsuperman_element_data",BaseConfig)
Fistsuperman_element_data.samplepath_ = "src.games.fistsuperman.data.Fistsuperman_element_config"

function Fistsuperman_element_data:ctor(id)
	self:super("ctor",id)
	self.blowState = false
end

function Fistsuperman_element_data:getId()
	return self.sid
end

function Fistsuperman_element_data:setBlowState(value)
	self.blowState = value
end

function Fistsuperman_element_data:getBlowState()
	return self.blowState
end

return Fistsuperman_element_data