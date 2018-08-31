--[[
*	下注 按钮
*	@author：lqh
]]
local BetButton = class("BetButton",require("src.base.extend.CCLayerExtend"),function() 
	local button = display.newButton()
	button.m_setBrightStyle = button.setBrightStyle
	return button
end)

function BetButton:ctor(betvalue)
	self:super("ctor")
	self.betvalue = betvalue
	self:loadTextureNormal(string.format("cm_bet_%s.png",betvalue),1)
	self:loadTexturePressed(string.format("cm_bet_%s.png",betvalue),1)
	self:loadTextureDisabled(string.format("cm_bet_%s_disable.png",betvalue),1)
	self:setScale(1.4)
	self.disable = false
	self:setDisable(Player.gold < betvalue)
end
--@override
function BetButton:setBrightStyle(value)
	if self.brightStyle == value then return end
	if value == ccui.BrightStyle.normal then
		self:setPositionY(self:getPositionY() - 20)
		self.brightStyle = value
	elseif value == ccui.BrightStyle.highlight then
		self:setPositionY(self:getPositionY()+ 20)
		self.brightStyle = value
	end
end

function BetButton:checkDisable()
	self:setDisable(Player.gold < self.betvalue)
end

--是否禁用
function BetButton:setDisable(value)
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

function BetButton:onCleanup()
	
end
return BetButton