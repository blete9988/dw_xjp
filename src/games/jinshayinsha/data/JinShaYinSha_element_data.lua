--[[
 *	金沙银沙配置
 *	@author：gwj
]]
local JinShaYinSha_element_data = class("JinShaYinSha_element_data",BaseConfig)
JinShaYinSha_element_data.samplepath_ = "src.games.jinshayinsha.data.JinShaYinSha_element_config"

function JinShaYinSha_element_data:getId()
	return self.id
end

return JinShaYinSha_element_data