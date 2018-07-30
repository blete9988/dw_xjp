--[[
 *	左方向弹层
 *	@author gwj
]]
local BaoDaRenLeftShootPanel = class("BaoDaRenLeftShootPanel",function() return display.newImage("gwj_ui_bg_1.png") end,require("src.base.event.EventDispatch"))

local COUNT_NUMBER = {1,3,5,10}
local BUTTON_RECTS = {cc.rect(70,51,100,70),cc.rect(178,51,110,70),cc.rect(291,51,110,70),cc.rect(399,51,120,70)}


function BaoDaRenLeftShootPanel:ctor()
	-- self:setAnchorPoint(cc.p(0,0))
	for i=1,4 do
		local button = display.newTextButton(nil,nil,nil,0,COUNT_NUMBER[i],30,Color.WHITE)
		button:ignoreContentAdaptWithSize(false)
		local rect = BUTTON_RECTS[i]
		button:setContentSize(rect.width,rect.height)
		button:setPosition(cc.p(rect.x,rect.y))
		button.index = i
		button:setTitleAlignment(1,1)
		button:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then return end
	    	self:moveGo()
	    	self:dispatchEvent("LEFT_SHOOTPANEL_CLICK",COUNT_NUMBER[sender.index])
        end)
		self:addChild(button)
	end
	self:setVisible(false)
	self.state = false
end

function BaoDaRenLeftShootPanel:show()
	if self.state then
		self:moveGo()
	else
		self:moveTo()
	end
end

function BaoDaRenLeftShootPanel:moveTo()
	if self.state or self.isAction then return end
	self:stopAllActions()
	self.state = true
	if not self.savePosition then
		self.savePosition = cc.p(self:getPositionX(),self:getPositionY())
	end
	self:setPosition(cc.p(0 - self:getContentSize().width/2,self:getPositionY()))
	self:setVisible(true)
	self.isAction = true
	self:runAction(cc.Sequence:create({
			cc.MoveTo:create(0.2,self.savePosition),
			cc.CallFunc:create(function()
				self.isAction = false
			end)}))
end

function BaoDaRenLeftShootPanel:moveGo()
	if not self.state or self.isAction then return end
	-- self.savePosition = cc.p(self:getPositionX(),self:getPositionY())
	self:stopAllActions()
	self.state = false
	self:runAction(cc.Sequence:create({
			cc.MoveTo:create(0.2,cc.p(0 - self:getContentSize().width/2,self:getPositionY())),
			cc.CallFunc:create(function()
				self.isAction = false
			end)}))
end

return BaoDaRenLeftShootPanel
