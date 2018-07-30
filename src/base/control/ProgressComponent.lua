--[[
*	自定义进度条
*	派发事件
*		set 		事件，直接设置时派发
*		began 		事件，动作开始时派发
*		change		事件，动作执行中派发
*		terminal	事件，动作执行到达端点时派发
*		end			事件，动作结束时派发
*	@author：lqh
]]
local ProgressComponent = class("ProgressComponent",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function() 
	local continer = display.newLayout()
	continer:setAnchorPoint(cc.p(0.5, 0.5))
	return continer
end)

-- ----------------------event 事件-------------------------------------
ProgressComponent.EVT_SET			= "set"			
ProgressComponent.EVT_BEGAN			= "began"		
ProgressComponent.EVT_END			= "end"			
ProgressComponent.EVT_TERMINAL		= "terminal"	
ProgressComponent.EVT_CHANGE		= "change"		
-- ---------------------------------------------------------------------

ProgressComponent.m_direction 		= 1				--方向
ProgressComponent.m_percent 		= 1				--当前百分比 0~1
ProgressComponent.m_duration 		= 2				--增长满一次所用时间
ProgressComponent.m_timehandler 	= nil

--获取一个模板进度条
function ProgressComponent.getSample()							
	local bar = display.newImage("progress_bar_1.png")
	bar:setScale9Enabled(true)
	bar:setContentSize(cc.size(300,10))
	local sample = ProgressComponent.new(bar)
	return sample
end
--[[
*	@param p1 可以是sprite对象或者字符串
]]
function ProgressComponent:ctor(p1)
	self:super("ctor")
	
	local drawNode = cc.DrawNode:create()
	self.m_drawNode = drawNode
	
	local clippNode = cc.ClippingNode:create(drawNode)
	self:addChild(clippNode)
	clippNode:setInverted(true)
	self.m_clippNode = clippNode
	
	self:setBar(p1)
end
--[[
*	设置动作条，尽量使用源生sprite对象
*	@param p1 可以是sprite对象或者字符串
]]
function ProgressComponent:setBar(p1)
	if not p1 then return end
	local tpname = type(p1)
	local bar
	if tpname == "userdata" then
		bar = p1
	elseif tpname == "string" then
		bar = display.newSprite(p1)
	end
	
	if self.m_bar then self.m_bar:removeFromParent(true) end
	bar:setAnchorPoint(cc.p(0, 0))
	bar:setPosition(cc.p(0,0))
	self.m_clippNode:addChild(bar)
	
	local size = bar:getContentSize()
	self:setContentSize(size)
	self.m_drawNode:drawSolidPoly({cc.p(0,0),cc.p(size.width,0),cc.p(size.width,size.height),cc.p(0,size.height)}, 4,cc.c4f(1,0,0,1))
	self.m_bar = bar
	self.m_size = size
	self:setDirection(self.m_direction)
end
function ProgressComponent:getPercent()
	return self.m_percent
end
--获取保留3为小数的percent值
function ProgressComponent:getPercent3f()
	return tonum(string.format("%.3f",self.m_percent))
end
--[[
*	设置进度条方向，可以复合方向
*	---## 水平方向:1(从左向右) , 2(从右向左)) , 3(从下向上),4(从上向下)
*	@param value 方向(默认1)
]]
function ProgressComponent:setDirection(value)
	self.m_percent = 1
	self.m_direction = value
	--方向系数
	self.m_ration = 1
	if value <= 2 then
		if value == 2 then self.m_ration = -1 end
		self.m_drawNode:setPosition(cc.p(self.m_size.width*self.m_ration,0))
	else
		if value == 4 then self.m_ration = -1 end
		self.m_drawNode:setPosition(cc.p(0,self.m_size.height*self.m_ration))
	end
end
--[[
*	设置增减一次满条的时间
*	@param duration 单位秒
]]
function ProgressComponent:setDuration(duration)
	self.m_duration = duration
end
--[[
*	设置当前百分比
*	@param percent 0~1
]]
function ProgressComponent:setPercent(percent)
	if percent < 0 then percent = 0 end
	if percent > 1 then percent = 1 end
	if self.m_percent == percent then return end
	self:m_setPercent(percent)
end
--@private
function ProgressComponent:m_setPercent(percent,notDispachEvent)
	self.m_percent = percent
	local w,h = self.m_size.width,self.m_size.height
	if self.m_direction <= 2 then
		self.m_drawNode:setPositionX(percent*w*self.m_ration)
	else
		self.m_drawNode:setPositionY(percent*h*self.m_ration)
	end
	
	if not notDispachEvent then self:dispatchEvent(self.EVT_SET,self) end
end
--[[
*	设置一个动作
*	@param fromPercent		起始值
*	@param toPercent		终点值
*	@param duration			持续时间(默认setDuration设置的一次全读条时间)
*	@param fullTimes		满条或者空条次数(默认0)
*	@param isReduce			增加或者减少(默认增加)
]]
function ProgressComponent:setPercentFrom(fromPercent,toPercent,duration,fullTimes,isReduce)
	self:m_removeTimeHandler()
	if fromPercent < 0 then fromPercent = 0 end
	if fromPercent > 1 then fromPercent = 1 end
	if toPercent < 0 then toPercent = 0 end
	if toPercent > 1 then toPercent = 1 end
	
	fullTimes = fullTimes or 0
	if isReduce then
		--减
		if fromPercent < toPercent and fullTimes == 0 then fullTimes = 1 end
	else
		--增
		if fromPercent > toPercent and fullTimes == 0 then fullTimes = 1 end
	end
	self:m_setPercent(fromPercent,true)
	self:m_initUpdateParam(toPercent,duration,fullTimes,isReduce)
	
	self.m_timehandler = timeup(self.m_onUpdate,0,self)
	self:dispatchEvent(self.EVT_BEGAN,self)
end
--@privete 初始化动作的一些参数
function ProgressComponent:m_initUpdateParam(targetPercent,duration,fullTimes,isReduce)
	--计算进度差
	if fullTimes > 0 then
		if isReduce then
			--减
			self.m_difPercent = fullTimes + self.m_percent - targetPercent
		else
			--增
			self.m_difPercent = fullTimes - self.m_percent + targetPercent
		end
	else
		self.m_difPercent = math.abs(targetPercent - self.m_percent)
	end
	--目标进度值
	self.m_targetPercent = targetPercent
	self.m_drawPercent = self.m_percent
	
	--计算平均每秒增减幅度
	if duration then
		self.m_perPercent = self.m_difPercent/duration
	else
		self.m_perPercent = 1/self.m_duration
	end
	
	if isReduce then
		self.m_coef = -1
	else
		self.m_coef = 1
	end
end
--@private 帧函数
function ProgressComponent:m_onUpdate(interval)
	local dper = interval*self.m_perPercent
	self.m_difPercent = self.m_difPercent - dper
	
	if self.m_difPercent <= 0 then
		self.m_percent = self.m_targetPercent
		self:m_setPercent(self.m_percent,true)
		self:m_removeTimeHandler()
		self:dispatchEvent(self.EVT_END,self)
	else
		self.m_percent = self.m_percent + dper*self.m_coef
		if self.m_percent <= 0 and self.m_coef < 0 then 
			self.m_percent = 1 + self.m_percent
			self:m_setPercent(self.m_percent,true)
			self:dispatchEvent(self.EVT_TERMINAL,self)
		elseif self.m_percent >= 1 and self.m_coef > 0 then 
			self.m_percent = 1 - self.m_percent 
			self:m_setPercent(self.m_percent,true)
			self:dispatchEvent(self.EVT_TERMINAL,self)
		else
			self:m_setPercent(self.m_percent,true)
			self:dispatchEvent(self.EVT_CHANGE,self)
		end
	end 
end
--[[
*	@private 
*	停止时间监听
]]
function ProgressComponent:m_removeTimeHandler()
	if not self.m_timehandler then return end
	timestop(self.m_timehandler)
	self.m_timehandler = nil
end
function ProgressComponent:onCleanup()
	self:m_removeTimeHandler()
	self:removeAllEventListeners()
end
return ProgressComponent