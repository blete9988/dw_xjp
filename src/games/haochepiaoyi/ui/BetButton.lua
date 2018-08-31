--[[
*	下注 按钮
*	@author：lqh
]]
local BetButton = class("BetButton",require("src.base.extend.CCLayerExtend"),function() 
	local button = display.newButton()
	button.m_setBrightStyle = button.setBrightStyle
	return button
end, IEventListener)

function BetButton:ctor(betvalue)
	self:super("ctor")
	--添加金币变动监听
	-- self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE,CommandCenter.MAX_PRO)
	self.betvalue = betvalue
	self:loadTextureNormal(string.format("sglb2_bet_%s.png",betvalue),1)
	self:loadTexturePressed(string.format("sglb2_bet_%s.png",betvalue),1)
	self:loadTextureDisabled(string.format("sglb2_bet_%s_disable.png",betvalue),1)
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
--@override
-- function BetButton:handlerEvent(event,arg)
-- 	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
-- 		self:setDisable(Player.gold < self.betvalue)
-- 	end
-- end
function BetButton:onCleanup()
	self:removeAllEvent()
end
return BetButton