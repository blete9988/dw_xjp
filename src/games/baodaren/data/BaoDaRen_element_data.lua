--[[
 *	一拳超人配置
 *	@author：gwj
]]
local BaoDaRen_element_data = class("BaoDaRen_element_data",BaseConfig)
BaoDaRen_element_data.samplepath_ = "src.games.baodaren.data.BaoDaRen_element_config"

function BaoDaRen_element_data:getId()
	return self.sid
end

return BaoDaRen_element_data