--[[
*	房间聊天显示按钮
]]
local TalkControl = class("TalkControl",require("src.base.extend.CCLayerExtend"), IEventListener,function() 
	local layout = display.newLayout(cc.size(85,110))
	layout:setAnchorPoint( cc.p(0,0.5) )
	layout:setLocalZOrder(20)
	return layout
end)

--单选按钮
local RadioButtonEx = class("RadioButtonEx",function(normalpath,selectpath) 
	local button = display.newButton("p_btn_1022.png","p_btn_1023.png")
	display.setS9(button,cc.rect(10,10,30,30),cc.size(60,220))
	button.m_setBrightStyle = button.setBrightStyle
	return button
end)
--头像列表控件
local PlayerListItem = class("PlayerListItem",function() 
	return display.newLayout(cc.size(470,145))
end)
--消息列表控件
local MsgInfoListItem = class("MsgInfoListItem",function() 
	return display.newLayout()
end)
--[[
*	TalkControl 构造函数
]]
function TalkControl:ctor(roomdata)
	self:super("ctor")
	self:addEvent(ST.COMMAND_GAME_SCROLL_MSG)
	
	local showBtn = display.newButton("p_ui_1068.png","p_ui_1068.png")
	showBtn:setPressedActionEnabled(true)
	self:addChild(Coord.ingap(self,showBtn,"CC",0,"CC",0))
	local btnAnim = display.newSprite("p_ui_1091.png")
	btnAnim:setVisible(false)
	self:addChild(Coord.ingap(self,btnAnim,"CC",0,"CC",0))
	
	showBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self.m_status = "show"
		btnAnim:stopAllActions()
		btnAnim:setOpacity(255)
		btnAnim:setVisible(false)
		self:showExtendContent()
	end)
	self.m_status = "hide"
	self.m_msgCache = {}
	self.m_btnAnim = btnAnim
	self.m_roomdata = roomdata
end

function TalkControl.show(roomdata,target,pos,order)
	local pos = pos or cc.p(0,D_SIZE.hh)
	local order = order or 0
	
	local item = TalkControl.new(roomdata)
	item:setPosition( pos )
	item:setLocalZOrder(order)
	target:addChild(item)
end

--显示扩展容器
function TalkControl:showExtendContent()
	if not self.m_content then
		self:createExtendContent()
	end
	
	self.m_content.hideBtn:setOpacity(0)
	
	self.m_content:runAction(cc.Sequence:create({
		cc.MoveTo:create(0.2,cc.p(0,55)),
		cc.CallFunc:create(function(t) 
			if not t then return end
			if self.m_content.playerLayout and self.m_content.playerLayout:isVisible() then
				self.m_content.playerLayout:update()
			end
			self.m_content.hideBtn:runAction(cc.FadeIn:create(0.3))
		end),
	}))
end

function TalkControl:createExtendContent()
	local layout = display.newLayout()
	layout:setBackGroundImage("p_panel_1006.png",1)
	display.setBgS9(layout,cc.rect(25,15,60,20),cc.size(600,450))
	layout:setTouchEnabled(true)
	layout:setAnchorPoint( cc.p(0,0.5) )
	layout:setPosition( cc.p(-600,55) )
	self:addChild(layout)
	self.m_content = layout
	
	local infoBtn = RadioButtonEx.new("p_ui_1072.png","p_ui_1073.png")
	layout:addChild(Coord.ingap(layout,infoBtn,"LL",5,"CB",1))
	local playersBtn = RadioButtonEx.new("p_ui_1070.png","p_ui_1071.png")
	layout:addChild(Coord.ingap(layout,playersBtn,"LL",5,"CT",-1))
	
	local buttonMgr = require("src.base.control.RadioButtonControl").new()
	local currentLayout
	--单选按钮
	buttonMgr:addEventListener(buttonMgr.EVT_SELECT,function(e,t) 
		if currentLayout then
			currentLayout:setVisible(false)
		end
		if t == infoBtn then
			if not self.m_content.msgLayout then
				self.m_content.msgLayout = self:createMsgInfoLayout()
				self.m_content:addChild(Coord.ingap(self.m_content,self.m_content.msgLayout,"LL",70,"CC",0))
			end
			
			currentLayout = self.m_content.msgLayout
		else
			if not self.m_content.playerLayout then
				self.m_content.playerLayout = self:createPlayersLayout()
				self.m_content:addChild(Coord.ingap(self.m_content,self.m_content.playerLayout,"LL",70,"CC",0))
			end
			self.m_content.playerLayout:update()
			
			currentLayout = self.m_content.playerLayout
			
		end
		currentLayout:setVisible(true)
	end)
	
	buttonMgr:addButton(infoBtn)
	buttonMgr:addButton(playersBtn)
	buttonMgr:setCurrentButton(infoBtn)
	
	local hideBtn = display.newButton("p_ui_1056.png","p_ui_1056.png")
	hideBtn:setPressedActionEnabled(true)
	layout:addChild(Coord.ingap(layout,hideBtn,"RR",-20,"CC",0))
	hideBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self.m_content:runAction(cc.MoveTo:create(0.2,cc.p(-600,55)))
		self.m_status = "hide"
	end)
	layout.hideBtn = hideBtn
end

function TalkControl:createPlayersLayout()
	local layout = display.newLayout(cc.size(470,440))
	layout.m_dateStamp = 0
	
	local looplist = require("src.base.control.LoopListView").new("",6)
	looplist:setContentSize(cc.size(470,380))
	layout:addChild(Coord.ingap(layout,looplist,"CC",0,"BB",0))
	
	layout:addChild(Coord.outgap(looplist,display.newImage("p_ui_1075.png"),"CC",0,"TB",2))
	local allNmbTxt = display.newText(display.trans("##2049",0),26,cc.c3b(0xc7,0xbb,0x73))
	layout:addChild(Coord.outgap(looplist,allNmbTxt,"CC",0,"TB",20))
	
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			params.target:setPlayerInfo(params.data)
		elseif params.event == looplist.EVT_NEW then
			return PlayerListItem.new(params.data)
		end
	end)
	
	function layout:update()
		if layout.m_dateStamp > ServerTimer.time then return end
		
		ConnectMgr.connect("gamehall.RoomPlayersConnect" , function(params) 
			if params.result ~= 0 then return end
			layout.m_dateStamp = ServerTimer.time + 60
			allNmbTxt:setString(display.trans("##2049",#params.playerList))
			looplist:setDatas(params.playerList)
			looplist:excute()
		end)
	end
	
	return layout
end
function TalkControl:createMsgInfoLayout()
	local layout = display.newLayout(cc.size(470,440))
	
	local looplist = require("src.base.control.LoopListView").new("",16)
	looplist:setContentSize(cc.size(470,430))
	layout:addChild(Coord.ingap(layout,looplist,"CC",0,"CC",0))
	
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			params.target:setInfo(params.data)
		elseif params.event == looplist.EVT_NEW then
			return MsgInfoListItem.new(params.data)
		end
	end)
	
	local datas = self.m_msgCache
	self.m_msgCache = nil
	looplist:setDatas(datas)
	looplist:excute(true,true)
	
	function layout:appendMsg(msglist)
		looplist:appendDatas(msglist,true)
	end
	return layout
end
--@override
function TalkControl:handlerEvent(event,arg)
	if event == ST.COMMAND_GAME_SCROLL_MSG then
		--只显示系统跑马灯
		local list = {}
		for i = 1,#arg do
			if arg[i].type == ST.TYPE_GAME_SYSTEM_MSG then
				--系统消息
				table.insert(list,arg[i])
			end
		end
		
		local len = #list
		if len < 1 then return end
			
		if self.m_msgCache then
			for i = 1,len do
				table.insert(self.m_msgCache,list[i])
			end
		else
			self.m_content.msgLayout:appendMsg(list)
		end
		
		if self.m_status == "hide" and not self.m_btnAnim:isVisible() then
			self.m_btnAnim:setVisible(true)
			self.m_btnAnim:runAction(cc.RepeatForever:create(
				cc.Sequence:create({
					cc.FadeTo:create(0.6,100),
					cc.FadeTo:create(0.6,255),
				})
			))
		end
	end
end

function TalkControl:onCleanup()
	self:removeAllEvent()
end

-- ---------------------------------Class RadioButtonEx-------------------------------
function RadioButtonEx:ctor(normalIconPath,selectIconPath)
	self.m_normalIconPath = normalIconPath
	self.m_selectIconPath = selectIconPath
	self.m_icon = display.newImage(normalIconPath)
	self:addChild(Coord.ingap(self,self.m_icon,"CC",0,"CC",0))
end
--@override
function RadioButtonEx:setBrightStyle(value)
	if value == ccui.BrightStyle.normal then
		self.m_icon:loadTexture(self.m_normalIconPath,1)
	elseif value == ccui.BrightStyle.highlight then
		self.m_icon:loadTexture(self.m_selectIconPath,1)
	end
	self:m_setBrightStyle(value)
end
-- -----------------------------------------------------------------------------------
-- ---------------------------------Class PlayerListItem------------------------------
function PlayerListItem:ctor(playerInfo)
	local headIcon = require("src.ui.item.HeadIcon").new()
	self:addChild(Coord.ingap(self,headIcon,"LC",100,"CC",0))
	
	local goldIcon = display.newImage("p_ui_1009.png")
	goldIcon:setScale(0.6)
	self:addChild(Coord.outgap(headIcon,goldIcon,"RL",35,"BB",5,true))
	--线
	local line = display.newImage("p_ui_1074.png")
	self:addChild(Coord.ingap(self,line,"CC",0,"BB",0))
	
	local infoTxt = display.newRichText(display.trans("##2050","","",0),22,cc.c3b(0xc7,0xbb,0x73))
	infoTxt:setAnchorPoint( cc.p(0,1) )
	infoTxt:setLeading(17)
	self:addChild(Coord.outgap(headIcon,infoTxt,"RL",35,"TT",0))
	
	local goldTxt = display.newText(0,22,cc.c3b(0xc7,0xbb,0x73))
	goldTxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(goldIcon,goldTxt,"RL",10,"CC",0,true))
	
	self.m_headIcon = headIcon
	self.m_infoTxt = infoTxt
	self.m_goldTxt = goldTxt
	
	self:setPlayerInfo(playerInfo)
end
function PlayerListItem:setPlayerInfo(playerInfo)
	self.m_headIcon:setHead(playerInfo.pic)
	self.m_infoTxt:setString(display.trans("##2050",playerInfo.name,playerInfo.id,playerInfo.level))
	self.m_goldTxt:setString(playerInfo.gold)
end
-- -----------------------------------------------------------------------------------
-- --------------------------------Class MsgInfoListItem------------------------------
function MsgInfoListItem:ctor(info)
	--线
	local line = display.newImage("p_ui_1074.png")
	line:setPosition(cc.p(235,1))
	self:addChild(line)
	
	local infoTxt = display.newRichText("",22,cc.c3b(0x67,0xd5,0xe2))
	infoTxt:setLeading(4)
	infoTxt:setWidth(430)
	infoTxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(infoTxt)
	
	self.m_infoTxt = infoTxt
	
	self:setInfo(info)
end
function MsgInfoListItem:setInfo(info)
	self.m_infoTxt:setString(info.txt)
	local size = self.m_infoTxt:getContentSize()
	self:setContentSize(cc.size(470,size.height + 30))
	self.m_infoTxt:setPosition(cc.p(20,size.height*0.5 + 15))
end
-- -----------------------------------------------------------------------------------

return TalkControl