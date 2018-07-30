--[[
 *	好车飘逸倍数配置
 *	@author：gwj
]]
local HaoChePiaoYi_multiple_data = class("HaoChePiaoYi_multiple_data",BaseConfig)
HaoChePiaoYi_multiple_data.samplepath_ = "src.games.haochepiaoyi.data.HaoChePiaoYi_multiple_config"

function HaoChePiaoYi_multiple_data:getId()
	return self.id
end

return HaoChePiaoYi_multiple_data