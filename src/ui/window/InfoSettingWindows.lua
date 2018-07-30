--[[
*	个人信息设置 window
*	@author：lqh
]]
local InfoSettingWindows = class("InfoSettingWindows",require("src.ui.BaseUIWindows"))

local CheckItem = class("CheckItem",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function() 
	return display.newLayout(cc.size(187,89))
end)
--InfoSettingWindows ctor
function InfoSettingWindows:ctor()
	local bg = display.newImage("#res/images/single/single_windowbg_01.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,250,20,20),cc.size(1086,700)),"p_ui_1077.png")
	
	local uilayout = display.newLayout(cc.size(970,450))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
	
	uilayout:addChild(Coord.ingap(uilayout,display.newText(display.trans("##2052"),30),"CC",0,"TB",10))
	
	--玩家头像
	local playerIcon = require("src.ui.item.HeadIcon").new(Player.headpath)
	uilayout:addChild(Coord.ingap(uilayout,playerIcon,"CC",-220,"TT",-30))
	
	--名字输入框背景
	local nameInputBg = display.newImage("p_ui_1081.png")
	uilayout:addChild(Coord.outgap(playerIcon,nameInputBg,"RL",0,"TT",-10))
	
	if Player.status:getStatus(ST.STATUS_PLAYER_NAME_CHANGED) ~= 0 then
		--已修改过名字
		nameInputBg:addChild(Coord.ingap(nameInputBg,display.newText(Player.name,28),"LL",40,"CC",0))
	else
		--名字输入框
		local nameInput = display.newInputText(cc.size(260,50),nil,28)
		nameInput:setMaxLength(12)
		nameInput:setText(Player.name)
		nameInputBg:addChild(Coord.ingap(nameInputBg,nameInput,"LL",40,"CC",0))
		nameInputBg:setTouchEnabled(true)
		nameInputBg:addTouchEventListener(function(t,e) 
			if e ~= ccui.TouchEventType.ended then return end
			nameInput:touchDownAction(self,ccui.TouchEventType.ended)
		end)
		
		--确认修改名字按钮
		local confirmBtn = display.newButton("p_btn_1012.png","p_btn_1012.png")
		confirmBtn:setPressedActionEnabled(true)
		confirmBtn:addChild(Coord.ingap(confirmBtn,display.newImage("p_ui_1078.png"),"CC",0,"CC",5))
		uilayout:addChild(Coord.outgap(nameInputBg,confirmBtn,"RL",20,"CC",0))
		confirmBtn:addTouchEventListener(function(t,e) 
			if e ~= ccui.TouchEventType.ended then return end
			local newname = string.trim(nameInput:getText())
			if newname == "" then return end
			if string.strlen(newname) > 8 then
				display.showMsg(display.trans("##20009"))
				return
			end
			local _,value = string.gsub(newname,"[=,/,\\,%%]","")
			if value > 0 then
				display.showMsg(display.trans("##20010"))
				return
			end
			ConnectMgr.connect("normal.ModifyNameConnect" , newname,function(result) 
				if result ~= 0 then return end
				confirmBtn:removeFromParent()
				nameInput:removeFromParent()
				nameInputBg:addChild(Coord.ingap(nameInputBg,display.newText(Player.name,28),"LL",40,"CC",0))
			end)
		end)
	end
	
	--ID文本
	local idTxt = display.newText(display.trans("##2000",Player.id),38,Color.dantuhuangse)
	uilayout:addChild(Coord.outgap(playerIcon,idTxt,"RL",10,"BB",0))
	--复制id按钮
	local copyBtn = display.newRichText(display.trans("##2053"),38,Color.dantuhuangse)
	copyBtn:setUnderLine(true)
	uilayout:addChild(Coord.outgap(idTxt,copyBtn,"RL",40,"CC",0))
	copyBtn:addEventListener(copyBtn.EVT_LINK,function() 
		--native 接口待实现
		--复制成功后提示
		display.showMsg(display.trans("##20008"))
	end)
	
	--头像列表
	local listbg = display.setS9(display.newImage("p_panel_1001.png"),cc.rect(20,20,30,30),cc.size(850,160))
	uilayout:addChild(Coord.ingap(uilayout,listbg,"CC",0,"BB",60))
	
	local listview = display.newListView(ccui.ScrollViewDir.horizontal,ccui.ListViewGravity.centerVertical,50,true)
	listview:setContentSize( cc.size(830,150) )
	listbg:addChild(Coord.ingap(listbg,listview,"CC",0,"CC",0))
	
	local headitem,currentItem
	
	local function iconTouchCallback(t,e)
		if e ~= ccui.TouchEventType.ended or t == currentItem then return end
		ConnectMgr.connect("normal.ModifyHeadIconConnect" , t.index,function(result) 
			if result ~= 0 then return end
			if currentItem then
				currentItem.flagIcon:removeFromParent()
				currentItem.flagIcon = nil
			end
			t.flagIcon = display.newImage("p_ui_1082.png")
			t:addChild(Coord.ingap(t,t.flagIcon,"RR",-2,"BB",2))
			currentItem = t
			playerIcon:setHead(Player.headpath)
		end)
	end
	
	for i = 1,ST.PLY_HEADICON_LEN do
		headitem = require("src.ui.item.HeadIcon").new(string.format("res/images/icons/head/head_icon_%s.png",i))
		headitem.index = i
		headitem:setTouchEnabled(true)
		headitem:addTouchEventListener(iconTouchCallback)
		headitem:setBackGroundImage("p_ui_1079.png",1)
		listview:pushBackCustomItem(headitem)
		if i == Player.headIndex then
			headitem.flagIcon = display.newImage("p_ui_1082.png")
			headitem:addChild(Coord.ingap(headitem,headitem.flagIcon,"RR",-2,"BB",2))
			currentItem = headitem
		end
	end
end

return InfoSettingWindows