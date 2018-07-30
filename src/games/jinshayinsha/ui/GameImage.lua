--[[
 *	飞禽走兽控件
 *	@author gwj
]]
local GameImage = class("GameImage",function() return display.newLayout(cc.size(110,94)) end)
local element = require("src.games.jinshayinsha.data.JinShaYinSha_element_data")
function GameImage:ctor(id,recttype)
	self.data = element.new(id)
	self.size = self:getContentSize()
	self.recttype = recttype
	local rect_str = nil
	if recttype == 1 then
		rect_str = "jsys_rect_green_01.png"
	elseif recttype == 2 then
		rect_str = "jsys_rect_red_01.png"
	else
		rect_str = "jsys_rect_yellow_01.png"
	end
	self.rect = display.newSprite(rect_str)
	self.rect:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self.rect:setVisible(false)
	self:addChild(self.rect)

	local data_image = display.newImage(self.data.icon)
	data_image:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self:addChild(data_image)
	self.data_image = data_image
	-- self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	-- self:setBackGroundColor(Color.BLACK)
end

function GameImage:blink()
	self.rect:setVisible(true)
end

function GameImage:disappear()
	self.rect:setVisible(false)
end

function GameImage:playRectAni()
	self.rect:setVisible(true)
	if self.recttype == 1 then
		self.rect:runAction(resource.getAnimateByKey("jsys_rect_green",true))
	elseif self.recttype == 2 then
		self.rect:runAction(resource.getAnimateByKey("jsys_rect_red",true))
	else
		self.rect:runAction(resource.getAnimateByKey("jsys_rect_yellow",true))
	end
end

function GameImage:stopRectAni()
	self.rect:stopAllActions()
end

function GameImage:setRectOpacity(value)
	self:setOpacity(value)
end

function GameImage:getData()
	return self.data
end

return GameImage
