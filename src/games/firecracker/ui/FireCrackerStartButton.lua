--[[
 *	显示的单项控件
 *	@author gwj
]]
local FireCrackerStartButton = class("FireCrackerStartButton",function() return display.newButton(nil,nil,nil) end,require("src.base.extend.CCNodeExtend"),require("src.base.event.EventDispatch"))

function FireCrackerStartButton:ctor(type)
	self:setPressedActionEnabled(true)
	self:setContentSize(cc.size())
	local number_txt = display.newText("100",24,Color.WHITE)
	number_txt:setPosition(cc.p(75,74))
	self:addChild(number_txt)
	self.number_txt = number_txt
	self:showType(type)
	self.isLongTime = false
	local run_Action = nil
	self:addTouchEventListener(function(sender,eventype)
	    if eventype == ccui.TouchEventType.began then
	    	self.isLongTime = true
	    	run_Action = sender:performWithDelay(function(senderI)
	    		self:dispatchEvent("START_CLICK",true,self.type)
	    		self.isLongTime = false
	    		run_Action = nil
			end,1)
	    elseif eventype == ccui.TouchEventType.ended then
	    	if self.isLongTime then
	    		self:dispatchEvent("START_CLICK",false,self.type)
	    		if run_Action ~= nil then
	    			sender:stopAction(run_Action)
	    			run_Action = nil
	    		end
	    		self.isLongTime = false
	    	end
        end
    end)
end

function FireCrackerStartButton:showType(type)
	self.type = type
	if self.type == 1 then
		self.number_txt:setVisible(false)
		self:loadTextureNormal("firecracker_btn_8.png",1)
	elseif self.type == 2 then
		self.number_txt:setVisible(true)
		self:loadTextureNormal("firecracker_btn_9.png",1)
	elseif self.type == 3 then
		self.number_txt:setVisible(false)
		self:loadTextureNormal("firecracker_btn_10.png",1)
	end
end

function FireCrackerStartButton:getType()
	return self.type
end

function FireCrackerStartButton:setText(value)
	self.number_txt:setString(value)
end

function FireCrackerStartButton:pauseShowType(type)
	self:showType(type)
	self:setTouchEnabled(false)
	self:performWithDelay(function(sender)
		self:setTouchEnabled(true)
	end,0.5)
end

return FireCrackerStartButton
