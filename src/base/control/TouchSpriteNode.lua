--[[
*	源生点击对象
*	@author：lqh
]]
local TouchSpriteNode = class("TouchSpriteNode",function() 
	return display.newSprite()
end)

function TouchSpriteNode:ctor()
	
end
function TouchSpriteNode:initTouch()
    self.m_touchEnabled = true
	--记录点击开始点
	local localBeganPoint
	--点击开始监听
	local function ontouchBegan(touch,event)
		if not self.m_touchEnabled or self.m_parentStatus.childtouch then return false end
		local point = touch:getLocation()
		if self.m_parentStatus.active or not self:containsTouchLocation(point) then
            return false
        end
        self.m_parentStatus.childtouch = true
		localBeganPoint = point
		return true
	end
	--点击结束监听
	local function ontouchEnd(touch,event)
		self.m_parentStatus.childtouch = nil
		if localBeganPoint and not self.m_parentStatus.active then
			if not self:containsTouchLocation(touch:getLocation(),true) then 
				localBeganPoint = nil
				return
			end
			
			self:touchEnded()
		end
		localBeganPoint = nil
	end
	local  listenner = cc.EventListenerTouchOneByOne:create()
--  listenner:setSwallowTouches(true)
    listenner:registerScriptHandler(ontouchBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    listenner:registerScriptHandler(ontouchEnd,cc.Handler.EVENT_TOUCH_ENDED)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listenner, self)
end
--设置夫对象状态
function TouchSpriteNode:setParentStatus(status)
	self.m_parentStatus = status
end
--[[
 *	点击成功
 *	@override
]]
function TouchSpriteNode:touchEnded()
	
end
function TouchSpriteNode:setTouchEnabled(value)
	self.m_touchEnabled = value
end
function TouchSpriteNode:containsTouchLocation(point)
	point = self:convertToNodeSpace(point)
    local s = self:getContentSize()
    local touchRect = cc.rect(0, 0, s.width, s.height)
    local b = cc.rectContainsPoint(touchRect, point)
    if b and self.m_polygon then
    	return self:m_polygonHitePointTest(point)
    end
    return b
end
--设置多边形数据
function TouchSpriteNode:setPolygon(pointlist)
	self.m_polygon = pointlist
end
--@private 检测点 是否在任意多边形内部
function TouchSpriteNode:m_polygonHitePointTest(point)
	local p1,p2
	local arg = self.m_polygon
	local len,count = #arg,0
	local index = len
	
	for i = 1,len do
		p1,p2 = arg[i],arg[index]
		index = i
		 --		p1p2 在同一水平线上	或者  	交点在p1p2延长线上 
		if not ((p1.y == p2.y) or (point.y < math.min(p1.y,p2.y) or point.y >= math.max(p1.y,p2.y))) then
			--交点的 X 坐标
			local x = (point.y-p1.y)*(p2.x-p1.x)/(p2.y-p1.y)+p1.x
			if x > point.x then 		--向右水平方向发射射线
				count = count + 1
			end
		end
	end
	return count%2 == 1
end
return TouchSpriteNode
