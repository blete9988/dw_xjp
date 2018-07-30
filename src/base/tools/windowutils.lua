--window显示列表，用于记录当前已经打开的window
local OpenList = {}
local WindowOrder = 1
--[[
*	窗口基类，实现一些窗口基本的方法
*	@author:lqh
]]
local BaseWindow = class("BaseWindow",require("src.base.extend.CCLayerExtend"),IEventListener,function() 
	local window = ccui.Layout:create()
	window:setTouchEnabled(true)
	window:setContentSize(cc.size(D_SIZE.w,D_SIZE.h))
	return window
end)
--默认隐藏上一层
BaseWindow.hide_forward = true	
--window路径
BaseWindow.windowPath = ""
--
function BaseWindow:ctor()
	self:super("ctor")
end
--[[
*	不要在该方法中写任何初始化方法
*	need override
]]
function BaseWindow:onWindowEnter(...)
	--no code need override 
end
--再次进入window
function BaseWindow:reWindowEnter()
	--no code need override 
end
--进入完成
function BaseWindow:enterComplete()
	
end
--退出完成
function BaseWindow:exitComplete()
	mlog(string.format("%s had closed!",self.windowPath))
	self:removeFromParent(true)
end
--退出动作,默认无动作
function BaseWindow:exitAction(callback)
	callback()
end
--进入动作,默认无动作
function BaseWindow:enterAction(callback)
	callback()
end
--[[
*	添加json文件
*	@param jsonpath:json文件路径
*	@param parent:父对象不传参数默认为窗口本身
]]
function BaseWindow:addJson(jsonpath,parent)
	local canvas = display.extend("UIWidgetExtend",ccs.GUIReader:getInstance():widgetFromJsonFile(jsonpath))
	parent = parent or self
	parent:addChild(canvas)
	return canvas
end
--创建一个层
function BaseWindow:createLayout(position,size,touchenabled,clip)
	local layout = ccui.Layout:create()
	if position then layout:setPosition(position) end
	if size then layout:setContentSize(size) end
	
	layout:setTouchEnabled(touchenabled or false)
	layout:setClippingEnabled(clip or false)
	self:addChild(layout)
	return layout
end
--[[
*	@private
*	窗口隐藏
]]
function BaseWindow:m_hide()
	--设置监听为非激活的
	--self:setActivity(false)
	self:setVisible(false)
end
--[[
*	@private
*	窗口显示
]]
function BaseWindow:m_show()
	--激活监听
	--self:setActivity(true)
	self:setVisible(true)
end

function BaseWindow:onCleanup()
	--移除命令中心监听
	self:removeAllEvent()
	--回收lua内存
	collectgarbage("collect")
	if Cfg.DEBUG_MEM then
		--打印纹理内存
        cc.Director:getInstance():getTextureCache():dumpCachedTextureInfo()
    end
end
--获取上一层window或ui
function BaseWindow:getForward()
	return OpenList[#OpenList] or display.getRunningScene():getUIView()
end
--执行加入场景
function BaseWindow:executEnter()
	--添加一个全屏遮罩防止错误点击
	display.showScreenMask()
	
	self:enterAction(function() 
		display.hideScreenMask()
		
		--需要隐藏前一层
		if self.hide_forward then
			local forward = self:getForward()
			if forward.windowPath then
				--is window
				forward:m_hide()
			else
				display.getRunningScene():hideUI()
			end
		end
		
		table.insert(OpenList,self)
		self:enterComplete()
	end)
end
--执行退出
function BaseWindow:executQuit()
	if OpenList[#OpenList].windowPath ~= self.windowPath then
		--不是当前正在显示的window，直接关闭
		table.removeKey(OpenList,"windowPath",self.windowPath,1)
		self:exitComplete()
		return
	end
	
	table.remove(OpenList,#OpenList)
	local forward = self:getForward()
	if forward.windowPath then
		--is window
		forward:m_show()
		forward:reWindowEnter()
	else
		display.getRunningScene():showUI()
	end
	
	--执行退出动画
	display.showScreenMask()
	self:exitAction(function() 
		display.hideScreenMask()
		self:exitComplete()
	end)
end

-- --------------------------------------- 窗口管理类 ----------------------------------------------
local WindowMgr = {}

function WindowMgr.showWindow(windowPath,...)
	mlog("<BaseWindow>: show window name is :" .. windowPath)
	local window
	--检查是否已经打开该window
	local index = table.indexOfKey(OpenList,"windowPath",windowPath,1)
	if index > 0 then
		--已经被打开
		window = table.remove(OpenList,index)
		window:m_show()
	else
		window = require(windowPath).new(...)
		window.windowPath = windowPath
		display.getRunningScene():addWindow(window)
	end
	
	window:setLocalZOrder(WindowOrder)
	--参数传递
	window:onWindowEnter(...)
	window:executEnter()
	
	WindowOrder = WindowOrder + 1
end
--获取当前显示的window数量
function WindowMgr.getWindowCount()
	return #OpenList
end
--[[
*	关闭一个窗口
*	@param windowkey 可以是一个window对象，也可以是window的路径
]]
function WindowMgr.closeWindow(windowkey)
	if type(windowkey) == "string" then
		local index = table.indexOfKey(OpenList,"windowPath",windowkey,1)
		if index < 1 then return end
		windowkey = OpenList[index]
	end
	windowkey:executQuit()
end
function WindowMgr.closeCurrentWindow()
	if OpenList[#OpenList] then
		OpenList[#OpenList]:executQuit()
	end
end
--清理当前所有显示window
function WindowMgr.closeAllWindow()
	WindowOrder = 0
	
	for i = 1,#OpenList do
		OpenList[i]:removeFromParent(true)
		OpenList[i] = nil
	end
	display.getRunningScene():getUIView():setPosition(cc.p(0,0))
	display.getRunningScene():getUIView():setVisible(true)
end
--获取当前正在显示的最上层的window
function WindowMgr.getRunningWindow()
	return OpenList[#OpenList]
end
setmetatable(WindowMgr,{
  __index = {},
  __newindex = function(t,k,v)
    error(string.format("<WindowMgr> attempt to read undeclared variable <%s>",k))
  end
})

Gbv.BaseWindow 	= BaseWindow
Gbv.WindowMgr	= WindowMgr
