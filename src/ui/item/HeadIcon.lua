--[[
*	头像item
*	@author：lqh
]]
local HeadIcon = class("HeadIcon",function() 
	local layout = display.newLayout(cc.size(125,125))
	layout:setBackGroundImage("p_ui_1080.png",1)
	return layout
end)

function HeadIcon:ctor(headpath)
	self.m_icon = display.newDynamicImage()
	self:addChild(Coord.ingap(self,self.m_icon,"CC",0,"CC",0))
	self:setHead(headpath)
end
function HeadIcon:setHead(headpath)
	if not headpath or headpath == "" then return end
	self.m_icon:loadTexture(headpath)
end

return HeadIcon