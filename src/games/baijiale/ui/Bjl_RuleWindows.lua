--[[
*	百家乐 规则window
*	@author：lqh
]]
local Bjl_RuleWindows = class("Bjl_RuleWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(1086,580))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",-20)
	return layer
end)
Bjl_RuleWindows.hide_forward = false

function Bjl_RuleWindows:ctor()
	self:super("ctor")
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),150),"CC",0,"CC",20))
	--底板
	self:addChild(Coord.ingap(self,display.setS9(display.newImage("bjl_panel_1001.png"),cc.rect(20,20,80,80),cc.size(1086,580)),"CC",0,"CC",0))
	--标题	
	self:addChild(Coord.ingap(self,display.newImage("bjl_ui_1050.png"),"CC",0,"TT",-25))
	
	local closebtn = display.newButton("bjl_ui_1049.png","bjl_ui_1068.png")
	self:addChild(Coord.ingap(self,closebtn,"RR",-8,"TT",-8))
	closebtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:executQuit()
	end)
	
	local contentLayout = display.newLayout()
	contentLayout:setBackGroundImage("bjl_panel_1002.png",1)
	display.setBgS9(contentLayout,cc.rect(20,20,60,60),cc.size(960,410))
	self:addChild(Coord.ingap(self,contentLayout,"CC",0,"BB",15))
	self.m_contentLayout = contentLayout
	
	local buttonMgr = require("src.base.control.RadioButtonControl").new()
	--单选按钮
	buttonMgr:addEventListener(buttonMgr.EVT_SELECT,function(e,t) 
		if t.index == 1 then
			self:m_showIntroduceLayout()
		else
			self:m_showRuleLayout()
		end
	end)
	self.m_buttonMgr = buttonMgr
	
	local button = display.newButton("bjl_ui_1045.png","bjl_ui_1046.png")
	button.index = 1
	self:addChild(Coord.ingap(self,button,"LL",50,"TT",-70))
	buttonMgr:addButton(button)
	local button1 = display.newButton("bjl_ui_1047.png","bjl_ui_1048.png")
	button1.index = 2
	self:addChild(Coord.outgap(button,button1,"RL",10,"CC",0))
	buttonMgr:addButton(button1)
	
	buttonMgr:setCurrentButton(button)
end
--显示介绍层
function Bjl_RuleWindows:m_showIntroduceLayout()
	if self.m_ruleLayout then
		self.m_ruleLayout:setVisible(false)
	end
	if self.m_introduceLayout then
		self.m_introduceLayout:setVisible(true)
	else
		local layout = display.newTextArea(display.trans("##3009"),28,cc.c3b(0xfb,0xdc,0x7d),nil,nil,cc.size(900,400))
		self.m_contentLayout:addChild(Coord.ingap(self.m_contentLayout,layout,"CC",0,"CC",0))
		self.m_introduceLayout = layout
	end
end
--显示规则层
function Bjl_RuleWindows:m_showRuleLayout()
	if self.m_introduceLayout then
		self.m_introduceLayout:setVisible(false)
	end
	if self.m_ruleLayout then
		self.m_ruleLayout:setVisible(true)
	else
		local layout = display.newListView(nil,nil,nil,true)
		layout:setContentSize(cc.size(900,400))
		self.m_contentLayout:addChild(Coord.ingap(self.m_contentLayout,layout,"CC",0,"CC",0))
		
		local temply = display.newLayout(cc.size(900,830))
		local rulepic = display.newDynamicImage("game/baijiale/bjl_rulepic.jpg")
		rulepic:setScale(1.266)
		temply:addChild(Coord.ingap(temply,rulepic,"CC",0,"CC",0,true))
		
		layout:pushBackCustomItem(temply)
		self.m_ruleLayout = layout
	end
end
function Bjl_RuleWindows:onCleanup()
	self:super("onCleanup")
	self.m_buttonMgr:removeAllEventListeners()
end
return Bjl_RuleWindows