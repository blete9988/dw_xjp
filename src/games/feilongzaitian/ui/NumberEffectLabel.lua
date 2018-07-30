--[[
 *	带特效的数字控件
 *	@author gwj
]]
local NumberEffectLabel = class("NumberEffectLabel",function() return display.extend("CCNodeExtend",ccui.TextAtlas:create()) end)

function NumberEffectLabel:ctor(value,charMapFile,itemWidth,itemHeight)
	self.max_value = value
	self.value = 0
	self:setProperty(0,charMapFile,itemWidth,itemHeight,0)
	self.action_handler = self:schedule(function()
		self.value = self.value + 10
		if self.value >= self.max_value then
			self.value = self.max_value
			self:stopAction(self.action_handler)
		end
		self:setString(self.value)
	end, 0.02)
end

return NumberEffectLabel
