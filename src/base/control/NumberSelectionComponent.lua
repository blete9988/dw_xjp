--[[
*	数量选择控件
*	@author：lqh
]]
local NumberSelectionComponent = class("NumberSelectionComponent",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function(size) 
	local container = display.newLayout(size or cc.size(200,50))
	container.m_setContentSize = container.setContentSize
	container:setTouchEnabled(true)
	return container
end)

function NumberSelectionComponent:ctor(size,min,max)
	self:super("ctor")
	
	size = size or cc.size(200,50)
	self.m_min = min or 0
	self.m_max = max or 100
	self.m_counts = 0
	
	local countlabel = display.newText(0)
	countlabel:setPosition(cc.p(size.width/2,size.height/2))
	self:addChild(countlabel)
	self.m_countlabel = countlabel
	
	local leftButton = display.newButton()
	leftButton:setAnchorPoint(cc.p(0, 0.5))
	leftButton:setPosition(cc.p(0,size.height/2))
	leftButton:setTouchEnabled(true)
	self:addChild(leftButton)
	self.m_leftButton = leftButton
	leftButton.express_ = function(value) 
		self.m_counts = self.m_counts - value
		if self.m_counts < self.m_min then self.m_counts = self.m_min end
		self:dispatchEvent("change",self.m_counts)
	end
	leftButton.limit_ = function(value) 
		if self.m_counts == self.m_min then return true end
	end
	
	local rightButton = display.newButton()
	rightButton:setAnchorPoint(cc.p(1, 0.5))
	rightButton:setPosition(cc.p(size.width,size.height/2))
	leftButton:setTouchEnabled(true)
	self:addChild(rightButton)
	self.m_rightButton = rightButton
	rightButton.express_ = function(value) 
		self.m_counts = self.m_counts + value
		if self.m_counts > self.m_max then self.m_counts = self.m_max end
		self:dispatchEvent("change",self.m_counts)
	end
	rightButton.limit_ = function(value) 
		if self.m_counts == self.m_max then return true end
	end
	
	local alltime,oldvalue,hold,value,step = 0,0
	local function touchlistener(t,e)
		if e == ccui.TouchEventType.began then
			oldvalue,step = 0,1
			self.m_handler = timeout(function() 
				hold = true
				self.m_handler = timeup(function(tm) 
					if t.limit_() then return end
					alltime = alltime + tm
					if alltime <= 1 then
						value = math.floor(alltime * 10)
					else
						value = math.floor(alltime * 100)
						if alltime > 2.5 then
							step = step + 1
						elseif alltime > 5 then
							step = step + 3
						end
					end
					if oldvalue ~= value then
						oldvalue = value
						t.express_(step)
						countlabel:setString(self.m_counts)
					end
				end)
			end,0.2)
		elseif e == ccui.TouchEventType.ended then
			if self.m_handler then timestop(self.m_handler) end
			if not hold and not t.limit_() then
				t.express_(1)
				countlabel:setString(self.m_counts)
			end
			alltime,self.m_handler,hold = 0
		elseif e == ccui.TouchEventType.canceled then
			if self.m_handler then timestop(self.m_handler) end
			alltime,self.m_handler,hold = 0
		end
	end
	
	leftButton:addTouchEventListener(touchlistener)
	rightButton:addTouchEventListener(touchlistener)
end
function NumberSelectionComponent:setMax(value)
	self.m_max = value or self.m_max
end
function NumberSelectionComponent:setMin(value)
	self.m_min = value or self.m_min
end
function NumberSelectionComponent:setCount(value)
	self.m_counts = value
	self.m_countlabel:setString(value)
end
function NumberSelectionComponent:getCount()
	return self.m_counts
end
--override
function NumberSelectionComponent:setContentSize(size)
	if not size then return end
	self:m_setContentSize(size)
	
	self.m_countlabel:setPosition(cc.p(size.width/2,size.height/2))
	self.m_leftButton:setPosition(cc.p(0,size.height/2))
	self.m_rightButton:setPosition(cc.p(size.width,size.height/2))
end
--设置文本属性
function NumberSelectionComponent:setLabelAttribute(size,color,fontname)
	if size then self.m_countlabel:setFontSize(size) end
	if color then self.m_countlabel:setColor(color) end
	if fontname then self.m_countlabel:setFontName(fontname) end
end
function NumberSelectionComponent:initLeftButton(normalpath,selectpath,disablepath,type)
	self.m_leftButton:init(normalpath,selectpath,disablepath,type or 1)
end
function NumberSelectionComponent:initRightButton(normalpath,selectpath,disablepath,type)
	self.m_rightButton:init(normalpath,selectpath,disablepath,type or 1)
end
function NumberSelectionComponent:onCleanup()
	if self.m_handler then timestop(self.m_handler) end
end
--获取一个简单的实例
function NumberSelectionComponent.getSample()
	local item = NumberSelectionComponent.new()
	item:initLeftButton("res/images/btn_sub.png","res/images/btn_sub.png","",0)
	item:initRightButton("res/images/btn_add.png","res/images/btn_add.png","",0)
	return item
end
return NumberSelectionComponent
