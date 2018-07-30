--[[
 *	连线数据
 *	@author：gwj
]]
local FeiLongZaiTian_line_data = class("FeiLongZaiTian_line_data",BaseConfig)
FeiLongZaiTian_line_data.samplepath_ = "src.games.feilongzaitian.data.FeiLongZaiTian_line_config"

function FeiLongZaiTian_line_data:ctor(id,count,multiple)
	self:super("ctor",id)
	self.count = count
	self.multiple = multiple
	self.blowState = false
end

function FeiLongZaiTian_line_data:getId()
	return self.sid
end

function FeiLongZaiTian_line_data:getLocationByColumn(column)
	return self.locations[column]
end


return FeiLongZaiTian_line_data