--[[
*	消息window
*	@author：lqh
]]
local NoticeWindows = class("NoticeWindows",require("src.ui.BaseUIWindows"))
--签到 item
local SignItem = class("SignItem",function() 
	local layer = display.newLayout(cc.size(210,210))
	layer:setAnchorPoint( cc.p(0.5,0.5) )
	layer:setTouchEnabled(true)
	return layer
end)

--NoticeWindows ctor
function NoticeWindows:ctor()
	Player.emailMgr:updateEmail()
	
	local bg = display.newImage("#res/images/single/single_windowbg_01.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,250,20,20),cc.size(1086,700)),"p_ui_1026.png")
	
	local uilayout = display.newLayout(cc.size(970,450))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
--	display.debugLayout(uilayout)
	
	--内容底板
	local infcontentBg = display.setS9(display.newImage("p_panel_1001.png"),cc.rect(20,20,30,30),cc.size(750,440))
	uilayout:addChild(Coord.ingap(uilayout,infcontentBg,"RR",-10,"CC",0))
	self.m_infcontentBg = infcontentBg
	
	--活动按钮
	local eventBtn = display.newButton("p_btn_1012.png","p_btn_1012.png")
	eventBtn:setPressedActionEnabled(true)
	uilayout:addChild(Coord.ingap(uilayout, eventBtn,"LL",35,"TT",-20))
	eventBtn:addChild(Coord.ingap(eventBtn,display.newImage("p_ui_1024.png"),"CC",0,"CC",5))
	eventBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:m_showEventLayout()
	end)
	
	--通知美术文字
	uilayout:addChild(Coord.outgap(eventBtn,display.newImage("p_ui_1025.png"),"CC",0,"BT",-70))
	--线框
	local line = display.setS9(display.newImage("p_ui_1027.png"),cc.rect(10,90,10,10),cc.size(180,216))
	uilayout:addChild(Coord.ingap(uilayout,line,"LL",0,"BB",20))
	--箭头
	local rightarrow = display.newImage("p_ui_1008.png")
	rightarrow:setVisible(false)
	rightarrow:setRotation(180)
	line:addChild(rightarrow)
	
	local function noticeBtnTouchCallback(t,e)
		if e ~= ccui.TouchEventType.ended then return end
		rightarrow:setVisible(true)
		Coord.outgap(t,rightarrow,"RC",20,"CC",0)
		self:m_showNoticeLayout(Player.emailMgr:getEmailByIndex(t.index))
	end
	
	local noticebtn,temp
	for i = 1,3 do
		noticebtn = display.newLayout(cc.size(160,68))
		noticebtn.index = i
		noticebtn:setTouchEnabled(true)
		noticebtn:addChild(Coord.ingap(noticebtn,display.newText(display.trans("##2013",i),36),"CC",0,"CC",0))
		if not temp then
			line:addChild(Coord.ingap(line,noticebtn,"RR",-2,"TT",-3))
		else
			line:addChild(Coord.outgap(temp,noticebtn,"CC",0,"BT",-4))
		end
		noticebtn:addTouchEventListener(noticeBtnTouchCallback)
		temp = noticebtn
	end
	
	self:m_showEventLayout()
end
--显示活动层
function NoticeWindows:m_showEventLayout(datas)
	if self.m_noticelayout then self.m_noticelayout:setVisible(false) end
	if self.m_eventlayout then
		self.m_eventlayout:setVisible(true)
		return
	end
	local eventLayout = display.newLayout(cc.size(740,430))
	eventLayout:setContentSize( cc.size(740,430) )
	self.m_infcontentBg:addChild(Coord.ingap(self.m_infcontentBg,eventLayout,"CC",0,"CC",0))
	
	--活动测试图片
--	local eventUrl = "http://192.168.1.119:8080/HelloWorld.png"
--	local urlsp = require("src.ui.item.URLSprite").new(eventUrl)
--	eventLayout:addChild(urlsp)
--	urlsp:addEventListener(urlsp.EVT_LOADED_TEXTURE,function(t) 
--		Coord.fixSizeUniform(urlsp,740,430)
--		Coord.ingap(eventLayout,urlsp,"CC",0,"CC",0)
--	end)
--	Coord.fixSizeUniform(urlsp,740,430)
--	Coord.ingap(eventLayout,urlsp,"CC",0,"CC",0)

	local eventImg = display.newDynamicImage("res/images/single/single_event_1001.png")
	eventLayout:addChild(Coord.ingap(eventLayout,eventImg,"CC",0,"CC",0))
	
	self.m_eventlayout = eventLayout
end
--显示通知层
function NoticeWindows:m_showNoticeLayout(txt)
	self.m_eventlayout:setVisible(false)
	if self.m_noticelayout then
		self.m_noticelayout:setVisible(true)
		self.m_noticelayout:setString(txt)
		return
	end
	local textarea = display.newTextArea(txt,30)
	textarea:setContentSize(cc.size(700,400))
	self.m_infcontentBg:addChild(Coord.ingap(self.m_infcontentBg,textarea,"CC",0,"CC",0))
	textarea:addEventListener(textarea.EVT_LINK,function(link) 
		cc.Application:getInstance():openURL(link)
	end)
	
	self.m_noticelayout = textarea
end
return NoticeWindows