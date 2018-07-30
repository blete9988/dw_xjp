--[[
*	签到window
*	@author：lqh
]]
local DailySignWindows = class("DailySignWindows",require("src.ui.BaseUIWindows"))
--签到 item
local SignItem = class("SignItem",function() 
	local layer = display.newLayout(cc.size(210,210))
	layer:setAnchorPoint( cc.p(0.5,0.5) )
	layer:setTouchEnabled(true)
	return layer
end)
SignItem.bgpath = {"p_ui_bg_yellow.png","p_ui_bg_purple.png"}
SignItem.panelpath = {"p_ui_namebg_purple.png","p_ui_namebg_blue.png"}

--DailySignWindows ctor
function DailySignWindows:ctor()
	local bg = display.newImage("#res/images/single/single_windowbg_01.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,250,20,20),cc.size(1086,700)),"p_ui_1017.png")
	
	local uilayout = display.newLayout(cc.size(970,450))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
--	display.debugLayout(uilayout)
	uilayout:addChild(Coord.ingap(uilayout,display.newText(display.trans("##2012"),30),"CC",0,"TB",13))

	local datas = {
		{ dayIndex = 1,pic = "sign_icon_1.png"},
		{ dayIndex = 2,pic = "sign_icon_2.png"},
		{ dayIndex = 3,pic = "sign_icon_3.png"},
		{ dayIndex = 4,pic = "sign_icon_4.png"},
		{ dayIndex = 5,pic = "sign_icon_5.png"},
		{ dayIndex = 6,pic = "sign_icon_6.png"},
		{ dayIndex = 7,pic = "sign_icon_7.png"},
	}
	
	local itemlist = {}
	local item,temp
	for i = 1,4 do
		item = SignItem.new(datas[i])
		if temp then
			uilayout:addChild(Coord.outgap(temp,item,"RL",20,"CC",0))
		else
			uilayout:addChild(Coord.ingap(uilayout,item,"LL",35,"CB",5))
		end
		temp = item
		itemlist[datas[i].dayIndex] = item
	end
	temp = SignItem.new(datas[6])
	itemlist[datas[6].dayIndex] = temp
	uilayout:addChild(Coord.ingap(uilayout,temp,"CC",0,"CT",-5))
	item = SignItem.new(datas[5])
	itemlist[datas[5].dayIndex] = item
	uilayout:addChild(Coord.outgap(temp,item,"LR",-12,"CC",0))
	item = SignItem.new(datas[7])
	itemlist[datas[7].dayIndex] = item
	uilayout:addChild(Coord.outgap(temp,item,"RL",12,"CC",0))
	
	
	local signbtn = display.newButton("p_btn_1012.png","p_btn_1012.png")
	signbtn:addChild(Coord.ingap(signbtn, display.newImage("p_ui_1016.png"),"CC",-5,"CC",5))
	signbtn:setPressedActionEnabled(true)
	uilayout:addChild(Coord.outgap(item,signbtn,"RL",0,"BB",0))
	signbtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
	end)
end

-- ---------------------------------class----------------------------------
function SignItem:ctor(data)
	local bg =  display.newImage(SignItem.bgpath[(data.dayIndex - 1)%2 + 1])
	self:addChild(Coord.ingap(self,bg,"CC",0,"CC",0))
	
	local namepanel = display.newImage(SignItem.panelpath[(data.dayIndex - 1)%2 + 1])
	bg:addChild(Coord.ingap(bg,namepanel,"CC",0,"BB",15))
	
	local icon = display.newDynamicImage(string.format("res/images/icons/sign/%s",data.pic))
	bg:addChild(Coord.outgap(namepanel,icon,"CC",0,"TB",0))
	
	local nametxt = display.newText(display.trans("##2011",data.dayIndex),36)
	bg:addChild(Coord.outgap(namepanel,nametxt,"CC",0,"CC",0))
end
-- -------------------------------------------------------------------------
return DailySignWindows