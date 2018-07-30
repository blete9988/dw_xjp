--[[
*	商城 Window
*	@author：lqh
]]
local MartWindows = class("MartWindows",require("src.ui.BaseUIWindows"))
function MartWindows:ctor()
	self.m_layouts = {}
	self.m_current_layout = nil
	
	local bg = display.newDynamicImage("res/images/single/single_windowbg_02.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,310,20,20),cc.size(1086,700)),"p_ui_1086.png")
	
	local uilayout = display.newLayout(cc.size(970,385))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
	display.debugLayout(uilayout)
	
	uilayout:addChild(Coord.ingap(uilayout,display.newText(display.trans("##2068"),30),"CC",0,"TB",8))
	
	local buttonMgr = require("src.base.control.RadioButtonControl").new()
	--按钮点击回掉
	buttonMgr:addEventListener(buttonMgr.EVT_SELECT,function(e,t) 
		if self.m_current_layout then 
			self.m_current_layout:setVisible(false)
		end
		if self.m_layouts[t.m_name] then
			self.m_layouts[t.m_name]:setVisible(true)
		else
			-- self.m_layouts[t.m_name] = require(t.m_name).new(onlySaveStatus)
			-- uilayout:addChild(Coord.ingap(uilayout,self.m_layouts[t.m_name],"CC",0,"CC",0))
		end
		self.m_current_layout = self.m_layouts[t.m_name]
	end)
	self.m_buttonMgr = buttonMgr
	local buttoncfg = {
		"",
		"",
		"",
	}
	local btn,temp
	for i = 1,#buttoncfg do
		btn = display.newTextButton("","p_btn_1019.png","",1,display.trans("##" .. 2059 + i - 1),30)
		btn.m_name = buttoncfg[i]
		display.setS9(btn,cc.rect(10,10,30,30),cc.size(273,52))
		buttonMgr:addButton(btn)
		if not temp then
			uilayout:addChild(Coord.ingap(uilayout,btn,"LL",64,"TB",50))
			buttonMgr:setCurrentButton(btn)
		else
			uilayout:addChild(Coord.outgap(temp,btn,"RL",4,"CC",0))
		end
		temp = btn
	end
end
--@override
function MartWindows:onCleanup()
	self:super("onCleanup")
end

return MartWindows