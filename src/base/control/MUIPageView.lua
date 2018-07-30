--[[
*	翻页容器
*	派发4个事件
*		ScrollNextBegan		事件 向后翻页开始
*		ScrollNextEnd		事件 向后翻页结束
*		ScrollFrontBegan	事件 向前翻页开始
*		ScrollFrontEnd		事件 向前翻页结束
*	@author：lqh
]]
local MUIPageView = class("MUIPageView",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function() 
	local layout = display.newLayout()
	layout:setClippingEnabled(true)
	layout:setTouchEnabled(true)
	layout.m_setContentSize = layout.setContentSize
	return layout
end)

-- ----------------------event 事件-------------------------------------
MUIPageView.EVT_NEXTBEGAN		= "ScrollNextBegan"			
MUIPageView.EVT_NEXTEND			= "ScrollNextEnd"		
MUIPageView.EVT_FRONTBEGAN		= "ScrollFrontBegan"			
MUIPageView.EVT_FRONTEND		= "ScrollFrontEnd"	
-- ---------------------------------------------------------------------

function MUIPageView.extend(layout)
	layout:setClippingEnabled(true)
	layout:setTouchEnabled(true)
	layout.m_setContentSize = layout.setContentSize
	setmetatableex(layout,MUIPageView)
	layout:ctor()
	return layout
end
function MUIPageView:ctor()
	self:super("ctor")
	
	self.m_pages = {}
	self.m_currentIndex = 1
	local innercontainer = display.newLayout()
	self:addChild(innercontainer)
	self.m_innercontainer = innercontainer
end
--设置是否可以循环翻页
function MUIPageView:setIsLoop(value)
	self.m_isLoop = value
end
function MUIPageView:setContentSize(size)
	self:m_setContentSize(size)
	--布局重置
	local len,position = #self.m_pages,cc.p(0,0)
	local page,pageSize,pageAnchor
	for i = 1,len do
		page = self.m_pages[i]
		pageSize = page:getContentSize()
		pageAnchor = page:getAnchorPoint()
		
		position.x = size.width*(i - 0.5) + pageSize.width*(pageAnchor.x - 0.5)
		position.y = size.height*0.5 + pageSize.height*(pageAnchor.y - 0.5)
		
		page:setPosition(position)
	end
	self.m_innercontainer:setPositionX(size.width*(self.m_currentIndex - 1))
end
--设置内置容器 尺寸
function MUIPageView:setInnerSize(size)
	self.m_innercontainer:setContentSize(size)
end
--页尾添加一页
function MUIPageView:pushPage(page)
	local len = #self.m_pages
	local size,pageSize,pageAnchor = self:getContentSize(),page:getContentSize(),page:getAnchorPoint()
	table.insert(self.m_pages,page)
	
	page:setPosition(cc.p(size.width*(len + 0.5) + pageSize.width*(pageAnchor.x - 0.5),size.height*0.5 + pageSize.height*(pageAnchor.y - 0.5)))
	self.m_innercontainer:addChild(page)
end
--插入一页
function MUIPageView:insertPage(page,index)
	if index > #self.m_pages then
		self:pushChild(page)
		return
	end
	table.insert(self.m_pages,index,page)
	self.m_innercontainer:addChild(page)
	--布局重置
	local len,size,position = #self.m_pages,self:getContentSize(),cc.p(0,0)
	local page,pageSize,pageAnchor
	for i = index,len do
		page = self.m_pages[i]
		pageSize = page:getContentSize()
		pageAnchor = page:getAnchorPoint()
		
		position.x = size.width*(i - 0.5) + pageSize.width*(pageAnchor.x - 0.5)
		position.y = size.height*0.5 + pageSize.height*(pageAnchor.y - 0.5)
		
		page:setPosition(position)
	end
end
--翻到下页
function MUIPageView:scrollNextPage()
	if self.m_isAction or (not self.m_isLoop and self.m_currentIndex >= #self.m_pages) then
		return
	end
	
	local nextPageIndex,actionEndX
	local page,oldX
	if self.m_isLoop and self.m_currentIndex >= #self.m_pages then
		nextPageIndex = 1
		page = self.m_pages[self.m_currentIndex]
		oldX = page:getPositionX()
		
		page:setPositionX(self:getContentSize().width*-0.5 + page:getContentSize().width*(page:getAnchorPoint().x - 0.5))
		self.m_innercontainer:setPositionX(self:getContentSize().width)
		
		actionEndX = 0
	else
		nextPageIndex = self.m_currentIndex + 1
		actionEndX = -self:getContentSize().width * self.m_currentIndex
	end
		
	self.m_innercontainer:runAction(cc.Sequence:create({
		cc.MoveTo:create(0.25,cc.p(actionEndX - 20,0)),
		cc.MoveTo:create(0.1 ,cc.p(actionEndX     ,0)),
		cc.CallFunc:create(function() 
			self.m_currentIndex = nextPageIndex
			self.m_isAction = false
			if nextPageIndex == 1 then
				page:setPositionX(oldX)
			end
			self:dispatchEvent(self.EVT_NEXTEND,self,nextPageIndex)
		end)
	}))
	self.m_isAction = true
	self:dispatchEvent(self.EVT_NEXTBEGAN,self,nextPageIndex)
end
--翻到上页
function MUIPageView:scrollFrontPage()
	if self.m_isAction or (not self.m_isLoop and self.m_currentIndex <= 1) then
		return
	end
	local upPageIndex,actionEndX
	local page,oldX
	if self.m_isLoop and self.m_currentIndex <= 1 then
		local len = #self.m_pages
		upPageIndex = len
		page = self.m_pages[self.m_currentIndex]
		oldX = page:getPositionX()
		
		page:setPositionX(self:getContentSize().width*(len + 0.5) + page:getContentSize().width*(page:getAnchorPoint().x - 0.5))
		self.m_innercontainer:setPositionX(-self:getContentSize().width*len)
		actionEndX = -self:getContentSize().width*(len - 1)
	else
		upPageIndex = self.m_currentIndex - 1
		actionEndX = -self:getContentSize().width * (self.m_currentIndex - 2)
	end
	
	
	local size = self:getContentSize()
	self.m_innercontainer:runAction(cc.Sequence:create({
		cc.MoveTo:create(0.25,cc.p(actionEndX + 20,0)),
		cc.MoveTo:create(0.1 ,cc.p(actionEndX     ,0)),
		cc.CallFunc:create(function() 
			self.m_currentIndex = upPageIndex
			self.m_isAction = false
			if upPageIndex == #self.m_pages then
				page:setPositionX(oldX)
			end
			self:dispatchEvent(self.EVT_FRONTEND,self,upPageIndex)
		end)
	}))
	self.m_isAction = true
	self:dispatchEvent(self.EVT_FRONTBEGAN,self,upPageIndex)
end
--跳转至某页
function MUIPageView:jumpToPage(index)
	self.m_currentIndex = index
	
	self.m_innercontainer:setPositionX(-self:getContentSize().width*(index - 1))
end
--获取指定页的显示对象
function MUIPageView:getPage(index)
	return self.m_pages[index]
end
--获取当前页的显示对象
function MUIPageView:getCurrentPage()
	return self.m_pages[self.m_currentIndex]
end
--获取当前页标
function MUIPageView:getCurrentIndex()
	return self.m_currentIndex
end
function MUIPageView:onExit()
	self:removeAllEventListeners()
end

return MUIPageView


