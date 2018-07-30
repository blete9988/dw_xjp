--[[
 *	飞禽走兽控件
 *	@author gwj
]]
local GameImage = class("GameImage",function() return display.newImage() end)
local element = require("src.games.feiqingzoushou.data.FeiQingZouShou_element_data")
local soundController = require("src.games.feiqingzoushou.data.FeiQingZouShouSoundController").getInstance()
function GameImage:ctor(id)
	self.data=element.new(id)
	self:loadTexture(self.data.background,1)
	self.size=self:getContentSize()

	self.rect = display.newImage("fqzs-fly-main-icon-circle-select.png")
	self.rect:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self.rect:setVisible(false)
	self:addChild(self.rect)

	local data_image = display.newImage(self.data.icon)
	data_image:setPosition(cc.p(self.size.width/2,self.size.height/2))
	self:addChild(data_image)
	self.data_image = data_image
end

function GameImage:blink()
	-- soundController:playTurnSound()
	self.rect:setVisible(true)
end

function GameImage:disappear()
	self.rect:setVisible(false)
end

function GameImage:setRectOpacity(value)
	self:setOpacity(value)
end

function GameImage:getData()
	return self.data
end

return GameImage
