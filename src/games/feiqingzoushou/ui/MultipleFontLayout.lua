--[[
 *	飞禽走兽倍数文本显示控件
 *	@author gwj
]]
local MultipleFontLayout = class("MultipleFontLayout",function() return display.newLayout() end)
function MultipleFontLayout:ctor(id,size,location)
	self:setContentSize(size)
	-- display.debugLayout(self)
	local total_value_label = ccui.TextAtlas:create("","game/haochepiaoyi/fcpy_number_4.png",18,24,0)
	self:addChild(total_value_label)
	total_value_label:setScale(0.6)
	self.total_value_label = total_value_label
	local self_value_label = ccui.TextAtlas:create("","game/haochepiaoyi/fcpy_number_5.png",18,24,0)
	self:addChild(self_value_label)
	self_value_label:setScale(0.6)
	self.self_value_label = self_value_label
	if location == 0 then
		Coord.ingap(self,self_value_label,"CC",0,"TT",-20)
		Coord.ingap(self,total_value_label,"CC",0,"CC",-10)
	else
		Coord.ingap(self,self_value_label,"CC",0,"BB",18)
		Coord.ingap(self,total_value_label,"CC",0,"CC",15)
	end
end

function MultipleFontLayout:setTotalValue(value)
	local oldvalue = tonum(self.total_value_label:getString())
	if oldvalue > value or value == 0 then return end
	self.total_value_label:setString(value)
end

function MultipleFontLayout:setSelfValue(value)
	local oldvalue = tonum(self.self_value_label:getString())
	if oldvalue > value or value == 0 then return end
	self.self_value_label:setString(value)
end

function MultipleFontLayout:cleanValue()
	self.self_value_label:setString("")
	self.total_value_label:setString("")
end

function MultipleFontLayout:addSelfValue(value)
	local oldvalue = tonum(self.self_value_label:getString())
	self.self_value_label:setString(oldvalue + value)
end

function MultipleFontLayout:addTotalValue(value)
	local oldvalue = tonum(self.total_value_label:getString())
	self.total_value_label:setString(oldvalue + value)
end


return MultipleFontLayout
