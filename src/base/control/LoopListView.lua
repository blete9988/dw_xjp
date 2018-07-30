--[[
*	循环滚动容器，解决大数据卡顿
*	##只支持 垂直方向滚动
*	##只支持 ccui.ScrollView扩展
*	@author lqh
]]
local LoopListView = class("LoopListView",require("src.base.extend.CCLayerExtend"),function() 
	local scrollview = display.newScrollView(ccui.ScrollViewDir.vertical,true)
	--setContentSize，addTouchEventListener,addEventListener这三个源生方法要被重写
	scrollview.m_setContentSize 		= scrollview.setContentSize
	scrollview.m_addTouchEventListener	= scrollview.addTouchEventListener
	scrollview.m_addEventListener		= scrollview.addEventListener
	return scrollview
end)
-- ----------------------event 事件-------------------------------------
LoopListView.EVT_UPDATE = "evt_update"
LoopListView.EVT_NEW 	= "evt_new"
-- ---------------------------------------------------------------------

--扩展一个ScrollView容器为循环滚动容器
function LoopListView.extend(target)
    --setContentSize，addTouchEventListener,addEventListener这三个源生方法要被重写
	target.m_setContentSize 		= target.setContentSize
	target.m_addTouchEventListener	= target.addTouchEventListener
	target.m_addEventListener		= target.addEventListener
	
    target:setDirection(ccui.ScrollViewDir.vertical)
	setmetatableex(target,LoopListView)
    target:init()
    return target
end
--[[
*	构造函数
*	@datas ： 数据列表
*	@initlen ： 初始化的item数量（也是最大显示数量）
*	@callback ： 监听，不能为空
]]
function LoopListView:ctor(datas,initlen,callback)
	self:super("ctor")
	
	self:init()
	self:setDatas(datas)
	self:setDefaultLength(initlen)
	self:setBufferDistance(150)
	self:setSmoothAppear()
	self.m_gap = 2
	
	self.m_isTouching = false
	self:m_addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then 
			self.m_isTouching = true
		elseif e ~= ccui.TouchEventType.moved then
			self.m_isTouching = false
		end
		if self.m_nativeTouchCallback then
			self.m_nativeTouchCallback(t,e)
		end
	end)
end
--@override native function
function LoopListView:setContentSize(size)
	self:m_setContentSize(size)
	self.m_size = cc.size(size.width,size.height)
end
--@override native function
function LoopListView:addTouchEventListener(cb)
	self.m_nativeTouchCallback = cb
end
--@override native function
function LoopListView:addEventListener(cb)
	self.m_nativeEventCallback= cb
end
function LoopListView:init()
	--原生容器层
	self.m_container = self:getInnerContainer()
	self.m_container:removeAllChildren(true)
	--扩展容器层，所有item的承载容器，主要用于快速排版
	self.m_alignContainer = display.newLayout()
	self.m_alignContainer:setContentSize(cc.size(1,1))
	self.m_container:addChild(self.m_alignContainer)
	
	local oldy = 0
	self:m_addEventListener(function(t,e) 
		if e == ccui.ScrollviewEventType.containerMoved then
			local y = self.m_container:getPositionY()
			local direction = y - oldy
			oldy = y
			if direction < 0 then
				--向下滑动，数据向上加载 
				if y - self.m_bufferDistance <= self.m_attr.bottomOffset - self.m_attr.curOffet - (self.m_attr.height - self.m_size.height) then
					if self.m_index - self.m_defaultLength <= 0 then return end	--已经到达第一个
					local item = self:m_getTailItem()
					
					self:m_dispachExtendListener({event = self.EVT_UPDATE,target = item,data = self.m_datas[self.m_index - self.m_defaultLength]})
					self:m_alignItem(item,"down")
					self:m_refresh()
				end
			elseif y + self.m_bufferDistance >= self.m_attr.bottomOffset - self.m_attr.curOffet then
				--向上滑动 已经到达最后
				if not self.m_datas[self.m_index + 1] then return end
				local item = self:m_getHeadItem()
				local oldheight = self.m_attr.maxHeight
				
				self:m_dispachExtendListener({event = self.EVT_UPDATE,target = item,data = self.m_datas[self.m_index + 1]})
				self:m_alignItem(item,"up")
				self:m_refresh()
				if self.m_attr.maxHeight ~= oldheight then
					--滚动总区域发生变化，修改容器y坐标已对齐当前显示的位置
					oldy = self.m_container:getPositionY()
					if self.m_isTouching then
						self.m_container:setPositionY(oldy - item._h_)
					end
					--self.m_container:setPositionY(oldy)
					--self:jumpToPercentVertical((1 + oldy/(self.m_attr.maxHeight - self.m_size.height))*100)
				end
			end
		end
		if self.m_nativeEventCallback then self.m_nativeEventCallback(t,e) end
	end)
end

--设置排列间隙，默认2个像素
function LoopListView:setGap(gap)
	self.m_gap = gap
end
--设置预加载缓存距离
function LoopListView:setBufferDistance(value)
	self.m_bufferDistance = value or self.m_bufferDistance
end
--设置对齐方式，只支持左右，居中对齐，默认居中对齐
function LoopListView:setAlign(align)
	self.m_align = align
end
--设置是平滑出现时间
function LoopListView:setSmoothAppear(tm)
	self.m_smoothTime = tm or 1.5
end
--设置数据列表，会拷贝数组
function LoopListView:setDatas(datas)
	self.m_datas = {}
	if not datas then return end
	for i = 1,#datas do
		self.m_datas[i] = datas[i]
	end
end
--设置初始化的item数量（也是最大显示数量），不支持动态修改
function LoopListView:setDefaultLength(len)
	if not len or self.m_defaultLength then return end
	self.m_defaultLength = len
end
--添加监听
function LoopListView:addExtendListener(callback)
	self.m_listener = callback
end
--[[
*	@private
*	派发事件
]]
function LoopListView:m_dispachExtendListener(e)
	local item = self.m_listener(e)
	
	if e.event == self.EVT_UPDATE then
		self:m_bindItem(e.target,e.data)
	elseif e.event == self.EVT_NEW then
		self:m_bindItem(item,e.data)
	end
	return item
end
--[[
*	向数据列表末尾添加
*	@param datas:数据列表
*	@param attach:如果当前刚好显示了最后一个数据，且在底部，是否立即显示
]]
function LoopListView:appendDatas(datas,attach)
	local cy,oldheight = self.m_container:getPositionY(),self.m_attr.maxHeight
	local item
	if attach and self.m_index >= #self.m_datas and cy >= 0 then
		attach = true
	else
		attach = false
	end
	
	local deslen = #datas
	local srclen = #self.m_datas
	for i = 1,deslen do
		table.insert(self.m_datas,datas[i])
		if srclen + (i - 1) < self.m_defaultLength then
			--未到初始数量
			item = self:m_dispachExtendListener({event = self.EVT_NEW,data = datas[i]})
			item._h_ = 0
			self:m_alignItem(item,"up")
			self.m_alignContainer:addChild(item)
		elseif attach then
			item = self:m_getHeadItem()
			
			self:m_dispachExtendListener({event = self.EVT_UPDATE,target = item,data = datas[i]})
			self:m_alignItem(item,"up")
		end
	end
	self:m_refresh()
	self.m_container:setPositionY(cy - (self.m_attr.maxHeight - oldheight))
	if attach then
		if self.m_smoothTime and self.m_smoothTime > 0 and deslen <= self.m_defaultLength*0.5 then
			self:scrollToBottom(self.m_smoothTime,true)
		else
			self:jumpToBottom()
		end
	end
end
--[[
*	向数据列表头添加数据
*	@param datas:数据列表
*	@param attach:如果当前刚好显示了第一个数据，且在顶部，是否立即显示
]]
function LoopListView:unshiftDatas(datas,attach)
	local cy,oldheight = tonumber(string.format("%.1f",self.m_container:getPositionY())),self.m_attr.maxHeight
	local item
	if attach and self.m_index <= self.m_defaultLength and cy >= tonumber(string.format("%.1f",self.m_size.height - self.m_attr.maxHeight)) then
		attach = true
	else
		attach = false
	end
	
	local deslen = #datas
	local srclen = #self.m_datas
	
	for i = deslen,1,-1 do
		table.insert(self.m_datas,1,datas[i])
		self.m_index = self.m_index + 1
		if srclen + (i - 1) < self.m_defaultLength then
			--未到初始数量
			item = self:m_dispachExtendListener({event = self.EVT_NEW,data = datas[i]})
			item._h_ = 0
			self:m_alignItem(item,"down")
			self.m_index = self.m_index + 1
			self.m_alignContainer:addChild(item)
		elseif attach then
			item = self:m_getTailItem()
			
			self:m_dispachExtendListener({event = self.EVT_UPDATE,target = item,data = datas[i]})
			self:m_alignItem(item,"down")
		end
	end
	self:m_refresh()
	
	if attach then
		if self.m_smoothTime and self.m_smoothTime > 0 and deslen <= self.m_defaultLength*0.5 then
			self:scrollToTop(self.m_smoothTime,true)
		else
			self:jumpToTop()
		end
	end
end
--更新数据，只有数据不改变显示对象的尺寸下才能用该方法
function LoopListView:updataData(index,data)
	if not self.m_datas[index] then return end
	local olddata = self.m_datas[index]
	self.m_datas[index] = data
	local item = self.m_bindtb[olddata]
	if item then
		self:m_dispachExtendListener({event = self.EVT_UPDATE,target = item,data = data})
	end
end
function LoopListView:m_bindItem(item,data)
	self.m_bindtb[data] = item
end
--获取尾部的item
function LoopListView:m_getTailItem()
	return self.m_bindtb[self.m_datas[self.m_index]]
end
--获取头部的item
function LoopListView:m_getHeadItem()
	return self.m_bindtb[self.m_datas[self.m_index - self.m_defaultLength + 1]]
end
--[[
*	@private 初始化item
*	@param reverse:数据是否从末尾显示
*	@param bottom:是否跳转到底部
]]
function LoopListView:m_initItems(reverse,bottom)
	local item,beganIndex,endIndex
	if reverse then
		endIndex = #self.m_datas
		beganIndex = endIndex - self.m_defaultLength + 1
		if beganIndex < 1 then beganIndex = 1 end
		
		self.m_index = beganIndex - 1
	else
		beganIndex,endIndex = 1,self.m_defaultLength
	end
	
	for i = beganIndex,endIndex do
		if not self.m_datas[i] then break end
		item = self:m_dispachExtendListener({event = self.EVT_NEW,data = self.m_datas[i]})
		item._h_ = 0
		self:m_alignItem(item,"up")
		self.m_alignContainer:addChild(item)
--		table.insert(self.m_items,item)
	end
	self:m_refresh()
	
	if not bottom then
		self.m_container:setPositionY(self.m_size.height - self.m_attr.maxHeight)
	else
		self.m_container:setPositionY(0)
	end
end
--[[
*	@private
*	刷新排版容器的坐标和滚动容器的滚动范围
]]
function LoopListView:m_refresh()
	--已经实例化的高度
	local allheight = self.m_attr.topOffset - self.m_attr.bottomOffset
	if allheight < self.m_size.height then	--高度小于容器的基准高度
		--从未设置过
		if self.m_attr.maxHeight ~= self.m_size.height then
			self:changeInnerContainerSize(self.m_size)
			
			self.m_attr.maxHeight = self.m_size.height
		end
		self.m_alignContainer:setPositionY(self.m_size.height - self.m_attr.topOffset)
	elseif self.m_attr.maxHeight ~= allheight then
		self:changeInnerContainerSize(cc.size(self.m_size.width,allheight))
		self.m_alignContainer:setPositionY(allheight - self.m_attr.topOffset)
		
		self.m_attr.maxHeight = allheight
	end
end
--[[
*	@private 排版item
*	@param item:item显示对象
*	@param dr:方向
]]
function LoopListView:m_alignItem(item,dr)
	local size,anchorpoint = item:getContentSize(),item:getAnchorPoint()
	--item更新之前高度
	local oldItemHeight = item._h_
	
	local y
	
	if dr == "up" then			--向上滑动，数据向后加载
		--更新当前所有item的总高度
		self.m_attr.height = self.m_attr.height + size.height + self.m_gap - oldItemHeight
		--通过锚点计算item的的y坐标，当前偏移量减去高差
		y = self.m_attr.curOffet - size.height*(1 - anchorpoint.y) - self.m_gap
		--改变当前最偏移值
		self.m_attr.curOffet = self.m_attr.curOffet - size.height - self.m_gap
		
		if self.m_attr.curOffet < self.m_attr.bottomOffset then
			--更新最小偏移
			self.m_attr.bottomOffset = self.m_attr.curOffet
		end
		self.m_index = self.m_index + 1
	else						--向下滑动，数据向前加载
		--通过锚点计算item的的y坐标
		y = self.m_attr.curOffet + self.m_attr.height + size.height*anchorpoint.y + self.m_gap
		--更新当前所有item的总高度
		self.m_attr.height = self.m_attr.height + size.height + self.m_gap - oldItemHeight
		
		--改变当前最偏移值
		self.m_attr.curOffet = self.m_attr.curOffet + oldItemHeight
		
		if self.m_attr.curOffet + self.m_attr.height  > self.m_attr.topOffset then
			--更新最大偏移
			self.m_attr.topOffset = self.m_attr.curOffet + self.m_attr.height 
		end
		self.m_index = self.m_index - 1
	end
	--记录当前item的高度
	item._h_ = size.height + self.m_gap
	
	if self.m_align == "left" then
		--左对齐
		item:setPosition(cc.p(size.width*anchorpoint.x,y))
	elseif self.m_align == "right" then
		--右对齐
		item:setPosition(cc.p(self.m_size.width - size.width*(1 - anchorpoint.x),y))
	else
		--居中对齐
		item:setPosition(cc.p((self.m_size.width*0.5 + size.width*(anchorpoint.x - 0.5)),y))
	end
end
--[[
*	执行
*	@param reverse:是否从尾部开始显示数据
*	@param bottom:是否默认直接到底部
]]
function LoopListView:excute(reverse--[[=false]],bottom--[[=false]])
	if not self.m_listener then error("<LoopListView>:can not use function excute,you need use 'addExtendListener' function add callback!! ") end
	self.m_datas = self.m_datas or {}
	--已实例的item列表
	self.m_items = {}
	--绑定表
	self.m_bindtb = {}
	--数据记录列表
	self.m_attr = {
		height = 0,			--排版容器中所有 item的高之和
		maxHeight = 0,		--当前滚动的范围
		bottomOffset = 0,	--排版容器底部位置的偏移量
		topOffset = 0,		--排版容器顶部位置的偏移量
		curOffet = 0,		--排版容器中当前最底部item的偏移量
	}
	--当前数据的索引位置
	self.m_index = 0
	self.m_alignContainer:removeAllChildren(true)
	
	self:m_initItems(reverse,bottom)
end
function LoopListView:onCleanup()
	self.m_listener = nil
end
return LoopListView