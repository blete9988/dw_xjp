--[[
 *	水平方向弹层
 *	@author gwj
]]
local FireCrackerHorShootPanel = class("FireCrackerHorShootPanel",function() return display.newImage("firecracker_bg_3.png") end,require("src.base.event.EventDispatch"))

local COUNT_NUMBER = {100,200,500,999}
local BUTTON_RECTS = {cc.rect(72,69,120,100),cc.rect(202,69,130,100),cc.rect(336,69,130,100),cc.rect(468,69,120,100)}


function FireCrackerHorShootPanel:ctor()
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
	    	self:dispatchEvent("HOR_SHOOTPANEL_CLICK",COUNT_NUMBER[sender.index])
        end)
		self:addChild(button)
	end
	self:setVisible(false)
	self.state = false
end

function FireCrackerHorShootPanel:show()
	if self.state then
		self:moveGo()
	else
		self:moveTo()
	end
end

function FireCrackerHorShootPanel:moveTo()
	if self.state then return end
	self:stopAllActions()
	self.state = true
	if not self.savePosition then
		self.savePosition = cc.p(self:getPositionX(),self:getPositionY())
	end
	self:setPosition(cc.p(D_SIZE.width + self:getContentSize().width/2,self:getPositionY()))
	self:setVisible(true)
	self:runAction(cc.MoveTo:create(0.2,self.savePosition))
end

function FireCrackerHorShootPanel:moveGo()
	if not self.state then return end
	-- self.savePosition = cc.p(self:getPositionX(),self:getPositionY())
	self:stopAllActions()
	self.state = false
	self:runAction(cc.MoveTo:create(0.2,cc.p(D_SIZE.width + self:getContentSize().width/2,self:getPositionY())))
end

return FireCrackerHorShootPanel
