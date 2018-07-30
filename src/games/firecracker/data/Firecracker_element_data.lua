--[[
 *	招财鞭炮配置
 *	@author：gwj
]]
local Firecracker_element_data = class("Firecracker_element_data",BaseConfig)
Firecracker_element_data.samplepath_ = "src.games.firecracker.data.Firecracker_element_config"

function Firecracker_element_data:getId()
	return self.id
end

return Firecracker_element_data