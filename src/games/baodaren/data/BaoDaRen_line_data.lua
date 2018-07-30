--[[
 *	连线数据
 *	@author：gwj
]]
local BaoDaRen_line_data = class("BaoDaRen_line_data",BaseConfig)
BaoDaRen_line_data.samplepath_ = "src.games.baodaren.data.BaoDaRen_line_config"


function BaoDaRen_line_data:ctor(id,count,multiple)
	self:super("ctor",id)
	self.count = count
	self.multiple = multiple
end

function BaoDaRen_line_data:getId()
	return self.id
end

function BaoDaRen_line_data:getLocationByColumn(column)
	return self.locations[column]
end

return BaoDaRen_line_data