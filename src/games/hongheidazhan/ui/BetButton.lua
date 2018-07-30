--[[
*	下注 按钮
*	@author：lqh
]]
local BetButton = class("BetButton",require("src.base.extend.CCLayerExtend"),function() 
	local button = display.newButton()
	button:setScale(1.19718)
	button.m_setBrightStyle = button.setBrightStyle
	return button
end, IEventListener)

function BetButton:ctor(betvalue)
	self:super("ctor")
	--添加金币变动监听
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE,CommandCenter.MAX_PRO)
	
	self.betvalue = betvalue
	self:loadTextureNormal(string.format("bet_hhdz_%s.png",betvalue),1)
	self:loadTexturePressed(string.format("bet_hhdz_%s_select.png",betvalue),1)
	self.disable = false
	self.showStatus = true
	
	self:handlerEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
end
--@override
function BetButton:setBrightStyle(value)
	if value == ccui.BrightStyle.normal then
		self:setPositionY(self:getPositionY() - 20)
		self.brightStyle = value
	elseif value == ccui.BrightStyle.highlight then
		self:setPositionY(self:getPositionY() + 20)
		self.brightStyle = value
	end
end
--是否禁用
function BetButton:setDisable(value)
	if value == self.disable then return end
	self.disable = value
	if value then
		self:setTouchEnabled(false)
		self:setOpacity(100)
	else
		if not self.showStatus then return end
		self:setTouchEnabled(true)
		self:setOpacity(255)
	end
end
function BetButton:setShowStatus(bool)
	self.showStatus = bool
	if not bool then
		self:setTouchEnabled(false)
		self:setOpacity(100)
	else
		if self.disable then return end
		self:setTouchEnabled(true)
		self:setOpacity(255)
	end
end
--@override
function BetButton:handlerEvent(event,arg)
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		self:setDisable(Player.gold < self.betvalue)
	end
end
function BetButton:onCleanup()
	self:removeAllEvent()
end
return BetButton