--[[
*	百人牛牛 scene
*	@author：lqh
]]
local Brnn_Scene = class("Brnn_Scene",require("src.base.extend.CCSceneExtend"),IEventListener)
function Brnn_Scene:ctor(room)
	self.brnn_gameMgr = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance()
	self.brnn_gameMgr:setRoom(room)
	self:super("ctor")
	SoundsManager.playMusic("brnn_bg",true)
	
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(115)),20)
	self:addEvent(ST.COMMAND_SOCKET_BREAK)    					--jinrf Distributed desgin
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self:addEvent(ST.COMMAND_GAMEBRNN_INITROOM)
	self:addEvent(ST.COOMAND_GAMEBRNN_BEGANBET)
	self:addEvent(ST.COMMAND_GAMEBRNN_RESULT)
	self:addEvent(ST.COMMAND_GAMEBRNN_APPLYNUM_UPDATE)
	self:addEvent(ST.COMMAND_GAMEBRNN_BET)
	self:addEvent(ST.COMMAND_GAMEBRNN_POKER_OVER)
	self:addEvent(ST.COMMAND_GAMEBRNN_RESULT_OVER)
	self:addEvent(ST.COMMAND_GAMEBRNN_MASTER_UPDATE)
	self:addEvent(ST.COMMAND_GAMEBRNN_DESKTOPPLAYERS_UPDATE)
	
	self:addChild(Coord.ingap(self,display.newImage("#game/bairenniuniu/brnn_desktop_background.jpg"),"CC",0,"CC",0))
	self.m_headlist = {}
	--左上
	local headitem = require("src.games.bairenniuniu.ui.Brnn_PlayerHeadItem").new()
	self:addChild(Coord.ingap(self,headitem,"LL",100,"TT",-110))
	table.insert(self.m_headlist,headitem)
	--坐下
	headitem = require("src.games.bairenniuniu.ui.Brnn_PlayerHeadItem").new()
	self:addChild(Coord.ingap(self,headitem,"LL",100,"BB",110))
	table.insert(self.m_headlist,headitem)
	--右上
	headitem = require("src.games.bairenniuniu.ui.Brnn_PlayerHeadItem").new()
	self:addChild(Coord.ingap(self,headitem,"RR",-100,"TT",-110))
	table.insert(self.m_headlist,headitem)
	--右下
	headitem = require("src.games.bairenniuniu.ui.Brnn_PlayerHeadItem").new()
	self:addChild(Coord.ingap(self,headitem,"RR",-100,"BB",110))
	table.insert(self.m_headlist,headitem)
	
	--筹码层
	self.m_betlayout = require("src.games.bairenniuniu.ui.BetLayout").new()
	self:addChild(Coord.ingap(self,self.m_betlayout,"CC",0,"CC",0))
	
	--倒计时item
	local cdItem = require("src.games.bairenniuniu.ui.ClockCountDownItem").new()
	self:addChild(Coord.ingap(self,cdItem,"CC",0,"CC",-130))
	self.m_cdItem = cdItem
	
	self:m_initTopView()
	
	--扑克层
	self.m_pokerLayout = require("src.games.bairenniuniu.ui.PokerLayout").new()
	self:addChild(Coord.ingap(self,self.m_pokerLayout,"CC",0,"CC",0))
	
	self:m_initBottomView()
	
	require("src.ui.item.TalkControl").show(room,self)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",5,"TT",-20))
	
	self.brnn_gameMgr:initgame()
end
--初始化顶部面板
function Brnn_Scene:m_initTopView()
	local layout = display.newLayout()
	layout:setBackGroundImage("ui_brnn_1038.png",1)
	display.setBgS9(layout,cc.rect(380,50,10,10),cc.size(D_SIZE.w,121))
	self:addChild(Coord.ingap(self,layout,"CC",0,"TT",0))
	
	local tempicon = display.newSprite("ui_brnn_1046.png")
	layout:addChild(Coord.ingap(layout,tempicon,"LL",345,"TT",-10))
	self.m_zhuangIcon = tempicon
	
	--金币显示
	local goldbg = display.newImage("ui_brnn_1047.png")
	display.setS9(goldbg,cc.rect(20,10,80,20),cc.size(255,36))
	layout:addChild(Coord.outgap(tempicon,goldbg,"LL",5,"BT",-3))
	goldbg:addChild(Coord.ingap(goldbg,display.newImage("ui_brnn_1031.png"),"LL",-5,"CC",0))
	
	--上下庄按钮
	local zhuangBtn = display.newButton("ui_brnn_1048.png","ui_brnn_1049.png")
	layout:addChild(Coord.ingap(layout,zhuangBtn,"RR",-345,"CC",15))
	zhuangBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		if not self.brnn_gameMgr:checkApplyMaster() then
			--申请下庄
			ConnectMgr.connect("src.games.bairenniuniu.connect.Brnn_XiaZhuangConnect" , function(result) 
				if result ~= 0 then return end
				display.showMsg(display.trans("##4013"))
				self.brnn_gameMgr:setAlreadyApply(false)
				self.m_zhuangBtn:loadTextureNormal("ui_brnn_1048.png",1)
				self.m_zhuangBtn:loadTexturePressed("ui_brnn_1049.png",1)
			end)
		else
			if not display.checkGold(self.brnn_gameMgr.masterGoldLimit,display.trans("##20005",string.cnspNmbformat(self.brnn_gameMgr.masterGoldLimit))) then 
				return 
			end
			--申请上庄
			ConnectMgr.connect("src.games.bairenniuniu.connect.Brnn_ShangZhuangConnect" , function(result) 
				if result ~= 0 then return end
				display.showMsg(display.trans("##4012"))
				self.brnn_gameMgr:setAlreadyApply(true)
				self.m_zhuangBtn:loadTextureNormal("ui_brnn_1050.png",1)
				self.m_zhuangBtn:loadTexturePressed("ui_brnn_1051.png",1)
			end)
		end
	end)
	self.m_zhuangBtn = zhuangBtn
	
	--规则按钮
	local ruleBtn = display.newButton("ui_brnn_1044.png","ui_brnn_1044.png")
	ruleBtn:setPressedActionEnabled(true)
	layout:addChild(Coord.ingap(layout,ruleBtn,"RR",-5,"CC",0))
	ruleBtn:addChild(Coord.ingap(ruleBtn,display.newImage("ui_brnn_1045.png"),"CC",0,"CC",0))
	ruleBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.games.bairenniuniu.ui.Brnn_RuleWindows")
	end)
	--记录按钮
	local recordBtn = display.newButton("ui_brnn_1044.png","ui_brnn_1044.png")
	recordBtn:setPressedActionEnabled(true)
	layout:addChild(Coord.difscgap(layout,recordBtn,"RR",-5,"CC",0))
	recordBtn:addChild(Coord.ingap(recordBtn,display.newImage("ui_brnn_1007.png"),"CC",0,"CC",0))
	recordBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.games.bairenniuniu.ui.Brnn_TrendWindows")
	end)
	
	--庄家名字
	local masterNameTxt = display.newText("",24,Color.danrubaise)
	masterNameTxt:setAnchorPoint( cc.p(0,0.5) )
	layout:addChild(Coord.outgap(tempicon,masterNameTxt,"RL",3,"CC",0))
	self.m_masterNameTxt = masterNameTxt
	--庄家金币文本
	local masterGoldTxt = require("src.base.control.ScrollNumberComponent").new(0,26,Color.dantuhuangse)
	masterGoldTxt:setAnchorPoint( cc.p(0,0.5) )
	goldbg:addChild(Coord.ingap(goldbg,masterGoldTxt,"LL",40,"CC",0))
	self.m_masterGoldTxt = masterGoldTxt
	--上庄申请人数
	local applyTxt = display.newText(display.trans("##4002",0),20,Color.danrubaise)
	layout:addChild(Coord.outgap(zhuangBtn,applyTxt,"CC",0,"BT",7))
	self.m_applyTxt = applyTxt
end
--初始化底部面板
function Brnn_Scene:m_initBottomView()
	local layout = display.newLayout(cc.size(D_SIZE.w,121))
	layout:setBackGroundImage("ui_brnn_1032.png",1)
	self:addChild(Coord.ingap(self,layout,"CC",0,"BB",-5))
	
	--筹码选中状态外发光
	local btnflow = display.newImage("ui_brnn_1043.png")
	btnflow:setVisible(false)
	btnflow:setScale(1.35)
	btnflow:runAction(cc.RepeatForever:create(cc.Sequence:create({
		cc.ScaleTo:create(1,1.3),
		cc.ScaleTo:create(1,1.36),
	})))
	Coord.ingap(layout,btnflow,"CC",0,"CC",0)
	layout:addChild(btnflow)
	self.m_btnflow = btnflow
	local buttonMgr = require("src.base.control.RadioButtonControl").new()
	--单选按钮
	buttonMgr:addEventListener(buttonMgr.EVT_SELECT,function(e,t) 
		self.m_currentBetBtn = t
		--记录当前所选赌注的数据
		self.brnn_gameMgr:setCurrentBet(t.betvalue,t:getParent():convertToWorldSpace(cc.p(t:getPosition())))
		
		btnflow:setVisible(true)
		Coord.outgap(t,btnflow,"CC",0,"CC",4,true)
	end)
	self.m_buttonMgr = buttonMgr
	--下注金额配置
	local config = {1000,10000,100000,1000000,5000000,10000000}
	self.m_betButtons = {}
	--下注按钮
	local btn,temp
	for i = 1,#config do
		btn = require("src.games.bairenniuniu.ui.BetButton").new(config[i])
		buttonMgr:addButton(btn)
		if not temp then
			layout:addChild(Coord.ingap(layout,btn,"CC",-308,"CC",5))
		else
			layout:addChild(Coord.outgap(temp,btn,"RL",50,"CC",0))
		end
		btn:setShowStatus(false)
		self.m_betButtons[i] = btn
		temp = btn
	end
	layout:addChild(Coord.ingap(layout,display.setS9(display.newImage("ui_brnn_1033.png"),cc.rect(120,20,5,5),cc.size(760,52)),"CC",-8,"BB",2))
	
	--金币显示
	local goldicon = display.newImage("ui_brnn_1031.png")
	layout:addChild(Coord.ingap(layout,goldicon,"LL",10,"BB",25))
	local goldtxt = require("src.base.control.ScrollNumberComponent").new(Player.gold,30,Color.dantuhuangse)
	goldtxt:setAnchorPoint( cc.p(0,0.5) )
	layout:addChild(Coord.outgap(goldicon,goldtxt,"RL",5,"CC",0))
	self.m_goldtxt = goldtxt
	--玩家是否庄家图标
	local playerIndexIcon = display.newImage("ui_brnn_1041.png")
	layout:addChild(Coord.outgap(goldicon,playerIndexIcon,"CC",0,"TB",0))
	self.m_playerIndexIcon = playerIndexIcon
	--玩家名字
	layout:addChild(Coord.outgap(playerIndexIcon,display.newText(Player.name,24,Color.dantuhuangse),"RL",0,"CC",0))
	--玩家等级
	local leveltxt = display.newRichText(display.trans("##4001",Player.level))
	leveltxt:setAnchorPoint(cc.p(1,0.5))
	layout:addChild(Coord.ingap(layout,leveltxt,"LL",235,"BB",70))
	--银行按钮
	local bankbtn = display.newButton("ui_brnn_1027.png","ui_brnn_1027.png")
	bankbtn:setPressedActionEnabled(true)
	layout:addChild(Coord.ingap(layout,bankbtn,"RR",-170,"BB",35))
	bankbtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.ui.window.bank.BankWindows")
	end)
	--续投按钮
	local rebetBtn = require("src.ui.item.ExButton").new("ui_brnn_1039.png","ui_brnn_1039.png","ui_brnn_1040.png")
	rebetBtn:setPressedActionEnabled(true)
	rebetBtn:setDisable(true)
	layout:addChild(Coord.outgap(bankbtn,rebetBtn,"RL",40,"CC",0))
	rebetBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local datas = self.brnn_gameMgr:getBetRecord()
		ConnectMgr.connect("src.games.bairenniuniu.connect.Brnn_BathBetConnect" , datas,function(result)
			if result ~= 0 then return end
			for i = 1,#datas do
				self.brnn_gameMgr:addBetRecord(datas[i].type,datas[i].value,datas[i].pos)
			end
			self.m_betlayout:bathAddMineBet(datas)
		end)
		rebetBtn:setDisable(true)
	end)
	self.m_rebetBtn = rebetBtn
end
function Brnn_Scene:enabledBetButton(bool)
	self.m_buttonMgr:cleanCurrentButton()
	for i = 1,#self.m_betButtons do
		self.m_betButtons[i]:setShowStatus(bool)
	end
	
	if bool then
		if self.m_currentBetBtn then
			self.m_buttonMgr:setCurrentButton(self.m_currentBetBtn)
		end
	else
		self.m_btnflow:setVisible(false)
		self.brnn_gameMgr:setCurrentBet(nil,nil)
	end
end
--更新庄家信息
function Brnn_Scene:updateZhuangInfo(isaction)
	self.m_masterNameTxt:setString(self.brnn_gameMgr.master.name)
	self.m_masterGoldTxt:setString(self.brnn_gameMgr.master.gold,not isaction)
	if not self.brnn_gameMgr:checkApplyMaster() then
		self.m_zhuangBtn:loadTextureNormal("ui_brnn_1050.png",1)
		self.m_zhuangBtn:loadTexturePressed("ui_brnn_1051.png",1)
	else
		self.m_zhuangBtn:loadTextureNormal("ui_brnn_1048.png",1)
		self.m_zhuangBtn:loadTexturePressed("ui_brnn_1049.png",1)
	end
end
--@override
function Brnn_Scene:handlerEvent(event,arg)
	if event == ST.COMMAND_GAMEBRNN_BET then
		--下注接收
		self.m_betlayout:bathAddBet(arg)
	elseif event == ST.COMMAND_GAMEBRNN_APPLYNUM_UPDATE then
		--上庄申请人数变化
		self.m_applyTxt:setString(display.trans("##4002",self.brnn_gameMgr.applyNum))
		
	elseif event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		--金币更新
		if self.m_currentBetBtn and self.m_currentBetBtn.disable then
			self.m_buttonMgr:cleanCurrentButton()
			self.m_btnflow:setVisible(false)
			self.m_currentBetBtn = nil
			self.brnn_gameMgr:setCurrentBet(nil,nil)
		end
		if not self.m_rebetBtn.disable then
			self.m_rebetBtn:setDisable(not self.brnn_gameMgr:enbaleContinueBet())
		end
		self.m_goldtxt:setString(Player.gold)
		
	elseif event == ST.COMMAND_GAMEBRNN_INITROOM then
		--房间初始化完成
		self.m_betlayout:clear()
		self.m_betlayout:updateMasterGoldLimitTxt()
		self.m_pokerLayout:clear()
		self:updateZhuangInfo()
		self.m_applyTxt:setString(display.trans("##4002",self.brnn_gameMgr.applyNum))
		
		if self.brnn_gameMgr.initstatus == ST.TYPE_GAMEBRNN_WAIT then
			self.m_cdItem:setTargetTimeStamp(self.brnn_gameMgr.beganStamp)
		else
			self.m_cdItem:setTargetTimeStamp(self.brnn_gameMgr.openStamp,true)
		end
		
		self.m_betlayout:setWaitingTips(true)
	elseif event == ST.COOMAND_GAMEBRNN_BEGANBET then
		--开始下注
		if self.brnn_gameMgr:isMaster() then
			self:enabledBetButton(false)
		else
			self:enabledBetButton(true)
		end
		self.m_betlayout:setWaitingTips(false)
		self.m_betlayout:clear()
		self.m_pokerLayout:clear()
		self.m_goldtxt:setString(Player.gold,true)
		SoundsManager.playSound("brnn_bet_start")
		self:updateZhuangInfo()
		display.showMsg( display.newImage("ui_brnn_1002.png"))
		
		--设置续投按钮状态
		self.m_rebetBtn:setDisable(not self.brnn_gameMgr:enbaleContinueBet())
		self.m_betlayout:updateBetLimitInfo()
		self.m_cdItem:setTargetTimeStamp(self.brnn_gameMgr.openStamp,true)
		
	elseif event == ST.COMMAND_GAMEBRNN_MASTER_UPDATE then
		--庄家更新
		if self.brnn_gameMgr.previousMasterID == Player.id then
			display.showMsg(display.trans("##4014"))
			self.m_playerIndexIcon:loadTexture("ui_brnn_1042.png",1)
		else
			self.m_playerIndexIcon:loadTexture("ui_brnn_1041.png",1)
		end
		
		self:updateZhuangInfo()
		if self.brnn_gameMgr.continueCount > 1 then
			--连庄
			display.showMsg(display.newRichText(display.trans("##4008",self.brnn_gameMgr.continueCount)))
		elseif self.brnn_gameMgr:isMaster() then
			--播放上庄特效
			self.m_zhuangIcon:runAction(resource.getAnimateByKey("brnn_zhuozhuang",nil,true))
			display.showMsg(display.trans("##20003"))
		else
			--庄家轮换
			display.showMsg( display.trans("##4011"))
			SoundsManager.playSound("brnn_zhuang_change")
		end
	elseif event == ST.COMMAND_GAMEBRNN_RESULT then
		self:enabledBetButton(false)
		self.m_cdItem:stop()
		self.m_betlayout:setWaitingTips(false)
		self.m_rebetBtn:setDisable(true)
		SoundsManager.playSound("brnn_bet_end")
		display.showMsg( display.newImage("ui_brnn_1001.png"))
		if self.brnn_gameMgr.openStamp - ServerTimer.time >= 3 then
			display.showMsg(display.trans("##20007"))
		end
		
		--显示牌局结果
		self.m_pokerLayout:clear()
		self.m_pokerLayout:beganDeal()
	elseif event == ST.COMMAND_GAMEBRNN_POKER_OVER then
		--牌显示结束
		display.showWindow("src.games.bairenniuniu.ui.Brnn_ResultWindows")
	elseif event == ST.COMMAND_GAMEBRNN_RESULT_OVER then
		--显示结果结束
		self:updateZhuangInfo(true)
		self.m_applyTxt:setString(display.trans("##4002",self.brnn_gameMgr.applyNum))
		self:runAction(cc.Sequence:create({
			cc.DelayTime:create(3),
			cc.CallFunc:create(function(target) 
				if not target then return end
				self.m_cdItem:setTargetTimeStamp(self.brnn_gameMgr.beganStamp)
				self.m_betlayout:clear()
				self.m_pokerLayout:clear()
			end),
		}))
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	elseif event == ST.COMMAND_GAMEBRNN_DESKTOPPLAYERS_UPDATE then
		--桌面玩家更新
		local playerList = self.brnn_gameMgr.desktopPlayers
		for i = 1,#self.m_headlist do
			self.m_headlist[i]:setPlayer(playerList[i])
		end
	--jinrf add COMMAND_SOCKET_BREAK
	elseif event == ST.COMMAND_MAINSOCKET_BREAK or event == ST.COMMAND_SOCKET_BREAK  then
		--主socket断开连接
		print("百人牛牛主socket断开")
		self.noNeedClearRes = true
		local room = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().room
		display.enterScene("src.ui.ReloginScene",{room})
	end
end
--@override
function Brnn_Scene:onCleanup()
	self:removeAllEvent()
	self.m_buttonMgr:removeAllEventListeners()
	SoundsManager.stopAllMusic()
	require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance():destory(self.noNeedClearRes)
end

return Brnn_Scene