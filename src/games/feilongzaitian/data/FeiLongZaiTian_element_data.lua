--[[
 *	飞龙在天配置
 *	@author：gwj
]]
local FeiLongZaiTian_element_data = class("FeiLongZaiTian_element_data",BaseConfig)
FeiLongZaiTian_element_data.samplepath_ = "src.games.feilongzaitian.data.FeiLongZaiTian_element_config"

function FeiLongZaiTian_element_data:getId()
	return self.sid
end

return FeiLongZaiTian_element_data