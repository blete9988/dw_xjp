--[[
 *	飞禽走兽配置
 *	@author：gwj
]]
local FeiQingZouShou_element_data = class("FeiQingZouShou_element_data",BaseConfig)
FeiQingZouShou_element_data.samplepath_ = "src.games.feiqingzoushou.data.FeiQingZouShou_element_config"

function FeiQingZouShou_element_data:getId()
	return self.sid
end

function FeiQingZouShou_element_data:getMutipleSid()
	if self.sid == 10 then	--金鲨银鲨使用一个sid
		return 9
	end
	return self.sid
end

return FeiQingZouShou_element_data