--[[
*	树形列表
*	@author：lqh
]]
local ListTreeView = class("ListTreeView",function() 
	return display.newListView()
end)
local RootNode

function ListTreeView.extend(scrollList)
	for k,v in pairs(ListTreeView) do 	
		if k ~= "new" then
			scrollList[k] = v 
		end
	end
	return scrollList
end
--[[
 *	从树形列表创建并获取一个根节点
 *	需要外部扩展根节点的显示内容
]]
function ListTreeView:createRootNode(size)				
	local rootNode = RootNode.new(self,self.m_duration or 0.3)
	if size then rootNode:setContentSize(size) end
	self:pushBackCustomItem(rootNode)
	return rootNode
end
--[[
 *	设置动画持续时间
]]
function ListTreeView:setDuration(value)
	self.m_duration = value
end


--[[
*	根节点layout,用于树形列表
*	派发4个事件
*		attach			事件		展开 
*		detach			事件		缩进 
*		attachover		事件		展开动画结束
*		detachover		事件		收缩动画结束 
]]
RootNode = class("RootNode",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function() 
	return display.newLayout()
end)

-- ----------------------event 事件-------------------------------------
RootNode.EVT_ATTACH			= "attach"			
RootNode.EVT_DETACH			= "detach"		
RootNode.EVT_ATTACHOVER		= "attachover"			
RootNode.EVT_DETACHOVER		= "detachover"	
-- ---------------------------------------------------------------------

function RootNode:ctor(list,duration)
	self:super("ctor")
	self:setTouchEnabled(true)
	self.m_duration = duration
	self.m_parentList = list
	self.m_state = 0
end
--创建并添加一个叶子节点
function RootNode:createLeafNode(size)
	if self.m_leafNode then
		self.m_leafNode:removeAllChildren()
		self.m_leafCurrentHeight = self.m_leafNode:getContentSize().height
	else
		local leafNode = ccui.Layout:create()
		leafNode:setClippingEnabled(true)
		self.m_leafNode = leafNode
		self.m_leafCurrentHeight = 0
		self.m_parentList:insertCustomItem(leafNode,self.m_parentList:getIndex(self) + 1)
	end
	if size then self.m_leafNode:setContentSize(size) end
	return self.m_leafNode
end
function RootNode:getState()
	return self.m_state
end
function RootNode:setDuration(value)
	self.m_duration = value
end
function RootNode:getDuration()
	return self.m_duration
end
function RootNode:changeStatus()
	if not self.m_leafNode then return end
	self:removeTimeHandler()
	self.m_state = (self.m_state + 1)%2
	local leafNode = self.m_leafNode
	local leafSize = leafNode:getContentSize()
	--高度变化速率，当前高度
	local heightStep,curHeight
	local count = math.ceil(60 * self.m_duration)
	if count == 0 then
		heightStep = 0
	else
		heightStep = math.ceil(leafSize.height/count)
	end
	
	--执行动画关闭叶子节点
	if self.m_state == 0 then		
		self:dispatchEvent(self.EVT_DETACH,self.m_leafNode)	
		curHeight = leafSize.height
		if heightStep == 0 then 
			--无动画
			self:dispatchEvent(self.EVT_DETACHOVER,leafNode)	
			self.m_leafNode = nil
			self.m_parentList:removeItem(self.m_parentList:getIndex(leafNode))
			return 
		end
		heightStep = math.ceil(leafNode.m_realHeight/count)
		
		self.m_actionTimeHandler = timeup(function() 
			curHeight = curHeight - heightStep
			if curHeight > 0 then
				leafNode:setContentSize(cc.size(leafSize.width,curHeight))
				self.m_parentList:requestDoLayout()
			else
				self:removeTimeHandler()
				self:dispatchEvent(self.EVT_DETACHOVER,leafNode)	
				self.m_leafNode = nil
				self.m_parentList:removeItem(self.m_parentList:getIndex(leafNode))
			end
		end,0,false)
	else--执行打开动画			
		curHeight = self.m_leafCurrentHeight
		if heightStep == 0 then 
			--无动画
			self:dispatchEvent(self.EVT_ATTACHOVER,leafNode)	
			return 
		end
		--记录真实高
		leafNode.m_realHeight = leafSize.height
		leafNode:setContentSize(cc.size(leafSize.width,curHeight))
		self:dispatchEvent(self.EVT_ATTACH,leafNode)
		
		self.m_actionTimeHandler = timeup(function() 
			curHeight = curHeight + heightStep
			
			if curHeight < leafSize.height then
				leafNode:setContentSize(cc.size(leafSize.width,curHeight))
			else
				self:removeTimeHandler()
				leafNode:setContentSize(cc.size(leafSize.width,leafSize.height))
				self:dispatchEvent(self.EVT_ATTACHOVER,leafNode)	
			end
			self.m_parentList:requestDoLayout()
		end,0,false)
	end
end
--将该节点滚动到抬头位置
function RootNode:scrollToTitle()
	--scrollview 尺寸
	local size = self.m_parentList:getContentSize()
	--scrollview 和内置容器的高度差
	local dh = self.m_parentList:getInnerContainer():getContentSize().height - size.height
	if dh == 0 then return end
	
	--scrollview y坐标
	local _,y = self.m_parentList:getPosition()
	--scrollview 左上角位置
	y = self.m_parentList:getParent():convertToWorldSpace(cc.p(0,y + size.height*(1 - self.m_parentList:getAnchorPoint().y))).y
	
	--自身坐标
	local _,sy = self:getPosition()
	--自身左上角位置
	sy = self:getParent():convertToWorldSpace(cc.p(0,sy + self:getContentSize().height*(1 - self:getAnchorPoint().y))).y
	
	if y ~= sy then
		--内置容器坐标
		local _,cy = self.m_parentList:getInnerContainer():getPosition()
		--需要滚动的距离
		cy = cy + (y - sy)
		if cy > 0 then cy = 0 end
		self.m_parentList:scrollToPercentVertical(100 - (-cy/dh*100),0.8,true)
	end
end
function RootNode:removeTimeHandler()
	if not self.m_actionTimeHandler then return end
	timestop(self.m_actionTimeHandler) 
	self.m_actionTimeHandler = nil
end
function RootNode:onExit()
	self:removeTimeHandler()
	self.m_leafNode = nil
end

return ListTreeView