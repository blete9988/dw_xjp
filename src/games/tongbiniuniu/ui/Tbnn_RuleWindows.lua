--[[
*	通比牛牛 规则window
*	@author：lqh
]]
local Tbnn_RuleWindows = class("Tbnn_RuleWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(1234,616))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",0)
	return layer
end)
Tbnn_RuleWindows.hide_forward = false

function Tbnn_RuleWindows:ctor()
	self:super("ctor")
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),200),"CC",0,"CC",0))
	--底板
	local background = display.newDynamicImage("game/tongbiniuniu/tbnn_windowbg_2.png")
	background:setScale(1.319)
	self:addChild(Coord.ingap(self,background,"CC",0,"CC",0,true))
	
	local closebtn = display.newButton("tbnn_ui_1025.png","tbnn_ui_1025.png")
	closebtn:setPressedActionEnabled(true)
	self:addChild(Coord.ingap(self,closebtn,"RR",-5,"TT",-45))
	closebtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:executQuit()
	end)
	
	local contentLayout = display.newLayout()
	contentLayout:setBackGroundImage("tbnn_panel_1003.png",1)
	display.setBgS9(contentLayout,cc.rect(40,40,10,10),cc.size(1100,420))
	self:addChild(Coord.ingap(self,contentLayout,"CC",0,"BB",30))
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
	
	local button = display.newButton("tbnn_ui_1005.png","tbnn_ui_1006.png")
	button.index = 1
	button:addChild(Coord.ingap(button,display.newImage("tbnn_ui_1003.png"),"CC",0,"CC",0))
	self:addChild(Coord.ingap(self,button,"LL",50,"TT",-70))
	buttonMgr:addButton(button)
	
	local button1 = display.newButton("tbnn_ui_1005.png","tbnn_ui_1006.png")
	button1.index = 2
	button1:addChild(Coord.ingap(button1,display.newImage("tbnn_ui_1004.png"),"CC",0,"CC",0))
	self:addChild(Coord.outgap(button,button1,"RL",10,"CC",0))
	buttonMgr:addButton(button1)
	
	buttonMgr:setCurrentButton(button)
end
--显示介绍层
function Tbnn_RuleWindows:m_showIntroduceLayout()
	if self.m_ruleLayout then
		self.m_ruleLayout:setVisible(false)
	end
	if self.m_introduceLayout then
		self.m_introduceLayout:setVisible(true)
	else
		local layout = display.newListView(nil,nil,nil,true)
		layout:setContentSize(cc.size(1050,400))
		self.m_contentLayout:addChild(Coord.ingap(self.m_contentLayout,layout,"CC",0,"CC",0))
		
		local temply = display.newLayout(cc.size(1050,400))
		local rulepic = display.newDynamicImage("game/tongbiniuniu/tbnn_rulepic_2.png")
		rulepic:setScale(1.3125)
		temply:addChild(Coord.ingap(temply,rulepic,"CC",0,"TT",0,true))
		
		layout:pushBackCustomItem(temply)
		
		self.m_introduceLayout = layout
	end
end
--显示规则层
function Tbnn_RuleWindows:m_showRuleLayout()
	if self.m_introduceLayout then
		self.m_introduceLayout:setVisible(false)
	end
	if self.m_ruleLayout then
		self.m_ruleLayout:setVisible(true)
	else
		local layout = display.newListView(nil,nil,nil,true)
		layout:setContentSize(cc.size(1050,400))
		self.m_contentLayout:addChild(Coord.ingap(self.m_contentLayout,layout,"CC",0,"CC",0))
		
		local temply = display.newLayout(cc.size(1050,982))
		local rulepic = display.newDynamicImage("game/tongbiniuniu/tbnn_rulepic_1.png")
		rulepic:setScale(1.3125)
		temply:addChild(Coord.ingap(temply,rulepic,"CC",0,"CC",0,true))
		
		layout:pushBackCustomItem(temply)
		self.m_ruleLayout = layout
	end
end
function Tbnn_RuleWindows:onCleanup()
	self:super("onCleanup")
	self.m_buttonMgr:removeAllEventListeners()
end
return Tbnn_RuleWindows