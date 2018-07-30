--[[
*	自定义扇形进度条
*	使用较大的半径来绘制遮罩圆，大量减少了verts数量
*	派发事件
*		set 	事件，直接设置时派发
*		began 	事件，动作开始时派发
*		change	事件，动作执行中派发
*		end		事件，动作结束时派发
*	@author:lqh
]]
local RadialProgressComponent = class("RadialProgressComponent",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function() 
	local continer = display.newLayout()
	continer:setAnchorPoint(cc.p(0.5, 0.5))
	return continer
end)
local RESET_INTERVAL = 0.5
local THRESHOLD      = math.pi/180	--绘制角度变化阈值，1度

-- ----------------------event 事件-------------------------------------
RadialProgressComponent.EVT_SET			= "set"			
RadialProgressComponent.EVT_BEGAN		= "began"		
RadialProgressComponent.EVT_END			= "end"			
RadialProgressComponent.EVT_CHANGE		= "change"		
-- ---------------------------------------------------------------------

RadialProgressComponent.m_direction 	= -1			--进度条方向
RadialProgressComponent.m_baseRads 		= math.pi*0.5	--扇形遮罩初始弧度
RadialProgressComponent.m_center 		= nil			--扇形遮罩中心点
RadialProgressComponent.m_radius 		= 0				--扇形遮罩半径
RadialProgressComponent.m_rads			= 0				--当前弧度
RadialProgressComponent.m_duration		= 2				--一周所用时间
RadialProgressComponent.m_resetDrawCd   = RESET_INTERVAL--执行动作时，每隔0.5s重置一次绘制顶点数，优化顶点数量
RadialProgressComponent.m_timehandler 	= nil

--获取一个样板
function RadialProgressComponent.getSample()			
	local sample = RadialProgressComponent.new("uielement_029.png",1)
	sample:setRadialBaseAngle(-90)
	return sample		
end
--[[
*	@param p1 可以是sprite对象或者字符串
]]
function RadialProgressComponent:ctor(p1)
	self:super("ctor")
	
	local drawNode = cc.DrawNode:create()
	self.m_drawNode = drawNode
	
	local clippNode = cc.ClippingNode:create(drawNode)
	self:addChild(clippNode)
	self.m_clippNode = clippNode
	self:setInverted(true)
	
	self:setBar(p1)
	self:m_initUpdateParam(0)
end
--[[
*	设置当前百分比
*	@param percent 0~1.0
]]
function RadialProgressComponent:setPercent(percent)
	self:setRads(percent*2*math.pi)
end
--[[
*	设置当前角度
*	@param angle 0~360
]]
function RadialProgressComponent:setAngle(angle)
	self:setRads(angle/180*math.pi)
end
--[[
*	设置角度
*	@param rads 0~2π
]]
function RadialProgressComponent:setRads(rads)
	if rads < 0 then rads = 0 end
	if rads == self.m_rads then return end
	self:m_removeTimeHandler()
	self:m_setRads(rads)
end
--获取当前百分比
function RadialProgressComponent:getPercent()
	return self.m_rads/(2*math.pi)
end
--获取当前角度
function RadialProgressComponent:getAngle()
	return self.m_rads/math.pi*180
end
--获取当前弧度
function RadialProgressComponent:getRads()
	return self.m_rads
end
--获取当前倒计时
function RadialProgressComponent:getCountDown()
	return (self.m_targetRads - self.m_rads)/self.m_diffRads * self.m_currentDuration
end
--[[
*	设置动作条，尽量使用源生sprite对象
*	@param p1 可以是sprite对象或者字符串
]]
function RadialProgressComponent:setBar(p1)
	if not p1 then return end
	local tpname = type(p1)
	local bar
	if tpname == "userdata" then
		bar = p1
	elseif tpname == "string" then
		bar = display.newSprite(p1)
	end
	if self.m_bar then self.m_bar:removeFromParent(true) end
	self.m_clippNode:addChild(bar)
	
	local size = bar:getContentSize()
	self:setContentSize(size)
	
	self.m_radius = math.max(size.width,size.height)
	self.m_bar = bar
	self.m_center = cc.p(0,0)
	
	self.m_clippNode:setPosition(cc.p(size.width*0.5,size.height*0.5))
end
--[[
*	设置扇形的起点角度，默认0度，即水平
*	@param angle 角度
]]
function RadialProgressComponent:setRadialBaseAngle(angle)
	--配合c2dx的习惯，angle取反一次
	self.m_baseRads = 2*math.pi*-angle/360
	
	self.m_rads 	= 0
end
--[[
*	设置方向，默认顺时针
*	@param b boolean值，true：顺时针，false：逆时针
]]
function RadialProgressComponent:setDirection(b)
	if b then
		self.m_direction = -1
	else
		self.m_direction = 1
	end
	
	self.m_rads 	= 0
end
--手动修改扇形遮罩半径，默认为bar的最长边
function RadialProgressComponent:setRadialRadius(value)
	self.m_radius = value
	
	self.m_drawNode:clear()
end
--手动修改扇形遮罩的中心点，默认在bar的中心点
function RadialProgressComponent:setRadialCenter(x,y)
	if not self.m_bar then return end
	local size = self.m_bar:getContentSize()
	self.m_center.x,self.m_center.y = x - size.width*0.5,y - size.height*0.5
	
	self.m_drawNode:clear()
end
--[[
*	设置是扇形进度条是出现还是消失，默认消失
*	@param value true是消失，false是出现
]]
function RadialProgressComponent:setInverted(value)
	self.m_clippNode:setInverted(value)
end
--[[
*	设置读条一周的默认时间(默认2s)
*	@param duration  >0
]]
function RadialProgressComponent:setDuration(duration)
	if duration <= 0 then return end
	self.m_duration = duration
end

--@privete 
function RadialProgressComponent:m_setRads(radsValue,notDispachEvent)
	self.m_rads = radsValue
	
	self.m_drawNode:clear()
	if radsValue == 0 then return end
	self.m_drawNode:clear()
	
	--因为绘制遮罩半径远大于图片本身，所以使用较大增长值，提高绘制效率，减少vert数据
	local perRads = math.pi*0.25	--45°
	--起始点
	local center = cc.p(self.m_center.x,self.m_center.y)
	local rads = self.m_baseRads
	local points = {center,cc.p(center.x + self.m_radius*math.cos(rads),center.y + self.m_radius*math.sin(rads))}
	
	while true do
		radsValue = radsValue - perRads
		if radsValue > 0 then
			rads = rads + perRads*self.m_direction
		else
			rads = self.m_baseRads + self.m_rads*self.m_direction
		end
		table.insert(points,cc.p(center.x + self.m_radius*math.cos(rads),center.y + self.m_radius*math.sin(rads)))
		if radsValue <= 0 then break end
	end
	self.m_drawNode:clear()
	self.m_drawNode:drawSolidPoly(points, #points,cc.c4f(1,0,0,1))
	
	if not notDispachEvent then self:dispatchEvent(self.EVT_SET,self) end
end
--[[
*	设置一个进度动作
*	@param fromPercent	起始百分比 0~1.0
*	@param toPercent	结束百分比 0~1.0
*	@param duration		持续时间，可以忽略
]]
function RadialProgressComponent:setPercentFrom(fromPercent,toPercent,duration)
	self:setRadsFrom(fromPercent*2*math.pi,toPercent*2*math.pi,duration)
end
--[[
*	设置一个进度动作
*	@param fromPercent	起始度数	0~360
*	@param toPercent	结束度数	0~360
*	@param duration		持续时间，可以忽略
]]
function RadialProgressComponent:setAngleFrom(fromAngle,toAngle,duration)
	self:setRadsFrom(fromAngle/180*math.pi,toAngle/180*math.pi,duration)
end
--[[
*	设置一个进度动作
*	@param fromRads 	起始弧度	0~2π
*	@param toRads   	结束弧度	0~2π
*	@param duration		持续时间，可以忽略
]]
function RadialProgressComponent:setRadsFrom(fromRads,toRads,duration)
	if fromRads < 0 then fromRads = 0 end
	if toRads < 0 then toRads = 0 end
	--起始角度大于结束角度直接返回错误
	if fromRads > toRads then error(string.format("<RadialProgressComponent>:fromRads(%s) is large for toRads(%s) !!!!",fromRads,toRads)) end
	self:m_removeTimeHandler()
	
	self:m_setRads(fromRads,true)
	self:m_initUpdateParam(toRads,duration)
	
	self.m_timehandler = timeup(self.m_onUpdate,0,self)
	self:dispatchEvent(self.EVT_BEGAN,self)
end
--@privete 初始化动作的一些参数
function RadialProgressComponent:m_initUpdateParam(targetRads,duration)
	--目标弧度
	self.m_targetRads = targetRads
	
	if duration and duration~=0 then
		--持续时间
		self.m_currentDuration = duration
		--弧度差
		self.m_diffRads = self.m_targetRads - self.m_rads
	else
		--采用设置默认设置的持续时间
		self.m_currentDuration = self.m_duration
		--弧度差为2π 因为设置的默认时间是一周的时间
		self.m_diffRads = math.pi*2
	end
	--每秒弧度变化率
	self.m_perRads = self.m_diffRads/self.m_currentDuration
	self.m_resetDrawCd = RESET_INTERVAL	
	--记录上一次绘制的角度
	self.m_drawRads = self.m_rads

	local curentRads = self.m_baseRads + self.m_rads*self.m_direction
	self.m_frontPoint = cc.p(
		self.m_center.x + self.m_radius*math.cos(curentRads),
		self.m_center.y + self.m_radius*math.sin(curentRads)
	)	
end
--@private 帧函数
function RadialProgressComponent:m_onUpdate(interval)
	self.m_resetDrawCd = self.m_resetDrawCd - interval
	
	self.m_rads = self.m_rads + interval*self.m_perRads
	if self.m_rads > self.m_targetRads then
		self.m_rads = self.m_targetRads
	end
	
	if self.m_rads >= self.m_targetRads then
		self:m_removeTimeHandler()
		self:m_setRads(self.m_rads,true)
		self:dispatchEvent(self.EVT_END,self)
	else
		if self.m_rads - self.m_drawRads >= THRESHOLD then
			local rads = self.m_baseRads + self.m_rads*self.m_direction
			local p = cc.p(self.m_center.x + self.m_radius*math.cos(rads),self.m_center.y + self.m_radius*math.sin(rads))
			if self.m_resetDrawCd <= 0 then
				self.m_resetDrawCd = RESET_INTERVAL
				self:m_setRads(self.m_rads,true)
			else
				self.m_drawNode:drawSolidPoly({self.m_center,self.m_frontPoint,p}, 3,cc.c4f(1,0,0,1))
			end
			self.m_frontPoint = p
			self.m_drawRads = self.m_rads
		end
		self:dispatchEvent(self.EVT_CHANGE,self)
	end
end

--[[
*	@private 
*	停止时间监听
]]
function RadialProgressComponent:m_removeTimeHandler()
	if not self.m_timehandler then return end
	timestop(self.m_timehandler)
	self.m_timehandler = nil
end
function RadialProgressComponent:onCleanup()
	self:m_removeTimeHandler()
	self:removeAllEventListeners()
end
return RadialProgressComponent