--[[
 *	右方向弹层
 *	@author gwj
]]
local BaoDaRenRightShootPanel = class("BaoDaRenRightShootPanel",function() return display.newImage("gwj_ui_bg_3.png") end,require("src.base.event.EventDispatch"))

local COUNT_NUMBER = {100,200,500,999}
local BUTTON_RECTS = {cc.rect(72,69,120,100),cc.rect(202,69,130,100),cc.rect(336,69,130,100),cc.rect(468,69,120,100)}


function BaoDaRenRightShootPanel:ctor()
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
	    	self:dispatchEvent("RIGHT_SHOOTPANEL_CLICK",COUNT_NUMBER[sender.index])
        end)
		self:addChild(button)
	end
	self:setVisible(false)
	self.state = false
end

function BaoDaRenRightShootPanel:show()
	if self.state then
		self:moveGo()
	else
		self:moveTo()
	end
end

function BaoDaRenRightShootPanel:moveTo()
	if self.state or self.isAction then return end
	self:stopAllActions()
	self.state = true
	if not self.savePosition then
		self.savePosition = cc.p(self:getPositionX(),self:getPositionY())
	end
	self:setPosition(cc.p(D_SIZE.width + self:getContentSize().width/2,self:getPositionY()))
	self:setVisible(true)
	self:runAction(cc.Sequence:create({
			cc.MoveTo:create(0.2,self.savePosition),
			cc.CallFunc:create(function()
				self.isAction = false
			end)}))
end

function BaoDaRenRightShootPanel:moveGo()
	if not self.state or self.isAction then return end
	-- self.savePosition = cc.p(self:getPositionX(),self:getPositionY())
	self:stopAllActions()
	self.state = false
	self:runAction(cc.Sequence:create({
			cc.MoveTo:create(0.2,cc.p(D_SIZE.width + self:getContentSize().width/2,self:getPositionY())),
			cc.CallFunc:create(function()
				self.isAction = false
			end)}))
end

return BaoDaRenRightShootPanel
