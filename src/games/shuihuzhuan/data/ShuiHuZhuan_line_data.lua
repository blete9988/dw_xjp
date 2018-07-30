--[[
 *	水浒传连线数据
 *	@author：gwj
]]
local ShuiHuZhuan_line_data = class("ShuiHuZhuan_line_data",BaseConfig)
ShuiHuZhuan_line_data.samplepath_ = "src.games.shuihuzhuan.data.ShuiHuZhuan_line_config"

function ShuiHuZhuan_line_data:ctor(id,count,multiple,direction)
	self:super("ctor",id)
	self.count = count
	self.multiple = multiple
	self.direction = direction
end

function ShuiHuZhuan_line_data:getId()
	return self.sid
end

function ShuiHuZhuan_line_data:getLocationByColumn(column)
	return self.locations[column]
end

return ShuiHuZhuan_line_data 