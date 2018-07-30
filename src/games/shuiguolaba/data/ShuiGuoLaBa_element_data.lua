--[[
 *	配置
 *	@author：gwj
]]
local ShuiGuoLaBa_element_data = class("ShuiGuoLaBa_element_data",BaseConfig)
ShuiGuoLaBa_element_data.samplepath_ = "src.games.shuiguolaba.data.ShuiGuoLaBa_element_config"

function ShuiGuoLaBa_element_data:getSid()
	return self.sid
end

return ShuiGuoLaBa_element_data