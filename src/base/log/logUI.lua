--[[
*	debug ui
*	@author:lqh
]]
local LOGUI = {
	__index = function() end,
	__newindex = function() error("------------") end,
}

local designsize = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
--显示宽，显示高
local showwidth,showheight = designsize.width,designsize.height*2/3
local recordfile = ""
local createLayout,createBtn
--ui单列
local panelInstance
--颜色值定义
local Prori = {
	[DEBUG_N] = cc.c3b(237,230,230),
	[DEBUG_W] = cc.c3b(169,195,27),
	[DEBUG_S] = cc.c3b(242,120,22),
	[DEBUG_E] = cc.c3b(0xfa,0x49,0x3c),
}

local LogPanel = class("LogPanel",require("src.base.extend.CCLayerExtend"),function() 
	local container = createLayout(cc.size(showwidth,showheight),cc.c3b(0,0,0),200)
	container:setPositionY(designsize.height - showheight)
	container:setLocalZOrder(1000000)
	return container
end)

function LogPanel:ctor()
	self:super("ctor")
	local cache,currentPriority = require("src.base.log.log"),0
	
	local looplist = require("src.base.control.LoopListView").new(nil,math.ceil((showheight - 80)/24*1.6))
	looplist:setContentSize(cc.size(showwidth - 20,showheight - 180))
	looplist:setBufferDistance(200)
	looplist:setPosition(cc.p(10,175))
	looplist:setAlign("left")
	self:addChild(looplist)
	
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			local label = params.target
			label:setFontColor(Prori[params.data.priority])
			label:setString(params.data:getMsg(),true)
		elseif params.event == looplist.EVT_NEW then
			--新创建
			local label = require("src.base.control.label.LabelElement").new(params.data:getMsg(),24,Prori[params.data.priority])
			label:setAnchorPoint(cc.p(0, 0))
			label:setEdgeSmoothing(true)
			label:setHorType("left")
			label:setLeading(5)
			label:setPositionX(10)
			label:setDimentWidth(showwidth - 20)
			label:draw()
			return label
		end
	end)
	
	--读取打印缓存
	local function loadmsgCache(priority)
		currentPriority = priority
		looplist:setDatas(cache.getLog(priority))
		looplist:excute(true,true)
	end
	
	--添加数据监听
	cache.addListener(function(msg)
		if not (msg.priority == currentPriority or currentPriority == 0) then return end
		looplist:appendDatas({msg},true)
	end)
	
	local function labelbuttonHandler(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local index = t.index
		if index == 6 then
			self:removeFromParent(true)
		elseif index == 5 then
			cache.clear()
			looplist:setDatas()
			looplist:excute(true,true)
		elseif index == 4 then
			loadmsgCache(DEBUG_E)
		elseif index == 3 then
			loadmsgCache(DEBUG_S)
		elseif index == 2 then
			loadmsgCache(DEBUG_W)
		elseif index == 1 then
			loadmsgCache(DEBUG_N)
		elseif index == 0 then
			loadmsgCache(0)
		end
	end
	
	local templist = {
		{title = "all",index = 0},
		{title = "noraml",index = 1},
		{title = "warning",color = Prori[DEBUG_W],index = 2},
		{title = "serious",color = Prori[DEBUG_S],index = 3},
		{title = "error",color = Prori[DEBUG_E],index = 4},
		{title = "clear",index = 5},
		{title = "exit",index = 6},
	}
	local button,label
	local buttonsize = showwidth/#templist*2/3
	for i = 1,#templist do
		button = createBtn(cc.size(buttonsize,60),templist[i].title,20,templist[i].color)
		button:setAnchorPoint(cc.p(0,0))
		button:setPosition(cc.p(buttonsize*0.25 + (buttonsize + buttonsize*0.5)*(i - 1),107 ))
		button:addTouchEventListener(labelbuttonHandler)
		button.index = templist[i].index
		self:addChild(button)
		if i == 1 then labelbuttonHandler(button,ccui.TouchEventType.ended) end
	end
	
	--重启游戏按钮
	local relanuchBtn = createBtn(cc.size(180,60),"重启游戏",24)
	relanuchBtn:setPosition(cc.p(showwidth*0.5 - 130,-30 ))
	self:addChild(relanuchBtn)
	relanuchBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:removeFromParent(true)
		display.enterScene("src.ui.scene.RelanuchScene")
	end)
	
	--进入登陆界面按钮
	local gologinBtn = createBtn(cc.size(180,60),"进入登陆界面",24)
	gologinBtn:setPosition(cc.p(showwidth*0.5 +130,-30 ))
	self:addChild(gologinBtn)
	gologinBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		ConnectMgr.noticehandler(ST.TYPE_SOCKET_CLOSE_ALL)
		self:removeFromParent(true)
		display.enterScene("src.ui.scene.login.LoginScene")
	end)
	
	self:initGMCommandTools()
	self:initReloadcodeTools()
end
--初始化GM命令工具条
function LogPanel:initGMCommandTools()
	local layer = createLayout(cc.size(showwidth - 200,44),cc.c3b(0,0,0))
	layer:setPosition(cc.p(5,53))
	self:addChild(layer)
	local inputtext = ccui.EditBox:create(cc.size(showwidth - 180,44),ccui.Scale9Sprite:create(),ccui.Scale9Sprite:create(),ccui.Scale9Sprite:create())
    inputtext:setFontSize(20)
    inputtext:setFontColor(cc.c3b(255,255,255))
    inputtext:setPlaceHolder(">>点击输入<<")
    inputtext:setPlaceholderFontColor(cc.c3b(0xfa,0x49,0x3c))
    inputtext:setMaxLength(20)
    inputtext:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    inputtext:setAnchorPoint(cc.p(0,0))
    inputtext:setPosition(cc.p(10,0))
    layer:addChild(inputtext)
    local submitButton = createBtn(cc.size(150,40),"提 交",20)
	submitButton:setPosition(cc.p(showwidth - 100,22))
	layer:addChild(submitButton)
	submitButton:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local command = inputtext:getText()
		inputtext:setText("")
		if command == "" or command:sub(1,3) ~= "CM@" then return end
		require("src.app.data.CommandParse")(command:sub(4))
	end)
end
--初始化代码重置工具条
function LogPanel:initReloadcodeTools()
	if not require("src.cocos.framework.device").isWindows() then return end
	local file,selectUI = recordfile
	
	local layer = createLayout(cc.size(showwidth - 200,44),cc.c3b(0,0,0))
	layer:setPosition(cc.p(5,3))
	self:addChild(layer)
	local inputtext = ccui.EditBox:create(cc.size(showwidth - 180,44),ccui.Scale9Sprite:create(),ccui.Scale9Sprite:create(),ccui.Scale9Sprite:create())
    inputtext:setFontSize(20)
    inputtext:setFontColor(cc.c3b(255,255,255))
    inputtext:setPlaceHolder(">>输入需要刷新的Lua文件<<")
    inputtext:setPlaceholderFontColor(cc.c3b(0xfa,0x49,0x3c))
    inputtext:setMaxLength(20)
    inputtext:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE)
    inputtext:setAnchorPoint(cc.p(0,0))
    inputtext:setPosition(cc.p(10,0))
    inputtext:setText(file)
    layer:addChild(inputtext)
    --确认按钮
    local confirbtn = createBtn(cc.size(150,40),"刷 新",20)
	confirbtn:setPosition(cc.p(showwidth - 100,22))
	layer:addChild(confirbtn)
    
    --初始化查找工具
    local tool = require("src.base.log.FuzzyFindLuafiles")
	tool:init()
	
	
	local function itemselect(t,e)
		if e ~= ccui.TouchEventType.ended then return end
		file = t.file
		inputtext:setText(file)
		selectUI:removeFromParent(true)
		selectUI = nil
	end
    inputtext:registerScriptEditBoxHandler(function(e,t) 
    	if e == "changed" then
    		file = nil
			local files = tool:find(t:getText())
			if not selectUI then
				selectUI = createLayout(cc.size(showwidth - 10,200),cc.c3b(0,0,0))
				selectUI:setPosition(cc.p(5,52))
				self:addChild(selectUI)
			end
			selectUI:removeAllChildren()
			local len = #files
			if len > 5 then len = 5 end
			for i = 1,len do
				local item = ccui.Layout:create()
				item:setTouchEnabled(true)
				item:setContentSize(cc.size(showwidth - 20,40))
				item.file = files[i]
				item:addTouchEventListener(itemselect)
				local txt = ccui.Text:create(files[i],"Helvetica",30)
				txt:setAnchorPoint(cc.p(0,0.5))
				txt:setPosition(cc.p(20,20))
				txt:setColor(cc.c3b(0xff,0xff,0xff))
				item:addChild(txt)
				
				item:setPosition(cc.p(10,(i - 1)*40))
				selectUI:addChild(item)
			end
		elseif e == "ended" then
			local files = tool:find(t:getText())
			if #files == 0 then
				selectUI:removeFromParent(true)
				selectUI = nil
			end
		end
    end)
    
	confirbtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		if file and file ~= "" then
			recordfile = file
			reload(file)
			mlog("重新加载Lua文件-------->" .. file)
		end
	end)
end
function LogPanel:onExit()
	panelInstance = nil
	require("src.base.log.log").addListener(nil)
end

--debug按钮当前位置
local btnPos = cc.p(40,D_SIZE.h * 0.5)
--显示debug按钮
function LOGUI.showdebug(scene)
	if not Cfg.DEBUG_TAG then return end
	
	local button = ccui.ImageView:create("src/base/log/log_debugbtn.png",0)
	button:setPosition(btnPos)
	button:setLocalZOrder(99999)
	button:setOpacity(90)
	button:setTouchEnabled(true)
	local movePos
	button:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then 
			button:setOpacity(255)
		elseif e == ccui.TouchEventType.moved then 
			local p = button:getTouchMovePosition()
			if not movePos then
				local startPos = button:getTouchBeganPosition()
				if math.abs(startPos.x - p.x) > 30 or math.abs(startPos.y - p.y) > 30 then
					movePos = p
				end
			else
				btnPos.x = btnPos.x + p.x - movePos.x
	    		btnPos.y = btnPos.y + p.y - movePos.y
	    		movePos = p
		    	if btnPos.x < 30 then btnPos.x = 30 end
		    	if btnPos.x > D_SIZE.w - 30 then btnPos.x = D_SIZE.w - 30 end
		    	if btnPos.y < 30 then btnPos.y = 30 end
		    	if btnPos.y > D_SIZE.h - 30 then btnPos.y = D_SIZE.h - 30 end
		    	button:setPosition(btnPos)
			end
		else
			button:setOpacity(90) 
			if e == ccui.TouchEventType.ended and not movePos then 
				panelInstance = LogPanel.new()
				display.getRunningScene():nativeAddChild(panelInstance)
			end
			movePos = nil
		end		
	end)
    
	scene:nativeAddChild(button)
end

function createLayout(size,color,opacity)
	local layout = ccui.Layout:create()
	layout:setTouchEnabled(true)
	layout:setContentSize(size)
	layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	layout:setBackGroundColorOpacity(opacity or 255)
	layout:setBackGroundColor(color)
	return layout
end
function createBtn(size,txt,txtsize,color)
	local btn = ccui.Button:create("src/base/log/log_uibtn.png","src/base/log/log_uibtn.png","",0)
	btn:setTouchEnabled(true)
	btn:setScale9Enabled(true)
	btn:setCapInsets(cc.rect(3,3,4,4))
	btn:setContentSize(size)
	btn:setPressedActionEnabled(true)
	btn:setTitleText(txt)
	btn:setTitleFontSize(txtsize)
	btn:setTitleColor(color or cc.c3b(255,255,255))
	return btn
end

setmetatable(LOGUI,LOGUI)
return LOGUI
