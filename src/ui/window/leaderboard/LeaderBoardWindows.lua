--[[
*	排行榜 window
*	@author：lqh
]]
local LeaderBoardWindows = class("LeaderBoardWindows",require("src.ui.BaseUIWindows"))

--LeaderBoardWindows ctor
function LeaderBoardWindows:ctor()
	self.m_layouts = {}
	self.m_current_layout = nil
	
	local bg = display.newImage("#res/images/single/single_windowbg_01.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,250,20,20),cc.size(1086,700)),"p_ui_1033.png")
	
	--[[local uilayout = display.newLayout(cc.size(970,450))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
	
	--@override 按钮高亮方法重写 
	local function setBrightStyle(target,value)
		if value == ccui.BrightStyle.highlight then
			target.m_txtimage:loadTexture(target.m_cfg.selectTxtPath,1)
		else
			target.m_txtimage:loadTexture(target.m_cfg.normalTxtPath,1)
		end
		target:m_setBrightStyle(value)
	end
	local buttoncfg = {
		{normalTxtPath = "p_ui_1035.png" , selectTxtPath = "p_ui_1034.png",name = "src.ui.window.leaderboard.WealthLeaderBoardLayout"},
		{normalTxtPath = "p_ui_1037.png" , selectTxtPath = "p_ui_1036.png",name = "src.ui.window.leaderboard.WinnerLeaderBoardLayout"},
		{normalTxtPath = "p_ui_1039.png" , selectTxtPath = "p_ui_1038.png",name = "src.ui.window.leaderboard.GrandRewardBoardLayout"},
	}
	
	--按钮点击回掉
	local buttonMgr = require("src.base.control.RadioButtonControl").new()
	buttonMgr:addEventListener(buttonMgr.EVT_SELECT,function(e,t) 
		if self.m_current_layout then 
			self.m_current_layout:setVisible(false)
		end
		if self.m_layouts[t.m_cfg.name] then
			self.m_layouts[t.m_cfg.name]:setVisible(true)
		else
			self.m_layouts[t.m_cfg.name] = require(t.m_cfg.name).new()
			uilayout:addChild(Coord.ingap(uilayout,self.m_layouts[t.m_cfg.name],"RR",-5,"CC",0))
		end
		self.m_current_layout = self.m_layouts[t.m_cfg.name]
	end)
	self.m_buttonMgr = buttonMgr
	local btn,temp
	for i = 1,#buttoncfg do
		btn = display.newButton("p_btn_1018.png","p_btn_1017.png")
		btn.m_txtimage = display.newImage(buttoncfg[i].normalTxtPath)
		btn.m_cfg = buttoncfg[i]
		btn.m_setBrightStyle = btn.setBrightStyle
		btn.setBrightStyle = setBrightStyle
		btn:addChild(Coord.ingap(btn,btn.m_txtimage,"CC",27,"CC",0))
		buttonMgr:addButton(btn)
		if not temp then
			uilayout:addChild(Coord.ingap(uilayout,btn,"LL",5,"TT",-5))
			buttonMgr:setCurrentButton(btn)
		else
			uilayout:addChild(Coord.outgap(temp,btn,"CC",0,"BT",-5))
		end
		temp = btn
	end
	--线
	uilayout:addChild(Coord.ingap(
		uilayout,
		display.setS9(display.newImage("p_ui_1048.png"),cc.rect(1,65,2,1),cc.size(4,450)),
		"LL",165,"CC",0
	))]]
	self:addChild(Coord.ingap(self,require("src.ui.window.leaderboard.WealthLeaderBoardLayout").new(),"CC",0,"BB",10))
end
function LeaderBoardWindows:onCleanup()
--	self.m_buttonMgr:removeAllEventListeners()
end

return LeaderBoardWindows