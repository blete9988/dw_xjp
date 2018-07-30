--[[
*	Slider控件，带增加，减少按钮
*	@派发 change 事件
*	@author：lqh
]]
local SliderComponent = class("SliderComponent",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function(size)
	local container = display.newLayout(size)
	container:setAnchorPoint(cc.p(0.5, 0.5))
	return container
end)
function SliderComponent:ctor(size)
	self:super("ctor")
	
	self.m_pervalue = 1
	self.m_maxValue = 1000
	self.m_minValue = 0
end
function SliderComponent.getSimple()
	local simple = SliderComponent.new(cc.size(470,50))
	simple:initLeftButton("uibutton_08.png","uibutton_08.png","",1)
	simple:initRightButton("uibutton_07.png","uibutton_07.png","",1)

	simple:initSlider(
		cc.Sprite:createWithSpriteFrameName("slider_bg.png"),
		cc.Sprite:createWithSpriteFrameName("slider_fg.png"),
		cc.Sprite:createWithSpriteFrameName("slider_button.png"),
		cc.Sprite:createWithSpriteFrameName("slider_button.png")
	)
	simple:upView()
	return simple
end

function SliderComponent:setMaxValue(value)
	self.m_maxValue = value or self.m_maxValue
	if self.m_slider then
		self.m_slider:setMaximumValue(value)
	end
end

function SliderComponent:setMinimumValue(value)
	self.m_minValue = value or self.m_minValue
	if self.m_slider then
		self.m_slider:setMinimumValue(value)
	end
end

function SliderComponent:getPercent()
	return math.floor(self.m_slider:getValue())
end
function SliderComponent:setPercent(value)
	if value > 0 then
		self.m_slider:setValue(value)
	end
end
--设置增减率
function SliderComponent:setPervalue(value)
	self.m_pervalue = value or 1
end
function SliderComponent:initSlider(bgsprite,fgsprite,thumbsprite,slelectThumbsprite)
	if self.m_slider then return end
	local slider = cc.ControlSlider:create(bgsprite,fgsprite,thumbsprite,slelectThumbsprite)
    slider:setAnchorPoint(cc.p(0.5, 0.5))
    slider:setMaximumValue(self.m_maxValue )
    slider:setMinimumValue(self.m_minValue)
    
	self:addChild(slider)
	slider:registerControlEventHandler(function(pSender)
		self:dispatchEvent("change",self:getPercent())
	end,cc.CONTROL_EVENTTYPE_VALUE_CHANGED)
	
	self.m_slider = slider
end
function SliderComponent:initLeftButton(normalfile,pressfile,disablefile,path)
	if self.m_leftbutton then return end
	local leftbutton = display.newButton(normalfile,pressfile,disablefile,path)
	leftbutton:setAnchorPoint(cc.p(0, 0.5))
	self:addChild(leftbutton)
	leftbutton:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then
			leftbutton:runAction(cc.Sequence:create(
				{
					cc.DelayTime:create(0.3),
					cc.CallFunc:create(function() 
						leftbutton.m_timehandler = timeup(function(t)
							self:setPercent(self:getPercent() - self.m_pervalue)
						end,0,false)
					end)
				}
			))
		elseif e == ccui.TouchEventType.ended then
			leftbutton:stopAllActions()
			if leftbutton.m_timehandler then
				timestop(leftbutton.m_timehandler)
				leftbutton.m_timehandler = nil
			else
				self:setPercent(self:getPercent() - self.m_pervalue)
			end
		elseif e == ccui.TouchEventType.canceled then
			leftbutton:stopAllActions()
			if leftbutton.m_timehandler then
				timestop(leftbutton.m_timehandler)
				leftbutton.m_timehandler = nil
			end
		end
	end)
	self.m_leftbutton = leftbutton
end
function SliderComponent:initRightButton(normalfile,pressfile,disablefile,path)
	if self.m_rightbutton then return end
	local rightbutton = display.newButton(normalfile,pressfile,disablefile,path)
	rightbutton:setAnchorPoint(cc.p(1, 0.5))
	self:addChild(rightbutton)
	rightbutton:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then
			rightbutton:runAction(cc.Sequence:create(
				{
					cc.DelayTime:create(0.3),
					cc.CallFunc:create(function() 
						rightbutton.m_timehandler = timeup(function(t)
							self:setPercent(self:getPercent() + self.m_pervalue)
						end,0,false)
					end)
				}
			))
		elseif e == ccui.TouchEventType.ended then
			rightbutton:stopAllActions()
			if rightbutton.m_timehandler then
				timestop(rightbutton.m_timehandler)
				rightbutton.m_timehandler = nil
			else
				self:setPercent(self:getPercent() + self.m_pervalue)
			end
		elseif e == ccui.TouchEventType.canceled then
			rightbutton:stopAllActions()
			if rightbutton.m_timehandler then
				timestop(rightbutton.m_timehandler)
				rightbutton.m_timehandler = nil
			end
		end
	end)
	
	self.m_rightbutton = rightbutton
end
function SliderComponent:upView()
	local size = self:getContentSize()
	self.m_leftbutton:setPosition(cc.p(0,size.height*0.5))
	self.m_rightbutton:setPosition(cc.p(self:getContentSize().width,size.height*0.5))
	self.m_slider:setPosition(cc.p(size.width*0.5,size.height*0.5))
end
function SliderComponent:onCleanup()
	self:removeAllEventListeners()
	self.m_leftButton,self.m_rightButton,self.m_slider = nil
end
return SliderComponent