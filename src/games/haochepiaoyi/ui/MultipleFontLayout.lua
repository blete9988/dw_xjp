--[[
 *	豪车漂移倍数文本显示控件
 *	@author gwj
]]
local MultipleFontLayout = class("MultipleFontLayout",function() return display.newLayout(cc.size(90,80)) end)
function MultipleFontLayout:ctor(id)
	self:setAnchorPoint(cc.p(0.5,0.5))
	local total_value_label = ccui.TextAtlas:create("","game/haochepiaoyi/fcpy_number_4.png",18,24,0)
	self:addChild(total_value_label)
	total_value_label:setScale(0.8)
	total_value_label:setPosition(cc.p(45,60))
	self.total_value_label = total_value_label
	local self_value_label = ccui.TextAtlas:create("","game/haochepiaoyi/fcpy_number_5.png",18,24,0)
	self:addChild(self_value_label)
	self_value_label:setScale(0.8)
	self_value_label:setPosition(cc.p(45,12))
	self.self_value_label = self_value_label
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
