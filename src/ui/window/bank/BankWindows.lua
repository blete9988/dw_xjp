--[[
*	排行榜 window
*	@author：lqh
]]
local BankWindows = class("BankWindows",require("src.ui.BaseUIWindows"))

--BankWindows ctor
function BankWindows:ctor(onlySaveStatus)
	self:addEvent(ST.COMMAND_GAME_PSW_QUIT)
	onlySaveStatus = onlySaveStatus or 0
	self.m_layouts = {}
	self.m_current_layout = nil
	local bg = display.newDynamicImage("res/images/single/single_windowbg_02.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,310,20,20),cc.size(1086,700)),"p_ui_1050.png")
	
	local uilayout = display.newLayout(cc.size(970,385))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
--	display.debugLayout(uilayout)
	
	local buttonMgr = require("src.base.control.RadioButtonControl").new()
	--按钮点击回掉
	buttonMgr:addEventListener(buttonMgr.EVT_SELECT,function(e,t) 
		if self.m_current_layout then 
			self.m_current_layout:setVisible(false)
		end
		if self.m_layouts[t.m_name] then
			self.m_layouts[t.m_name]:setVisible(true)
		else
			self.m_layouts[t.m_name] = require(t.m_name).new(onlySaveStatus)
			uilayout:addChild(Coord.ingap(uilayout,self.m_layouts[t.m_name],"CC",0,"CC",0))
		end
		self.m_current_layout = self.m_layouts[t.m_name]
	end)
	self.m_buttonMgr = buttonMgr
	local buttoncfg = {
		"src.ui.window.bank.DeositLayout",
		"src.ui.window.bank.TransferLayout",
		"src.ui.window.bank.DetailLayout",
	}
	local btn,temp
	if onlySaveStatus ~= 0 then
		for i = 1,#buttoncfg do
			btn = display.newTextButton("p_btn_1020.png","p_btn_1019.png","",1,display.trans("##" .. 2015 + i - 1),30)
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
	else
		btn = display.newTextButton("p_btn_1020.png","p_btn_1019.png","",1,display.trans("##2043"),30)
		btn.m_name = buttoncfg[1]
		display.setS9(btn,cc.rect(10,10,30,30),cc.size(273,52))
		buttonMgr:addButton(btn)
		uilayout:addChild(Coord.ingap(uilayout,btn,"CC",-8,"TB",50))
		buttonMgr:setCurrentButton(btn)
	end
	
	if Player.status:getStatus(ST.STATUS_PLAYER_PSW_SETTED) ~= 1 then
		display.showMsg(display.trans("##20012"))
		self:delayTimer(function() 
			display.showWindow("src.ui.window.PswSettingWindows")
		end,0)
	end
end

--@override
function BankWindows:handlerEvent(event,arg)
	if event == ST.COMMAND_GAME_PSW_QUIT then
		if Player.status:getStatus(ST.STATUS_PLAYER_PSW_SETTED) ~= 1 then
			self:executQuit()
		end
	end
end
function BankWindows:onCleanup()
	self.m_buttonMgr:removeAllEventListeners()
end

return BankWindows