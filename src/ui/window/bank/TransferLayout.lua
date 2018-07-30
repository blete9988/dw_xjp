--[[
*	银行转账 层
*	@author：lqh
]]
local TransferLayout = class("TransferLayout",require("src.base.extend.CCLayerExtend"),IEventListener,function() 
	local container = display.newLayout(cc.size(970,385))
	container:setTouchEnabled(true)
	return container
end)

function TransferLayout:ctor()
	self:super("ctor")
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	
	--钱包背景
	local walletbg = display.newLayout()
	walletbg:setBackGroundImage("p_panel_1004.png",1)
	display.setBgS9(walletbg,cc.rect(10,10,20,20),cc.size(330,50))
	self:addChild(Coord.ingap(self,walletbg,"CR",-60,"TT",-25))
	
	walletbg:addChild(Coord.ingap(walletbg, display.newImage("p_ui_1054.png"),"LR",30,"CC",5))
	walletbg:addChild(Coord.ingap(walletbg, display.newText(display.trans("##2027"),28,Color.GREY),"LL",35,"CC",0))
	--钱包数量
	local wallettxt = display.newText(string.thousandsformat(Player.gold),28)
	wallettxt:setAnchorPoint( cc.p(0,0.5) )
	walletbg:addChild(Coord.ingap(walletbg,wallettxt,"LL",110,"CC",0))
	self.m_wallettxt = wallettxt
	
	--存款背景
	local banbg = display.newLayout()
	banbg:setBackGroundImage("p_panel_1004.png",1)
	display.setBgS9(banbg,cc.rect(10,10,20,20),cc.size(330,50))
	self:addChild(Coord.ingap(self,banbg,"CL",90,"TT",-25))
	
	banbg:addChild(Coord.ingap(banbg, display.newImage("p_ui_1055.png"),"LR",30,"CC",9))
	banbg:addChild(Coord.ingap(banbg, display.newText(display.trans("##2028"),28,Color.GREY),"LL",35,"CC",0))
	--存款数量
	local banktxt = display.newText(string.thousandsformat(Player.bank),28)
	banktxt:setAnchorPoint( cc.p(0,0.5) )
	banbg:addChild(Coord.ingap(banbg,banktxt,"LL",110,"CC",0))
	self.m_banktxt = banktxt
	
	--输入金额背景
	local amountbg = display.newLayout()
	amountbg:setTouchEnabled(true)
	amountbg:setBackGroundImage("p_panel_1004.png",1)
	display.setBgS9(amountbg,cc.rect(10,10,20,20),cc.size(400,50))
	self:addChild(Coord.outgap(walletbg,amountbg,"RR",50,"BT",-30))
	amountbg:addChild(Coord.ingap(amountbg, display.newText(display.trans("##2029"),28,Color.GREY),"LL",10,"CC",0))
	--金额输入
	local amount_num = 0
	local amountInput = display.newInputText(cc.size(260,50),nil,28)
	amountInput:setMaxLength(12)
	amountInput:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	amountbg:addChild(Coord.ingap(amountbg,amountInput,"LL",135,"CC",0))
	amountbg:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		amountInput:touchDownAction(self,ccui.TouchEventType.ended)
	end)
	
	amountInput:registerScriptEditBoxHandler(function(strEventName,pSender) 
		if strEventName == "ended" then
			amount_num = tonum(amountInput:getText())
			amountInput:setText(string.thousandsformat(amount_num))
		elseif(strEventName == "began")then
			amountInput:setText("")
			amount_num = 0
		end
	end)

	--密码背景
	local passwordbg = display.newLayout()
	passwordbg:setTouchEnabled(true)
	passwordbg:setBackGroundImage("p_panel_1004.png",1)
	display.setBgS9(passwordbg,cc.rect(10,10,20,20),cc.size(400,50))
	self:addChild(Coord.outgap(amountbg,passwordbg,"CC",0,"BT",-20))
	passwordbg:addChild(Coord.ingap(passwordbg, display.newText(display.trans("##2030"),28,Color.GREY),"LL",10,"CC",0))
	--密码输入
	local passwordInput = display.newInputText(cc.size(260,50),nil,28)
	passwordInput:setMaxLength(8)
	passwordInput:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	passwordbg:addChild(Coord.ingap(passwordbg,passwordInput,"LL",135,"CC",0))
	
	passwordbg:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		passwordInput:touchDownAction(self,ccui.TouchEventType.ended)
	end)
	
	--最近接收人背景
	local nearAccountbg = display.newLayout()
	nearAccountbg:setTouchEnabled(true)
	nearAccountbg:setBackGroundImage("p_panel_1004.png",1)
	display.setBgS9(nearAccountbg,cc.rect(10,10,20,20),cc.size(400,50))
	self:addChild(Coord.outgap(passwordbg,nearAccountbg,"CC",0,"BT",-20))
	nearAccountbg:addChild(Coord.ingap(nearAccountbg, display.newText(display.trans("##2034"),28,Color.GREY),"LL",10,"CC",0))
	--接收人ID输入
	local accountInput = display.newInputText(cc.size(260,50),nil,28)
	accountInput:setMaxLength(12)
	accountInput:setInputFlag(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	nearAccountbg:addChild(Coord.ingap(nearAccountbg,accountInput,"LL",135,"CC",0))
	
	nearAccountbg:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		accountInput:touchDownAction(self,ccui.TouchEventType.ended)
	end)
	--最近接受人按钮
	local nearAccountBtn = display.newTextButton("p_btn_1021.png","p_btn_1021.png","",1,display.trans("##2035"),28)
	nearAccountBtn:setPressedActionEnabled(true)
	display.setS9(nearAccountBtn,cc.rect(10,10,20,20),cc.size(200,50))
	self:addChild(Coord.outgap(nearAccountbg,nearAccountBtn,"RL",20,"CC",0))
	nearAccountBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local str = require("src.base.tools.storage").getXML("nearest_account")
		if str and str ~= "" then
			accountInput:setText(str)
		end
	end)
	
	--按钮点击回掉
	local function btnTouchHandler(t,e)
		if e ~= ccui.TouchEventType.ended then return end
		-- amountInput:setText(tonum(amountInput:getText()) + t.m_value)
		amountInput:setText(string.thousandsformat(amount_num+ t.m_value)) 
		amount_num = amount_num + t.m_value

	end
	
	local btncfg = {
		{name = "+10万", value = 100000},
		{name = "+100万", value = 1000000},
		{name = "+1000万", value = 10000000},
		{name = "+1亿", value = 100000000},
	}
	local quickbtn = display.newTextButton("p_btn_1021.png","p_btn_1021.png","",1,btncfg[1].name,28)
	quickbtn:setPressedActionEnabled(true)
	quickbtn.m_value = btncfg[1].value
	display.setS9(quickbtn,cc.rect(10,10,20,20),cc.size(140,50))
	quickbtn:addTouchEventListener(btnTouchHandler)
	self:addChild(Coord.outgap(amountbg,quickbtn,"RL",20,"CC",0))
	quickbtn = display.newTextButton("p_btn_1021.png","p_btn_1021.png","",1,btncfg[2].name,28)
	quickbtn:setPressedActionEnabled(true)
	quickbtn.m_value = btncfg[2].value
	display.setS9(quickbtn,cc.rect(10,10,20,20),cc.size(140,50))
	quickbtn:addTouchEventListener(btnTouchHandler)
	self:addChild(Coord.outgap(amountbg,quickbtn,"RL",180,"CC",0))
	quickbtn = display.newTextButton("p_btn_1021.png","p_btn_1021.png","",1,btncfg[3].name,28)
	quickbtn:setPressedActionEnabled(true)
	quickbtn.m_value = btncfg[3].value
	display.setS9(quickbtn,cc.rect(10,10,20,20),cc.size(140,50))
	quickbtn:addTouchEventListener(btnTouchHandler)
	self:addChild(Coord.outgap(passwordbg,quickbtn,"RL",20,"CC",0))
	quickbtn = display.newTextButton("p_btn_1021.png","p_btn_1021.png","",1,btncfg[4].name,28)
	quickbtn:setPressedActionEnabled(true)
	quickbtn.m_value = btncfg[4].value
	display.setS9(quickbtn,cc.rect(10,10,20,20),cc.size(140,50))
	quickbtn:addTouchEventListener(btnTouchHandler)
	self:addChild(Coord.outgap(passwordbg,quickbtn,"RL",180,"CC",0))
	
	local clearbtn = display.newRichText(display.trans("##2031"),38)
	self:addChild(Coord.outgap(quickbtn,clearbtn,"RL",20,"TC",8))
	clearbtn:addEventListener(clearbtn.EVT_LINK,function() 
		amountInput:setText("")
		amount_num = 0
	end)
	
	--确定按钮
	local confirmBtn = display.newButton("p_btn_1012.png","p_btn_1012.png")
	confirmBtn:addChild(Coord.ingap(confirmBtn, display.newImage("p_ui_1053.png"),"CC",-5,"CC",5))
	confirmBtn:setPressedActionEnabled(true)
	self:addChild(Coord.ingap(self,confirmBtn,"CC",0,"BB",5))
	confirmBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local value = tonum(amount_num)
		if value <= 0 then
			return
		end
		if Player.gold < value then
			--现金不够
			display.showMsg(display.trans("##2032"))
			return
		end
		local psw = passwordInput:getText()
		if psw == "" then
			display.showMsg(display.trans("##20013"))
			return
		end
		if accountInput:getText() == "" then
			display.showMsg(display.trans("##2036"))
			return
		end
		ConnectMgr.connect("normal.TransferAccountsConnect" , value,psw,tonum(accountInput:getText()),function(result) 
			if result ~= 0 then return end
			display.showMsg(display.trans("##20015",value))
			require("src.base.tools.storage").saveXML("nearest_account",accountInput:getText())
			amountInput:setText("")
			amount_num = 0
			passwordInput:setText("")
		end)
	end)
end

--@override
function TransferLayout:handlerEvent(event,arg)
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		self.m_wallettxt:setString(string.thousandsformat(Player.gold))
		self.m_banktxt:setString(string.thousandsformat(Player.bank))
	end
end

function TransferLayout:onCleanup()
	self:removeAllEvent()
end

return TransferLayout