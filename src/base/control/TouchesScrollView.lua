--[[
*	多点触控滚动容器（可移动，缩放）
*	该容器本身不会执行缩放（本身执行缩放会出现不可预知的问题），只会执行移动。
*	显示内容的缩放 和 移动边界判断 需要重载 excuteScale 和 excuteScroll 方法
*	@author：lqh
]]
local TouchesScrollView = class("TouchesScrollView",function()
	local scrollview = cc.Layer:create()
	scrollview:setTouchEnabled(true)
	scrollview:setTouchMode(cc.EVENT_TOUCH_ALL_AT_ONCE)
	return scrollview
end)
TouchesScrollView.m_scaleSteep 		= 0.04		--默认缩放频率
TouchesScrollView.m_currentScale 	= 1			--默认当前缩放值
TouchesScrollView.m_touchenabled 	= 0.04		--默认接收触摸事件

function TouchesScrollView:ctor()
	self.m_status = {
		active 	= false,		--是否正在移动或缩放(当容器移动，或缩放，该值为置为true)
		childtouch = false		--touch子对象是否已经触摸(防止重叠)
	}
	
	local localBeganPoint,localMovePoint,distance,dx,dy
	local localsize = 0
	--触摸开始监听
	local function onTouchesBegan(touches,event)
		if not self.m_touchenabled then return false end
		
		local size = #touches
		localsize = localsize + size
		if distance then return end
		if size > 1 then
			local p1 = touches[1]:getLocation()
			local p2 = touches[2]:getLocation()
			distance = (p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y)
			--记录偏移
			dx = (p1.x + p2.x)/2 - self:getPositionX()
			dy = (p1.y + p2.y)/2 - self:getPositionY()
			localBeganPoint = nil
			self.m_status.active = true
		else
			--andriod平台多点触摸，触摸点是依次传出
			if not localBeganPoint then
				localBeganPoint = touches[1]:getLocation()
			else
				local p2 = touches[1]:getLocation()
				distance = (localBeganPoint.x - p2.x)*(localBeganPoint.x - p2.x) + (localBeganPoint.y - p2.y)*(localBeganPoint.y - p2.y)
				--记录偏移
				dx = (localBeganPoint.x + p2.x)/2 - self:getPositionX()
				dy = (localBeganPoint.y + p2.y)/2 - self:getPositionY()
				localBeganPoint = nil
				self.m_status.active = true
			end
		end
		self:touchBegan()
	end
	--触摸移动监听
	local function onTouchesMoved(touches,event)
		if not self.m_touchenabled then return end
		
		local size = #touches
		if size > 1 then
			--缩放
			if not distance then return end
			local touche_1,touche_2
			for i = 1,#touches do
				if touches[i]:getId() == 0 then
					touche_1 = touches[i]
				elseif touches[i]:getId() == 1 then
					touche_2 = touches[i]
				end
			end
			if not touche_1 or not touche_2 then return end
			local p1 = touche_1:getLocation()
			local p2 = touche_2:getLocation()
			local tempdistance = (p1.x - p2.x)*(p1.x - p2.x) + (p1.y - p2.y)*(p1.y - p2.y)
			local temp = math.sqrt(math.abs(tempdistance - distance))
			--当移动距离大于3像素，则开始执行一次缩放
			if temp > 3 then
				if tempdistance > distance then
					self:excuteScale(self.m_currentScale + self.m_scaleSteep)
				else
					self:excuteScale(self.m_currentScale - self.m_scaleSteep)
				end
				--边界内， 保持偏移
				self:excuteScroll(cc.p((p1.x+p2.x)/2 - dx,(p1.y+p2.y)/2 - dy))
				distance = tempdistance
			end
		else
			--移动
			if not localBeganPoint or distance then return end
			
			local movep = touches[1]:getLocation()
			if not localMovePoint then 
				--设置移动阈值 为 8，即移动 >=8，不应该触发子控件的点击事件
				if math.abs(movep.x - localBeganPoint.x) >= 8 or math.abs(localBeganPoint.y - movep.y) >= 8 then
					self.m_status.active = true
					localMovePoint = movep
				end
			elseif localMovePoint then
				local x,y = self:getPosition()
				self:excuteScroll(cc.p(x + (movep.x - localMovePoint.x),y + (movep.y - localMovePoint.y)))
				localMovePoint = movep
			end
		end
	end
	--触摸结束监听
	local function onTouchesEnded(touches,event)
		localsize = localsize - #touches
		if localsize > 0 then return end
		localsize = 0
		self.m_status.active = false
		localBeganPoint,localMovePoint,distance = nil
	end
	
	local listener = cc.EventListenerTouchAllAtOnce:create()
	listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN)
	listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED)
	listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED)
	local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
end
--在多点触摸中需要添加触摸对象
function TouchesScrollView:addTouchChild(child)
	child:setParentStatus(self.m_status)
	self:addChild(child)
end
function TouchesScrollView:relateTouchChild(child)
	child:setParentStatus(self.m_status)
end
function TouchesScrollView:setTouchEnabled(value)
	self.m_touchenabled = value
end
--设置缩放频率
function TouchesScrollView:setScaleSteep(value)
	self.m_scaleSteep = value or self.m_scaleSteep
end
--设置当前缩放值
function TouchesScrollView:setCurrentScale(value)
	self.m_currentScale = value or self.m_currentScale
end
function TouchesScrollView:getCurrentScale(value)
	return self.m_currentScale
end
--@need override
function TouchesScrollView:touchBegan()
end
--[[
 *	执行缩放 
 *	@override ： 需要复写
 *	@param：scale 缩放值
]]
function TouchesScrollView:excuteScale(scale)
	
end
--[[
 *	执行移动，该方法执行最后 应该设置容器当前的坐标
 *	@override ：需要复写
 *	@param：point
]]
function TouchesScrollView:excuteScroll(point)
	
end

return TouchesScrollView
