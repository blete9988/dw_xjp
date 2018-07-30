--[[
*	密码设置  window
*	@author：lqh
]]
local PswSettingWindows = class("PswSettingWindows",require("src.ui.BaseUIWindows"))

--PswSettingWindows ctor
function PswSettingWindows:ctor()
	local bg = display.newImage("#res/images/single/single_windowbg_01.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,250,20,20),cc.size(1086,700)),"p_ui_1012.png")
	self:addChild(Coord.ingap(self,require("src.base.log.debugKey")(),"LL",0,"BB",0))
	
	local uilayout = display.newLayout(cc.size(970,450))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
	
	self:addChild(Coord.outgap(uilayout,display.newText(display.trans("##2057"),26),"CC",0,"TB",10))
	
	local tipTxt = display.newRichText(display.trans("##2058"),28)
	tipTxt:setUnderLine(true)
	uilayout:addChild(Coord.ingap(uilayout,tipTxt,"RR",-45,"CC",30))
	
	local pswStr_1,pswStr_2 = "",""
	--密码背景
	local passwordbg = display.newLayout()
	passwordbg:setTouchEnabled(true)
	passwordbg:setBackGroundImage("p_panel_1004.png",1)
	display.setBgS9(passwordbg,cc.rect(10,10,20,20),cc.size(520,70))
	uilayout:addChild(Coord.ingap(uilayout,passwordbg,"LL",100,"TT",-100))
	passwordbg:addChild(Coord.ingap(passwordbg, display.newText(display.trans("##2030"),28,Color.GREY),"LL",10,"CC",0))
	--提示图标
	local flagIcon_1 = display.newImage("p_ui_1082.png")
	flagIcon_1:setVisible(false)
	uilayout:addChild(Coord.outgap(passwordbg,flagIcon_1,"RL",15,"CC",0))
	--密码输入
	local passwordInput = display.newInputText(cc.size(260,50),nil,28)
	passwordInput:setMaxLength(8)
	passwordInput:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	passwordbg:addChild(Coord.ingap(passwordbg,passwordInput,"LL",135,"CC",0))
	
	passwordbg:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		passwordInput:touchDownAction(self,ccui.TouchEventType.ended)
	end)
	passwordInput:registerScriptEditBoxHandler(function(strEventName,pSender) 
		if strEventName == "ended" then
			pswStr_1 = passwordInput:getText()
			flagIcon_1:setVisible(true)
			if pswStr_1:len() == 8 then
				flagIcon_1:loadTexture("p_ui_1082.png",1)
			else
				flagIcon_1:loadTexture("p_ui_1013.png",1)
			end
		end
	end)
	
	--密码背景
	local passwordbg1 = display.newLayout()
	passwordbg1:setTouchEnabled(true)
	passwordbg1:setBackGroundImage("p_panel_1004.png",1)
	display.setBgS9(passwordbg1,cc.rect(10,10,20,20),cc.size(520,70))
	uilayout:addChild(Coord.outgap(passwordbg,passwordbg1,"CC",0,"BT",-40))
	passwordbg1:addChild(Coord.ingap(passwordbg1, display.newText(display.trans("##2030"),28,Color.GREY),"LL",10,"CC",0))
	--提示图标
	local flagIcon_2 = display.newImage("p_ui_1082.png")
	flagIcon_2:setVisible(false)
	uilayout:addChild(Coord.outgap(passwordbg1,flagIcon_2,"RL",15,"CC",0))
	--密码确认输入
	local passwordConfirmInput = display.newInputText(cc.size(260,50),nil,28)
	passwordConfirmInput:setMaxLength(8)
	passwordConfirmInput:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	passwordbg1:addChild(Coord.ingap(passwordbg1,passwordConfirmInput,"LL",135,"CC",0))
	
	passwordbg1:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		passwordConfirmInput:touchDownAction(self,ccui.TouchEventType.ended)
	end)
	passwordConfirmInput:registerScriptEditBoxHandler(function(strEventName,pSender) 
		if strEventName == "ended" then
			pswStr_1 = passwordInput:getText()
			pswStr_2 = passwordConfirmInput:getText()
			flagIcon_2:setVisible(true)
			if pswStr_2:len() == 8 and pswStr_1 == pswStr_2 then
				flagIcon_2:loadTexture("p_ui_1082.png",1)
			else
				flagIcon_2:loadTexture("p_ui_1013.png",1)
			end
		end
	end)
	
	
	local confirmBtn = display.newButton("p_btn_1012.png","p_btn_1012.png")
	confirmBtn:setPressedActionEnabled(true)
	confirmBtn:addChild(Coord.ingap(confirmBtn,display.newImage("p_ui_1053.png"),"CC",0,"CC",5))
	uilayout:addChild(Coord.ingap(uilayout,confirmBtn,"CC",0,"BB",50))
	confirmBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		if pswStr_1 ~= pswStr_2 then return end
		
		ConnectMgr.connect("normal.PswSettingConnect" , pswStr_2,function(result) 
			if result ~= 0 then return end
			display.showMsg(display.trans("##20014"))
			self:executQuit()
		end)
	end)
end

function PswSettingWindows:onCleanup()
	self:super("onCleanup")
	CommandCenter:sendEvent(ST.COMMAND_GAME_PSW_QUIT,nil,true)
end

return PswSettingWindows