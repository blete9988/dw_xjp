--[[
 *	水浒传配置
 *	@author：gwj
]]
local ShuiHuZhuan_element_data = class("ShuiHuZhuan_element_data",BaseConfig)
ShuiHuZhuan_element_data.samplepath_ = "src.games.shuihuzhuan.data.ShuiHuZhuan_element_config"

function ShuiHuZhuan_element_data:getId()
	return self.sid
end

return ShuiHuZhuan_element_data