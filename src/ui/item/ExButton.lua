--[[
*	按钮扩展
*	@author：lqh
]]
local ExButton = class("ExButton",function(normalpath,selectpath,disablepath,type) 
	local button = display.newButton(normalpath,selectpath,disablepath,type)
	return button
end)

function ExButton:ctor(normalpath,selectpath,disablepath,type)
	self.disable = false
	self.visibleTouch = false
end
--是否禁用
function ExButton:setDisable(value)
	if value == self.disable then return end
	self.disable = value
	if value then
		self:setTouchEnabled(false)
		self:setBright(false)
	else
		self:setTouchEnabled(true)
		self:setBright(true)
	end
end

function ExButton:setVisibleTouch(value)
	if value == self.visibleTouch then return end
	self.visibleTouch = value
	self:setTouchEnabled(value)
	self:setVisible(value)
end

return ExButton