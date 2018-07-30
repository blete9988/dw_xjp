--[[
*	客服 Window
*	@author：lqh
]]
local ClientServiceWindows = class("ClientServiceWindows",require("src.ui.BaseUIWindows"))
function ClientServiceWindows:ctor()
	local bg = display.newImage("#res/images/single/single_windowbg_01.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,250,20,20),cc.size(1086,700)),"p_ui_1087.png")
	
	local uilayout = display.newLayout(cc.size(970,450))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
	
	local bg = display.newLayout()
	bg:setBackGroundImage("p_panel_1004.png",1)
	display.setBgS9(bg,cc.rect(10,10,20,20),cc.size(700,120))
	uilayout:addChild(Coord.ingap(uilayout,bg,"CC",0,"TT",-80))
	--企鹅
	local icon = display.newImage("p_ui_1088.png")
	bg:addChild(Coord.ingap(bg,icon,"LL",20,"CC",0))
	
	local tipTxt = display.newRichText(display.trans("##2065"),30)
	tipTxt:setWidth(400)
	tipTxt:setHorType("center")
	tipTxt:setLeading(10)
	bg:addChild(Coord.outgap(icon,tipTxt,"RL",20,"CC",0))
	
	local copyBtn = display.newButton("p_ui_1089.png","p_ui_1089.png")
	copyBtn:setPressedActionEnabled(true)
	bg:addChild(Coord.outgap(tipTxt,copyBtn,"RL",30,"CC",0))
	copyBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showMsg(display.trans("##2066"))
	end)
	
	local contactBtn = display.newButton("p_btn_1012.png","p_btn_1012.png")
	contactBtn:setPressedActionEnabled(true)
	uilayout:addChild(Coord.ingap(uilayout, contactBtn,"CC",0,"BB",100))
	contactBtn:addChild(Coord.ingap(contactBtn,display.newImage("p_ui_1090.png"),"CC",0,"CC",5))
	contactBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		cc.Application:getInstance():openURL("www.baidu.com")
	end)
	contactBtn:setVisible(false)
end

return ClientServiceWindows