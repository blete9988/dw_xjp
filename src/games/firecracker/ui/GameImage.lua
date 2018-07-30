--[[
 *	显示的单项控件
 *	@author gwj
]]
local GameImage = class("GameImage",function() return cc.Sprite:create() end)
local FirecrackerData =  require("src.games.firecracker.data.Firecracker_element_data")
function GameImage:ctor(sid)
	self.data= FirecrackerData.new(sid)
	self:setSpriteFrame(self.data.icon)
	self.size=self:getContentSize()
end

function GameImage:setdata(sid)
	self.data = FirecrackerData.new(sid)
	self:setSpriteFrame(self.data.icon)
	self.size = self:getContentSize()
end

return GameImage
