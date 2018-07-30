display.getFrameCache():addSpriteFrames("res/images/popui.plist")
--[[
 *	通用提示框
 *	弹窗接收一个table对象
 *	{
 		info:显示信息（可以是纯文字，也可以是一个layout）
 		title：标题文字（默认为“提 示”）
 		vtype：（只有当info为纯文字时，才有效，垂直对齐方式<默认居中>）
 		htype：（只有当info为纯文字时，才有效，水平对齐方式<默认居中>）
 		color：字体颜色（默认为土黄色）
 		leader：行间距（默认为3）
 		size：字体大小（默认为全局字体大小，30）
 		callback：回调函数
 		priority：优先级（默认为10，值越小，优先级越高，优先级高的弹窗会覆盖比当前优先级低的弹窗）
 		confirmtext：确认按钮文字
 		canceltext：取消按钮文字
 		touchclose:是否启用 点击空白区域关闭提示框（默认为false不启用）
 		mask：（默认为flase）该参数为true实现触摸任何区域提示框关闭
 		flag：标记参数（默认为1<可选1,2>；1：显示两个按钮；2：只显示一个按钮；）
	}
]]
local PopControl = class("PopControl",require("src.base.extend.CCLayerExtend"),function() 
	local container = display.newMask(nil,150,cc.c3b(0x10,0x10,0x10))
	return container
end)

local instance = {}

function PopControl:ctor(alterinfo)
	self:super("ctor")
	
	alterinfo.flag = alterinfo.flag or 1
	alterinfo.mask = false or alterinfo.mask
	alterinfo.confirmtext = alterinfo.confirmtext or "确 认"
	alterinfo.canceltext = alterinfo.canceltext or "取 消"
	alterinfo.title = alterinfo.title or "提 示"
	
	local deaultSize = cc.size(600,250)
	--显示层
	local displayLayout = display.newLayout()
	displayLayout:setBackGroundImage("popui_002.png",1)
	display.setBgS9(displayLayout,cc.rect(10,10,50,50),deaultSize)
	displayLayout:setTouchEnabled(true)
	self:addChild(displayLayout)
	
	local btnClose		--关闭按钮
	local btnCancel		--取消按钮
	local btnConfirm	--确定按钮
	local infolayout	--信息层
	local buttonHandler	--操作按钮监听方法
	
	function buttonHandler(t,e)
		if e ~= ccui.TouchEventType.ended then return end
		local flag = 2--TYPE_POP_NIL 
		if t == btnConfirm then
			flag = 0--ST.TYPE_POP_OK
		elseif t == btnCancel then
			flag = 1--ST.TYPE_POP_NO
		end
		PopControl.hide()
		
		if alterinfo.callback then alterinfo.callback(flag) end
	end
	
	if alterinfo.touchclose then
		self:addTouchEventListener(buttonHandler)
	end
	
	--确认按钮
	btnConfirm = display.newTextButton("popui_btn_001.png","popui_btn_001.png","",1,alterinfo.confirmtext,26)
	btnConfirm:setLocalZOrder(2)
	btnConfirm:setPressedActionEnabled(true)
	btnConfirm:addTouchEventListener(buttonHandler)
	
	if alterinfo.flag == 1 then
		--有取消按钮
		btnCancel = display.newTextButton("popui_btn_002.png","popui_btn_002.png","",1,alterinfo.canceltext,26)
		btnCancel:setLocalZOrder(2)
		btnCancel:setPressedActionEnabled(true)
		btnCancel:addTouchEventListener(buttonHandler)
		displayLayout:addChild(Coord.ingap(displayLayout,btnCancel,"CR",-40,"BB",15))
		displayLayout:addChild(Coord.ingap(displayLayout,btnConfirm,"CL",40,"BB",15))
	else
		displayLayout:addChild(Coord.ingap(displayLayout,btnConfirm,"CC",0,"BB",15))
	end
	
	--标题文本
	local titletext = display.newText(alterinfo.title,32,cc.c3b(0xe9,0xd4,0x5f))

	local infoSize
	if type(alterinfo.info) == "string" then
		--显示信息为纯文本
		infolayout = display.newTextArea(
			alterinfo.info,alterinfo.size or 30,
			alterinfo.color or cc.c3b(0xe9,0xd4,0x5f),nil,require("src.app.config.style.cssstyle")["alter"],cc.size(500,deaultSize.height - 150)
		)
		infolayout:setLeading(alterinfo.leader or 3)
		--infolayout:enableOutline(cc.c4b(0,0,0,255),2)
		infolayout:setVerType(alterinfo.vtype or "center")
		infolayout:setHorType(alterinfo.htype or "center")
		infolayout:draw()
		infoSize = infolayout:getInnerContainerSize()
		if infoSize.height > 100 then
			if infoSize.height > 400 then
				infoSize.height = 400
			else
				infoSize.height = infoSize.height + 20
			end
			infolayout:setContentSize(infoSize)
		end
--		display.debugLayout(infolayout)
	else
		--显示信息为一个已定义好的显示对象
		infolayout = alterinfo.info
		infoSize = infolayout:getContentSize()
		if infoSize.width < deaultSize.width - 100 then
			infoSize.width = deaultSize.width + 100
		end
	end
	
	if infoSize.height > deaultSize.height - 150 then
		displayLayout:setContentSize(cc.size(deaultSize.width,infoSize.height + 150))
	end
	
	displayLayout:addChild(Coord.ingap(displayLayout,titletext,"CC",0,"TT",-15))
	displayLayout:addChild(Coord.ingap(displayLayout,infolayout,"CC",0,"BB",90))
	
	Coord.ingap(self,displayLayout,"CC",0,"CC",0)
	
	--关闭按钮
	btnClose = display.newButton("popui_btn_close.png","popui_btn_close.png")
	btnClose:setLocalZOrder(2)
	btnClose:setPressedActionEnabled(true)
	btnClose:addTouchEventListener(buttonHandler)
	displayLayout:addChild(Coord.ingap(displayLayout,btnClose,"RC",-20,"TC",-20))
	
	if alterinfo.mask then
		local mask = display.newLayout()
		mask:setContentSize(cc.size(D_SIZE.w,height))
		mask:setLocalZOrder(1)
		mask:setTouchEnabled(true)
		mask:addTouchEventListener(buttonHandler)
		displayLayout:addChild(mask)
	end
end

function PopControl:onEnter()
--	self:runAction(cc.FadeIn:create(0.3))
--	self._animalayout:runAction(cc.Sequence:create({
--		cc.ScaleTo:create(0.2,1.05),
--		cc.ScaleTo:create(0.1,1)
--	}))
end

function PopControl:onExit()
	for i = 1,#instance do
		if instance[i] == self then
			table.remove(instance,i)
			break
		end
	end
end
--关闭所有 提示框
function PopControl.hideAll()
	for i = #instance,1,-1 do
		instance[i]:removeFromParent(true)
	end
	instance = {}
end
--关闭当前正在显示的提示框
function PopControl.hide()
	local obj = instance[#instance]
	if obj then
		obj:removeFromParent(true)
	end
end
function PopControl.show(alterinfo)
	if type(alterinfo) == "string" then
		alterinfo = {info = alterinfo}
	end
	local priority = alterinfo.priority or 10
	
	local obj = PopControl.new(alterinfo)
	obj.priority = priority
	local len = #instance
	
	local currentAlter = instance[len]
	local b,err = pcall(function()
		if currentAlter and currentAlter.priority < priority then
			--上一个提示框优先级大于当前想显示的提示框
			table.insert(instance,len - 1,obj)
			currentAlter:setLocalZOrder(len + 1)
			obj:setLocalZOrder(len)
		else
			table.insert(instance,obj)
			obj:setLocalZOrder(len)
		end
		
		display.getRunningScene():addPop(obj)
	end)
	if not b then
		PopControl.hideAll()
		instance = {}
	end
end
return PopControl