--[[
*	百家乐 scene
*	@author：lqh
]]
local Bjl_Scene = class("Bjl_Scene",require("src.base.extend.CCSceneExtend"),IEventListener)
function Bjl_Scene:ctor(room)
	self.bjl_gameMgr = require("src.games.baijiale.data.Bjl_GameMgr").getInstance()
	self.bjl_gameMgr:setRoom(room)
	
	self:super("ctor")
	
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(105)),20)
		
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self:addEvent(ST.COMMAND_GAMEBJL_INITROOM)
	self:addEvent(ST.COOMAND_GAMEBJL_BEGANBET)
	self:addEvent(ST.COMMAND_GAMEBJL_RESULT)
	self:addEvent(ST.COMMAND_GAMEBJL_BET)
	self:addEvent(ST.COMMAND_GAMEBJL_POKER_OVER)
	self:addEvent(ST.COMMAND_GAMEBJL_RESULT_OVER)
	self:addEvent(ST.COMMAND_GAMEBJL_DESKTOP_OVER)
	
	self:addChild(Coord.ingap(self,display.newImage("#game/baijiale/bjl_desktop_background.jpg"),"CC",0,"CC",0))
	
	--牌盒子
	local temp = display.newImage("bjl_ui_1009.png")
	self:addChild(Coord.ingap(self,temp,"RR",-185,"TT",-90))
	temp:addChild(Coord.ingap(temp,display.newImage("bjl_ui_1010.png"),"CC",-37,"CC",-5))
	
	--桌面层
	self.m_betlayout = require("src.games.baijiale.ui.BetLayout").new()
	self:addChild(self.m_betlayout)
	
	self:m_initRightLayout()
	self:m_initBottomView()
	--比牌桌面
	local pokerLayout = require("src.games.baijiale.ui.PokerLayout").new()
	self:addChild(pokerLayout)
	self.m_pokerLayout = pokerLayout
	
	require("src.ui.item.TalkControl").show(room,self)
	self:m_initTopView()
	
	self.bjl_gameMgr:initgame()


	SoundsManager.playMusic("bjl_bg",true)

end
--初始化顶部面板
function Bjl_Scene:m_initTopView()
	local layout = display.newLayout(cc.size(D_SIZE.w,110))
	self:addChild(Coord.ingap(self,layout,"CC",0,"TT",0))
	--退出按钮
	local quitebtn = require("src.ui.QuitButton").new("bjl_ui_1069.png","bjl_ui_1070.png","bjl_ui_1071.png","bjl_ui_1072.png")
	quitebtn:setLocalZOrder(2)
	layout:addChild(Coord.ingap(layout,quitebtn,"LL",0,"TT",0))
	--顶部背景
	layout:addChild(Coord.ingap(layout,display.newImage("bjl_ui_1018.png"),"CC",0,"TT",0))
	
	--第几局
	local inningsTxt = display.newText(display.trans("##3001",0),46,Color.danrubaise)
	inningsTxt:setAnchorPoint( cc.p(0,0.5) )
	layout:addChild(Coord.ingap(layout,inningsTxt,"LC",200,"CC",10))
	self.m_inningsTxt = inningsTxt
	
	--倒计时item
	local cdItem = require("src.games.baijiale.ui.ClockCountDownItem").new()
	layout:addChild(Coord.ingap(layout,cdItem,"CC",-300,"CC",8))
	self.m_cdItem = cdItem
	
	local plyerIcon = require("src.ui.item.HeadIcon").new(Player.headpath)
	plyerIcon:setScale(0.6)
	layout:addChild(Coord.ingap(layout,plyerIcon,"CC",175,"CC",12,true))
	
	--玩家名字
	layout:addChild(Coord.outgap(plyerIcon,display.newText(Player.name,26,Color.danrubaise),"CL",55,"CB",8,true))
	--玩家等级
	layout:addChild(Coord.ingap(layout,display.newRichText(display.trans("##3003",Player.level)),"RR",-200,"TT",-13))
	
	--金币显示
	local goldbg = display.newImage("bjl_ui_1024.png")
	display.setS9(goldbg,cc.rect(20,10,80,20),cc.size(255,36))
	layout:addChild(Coord.outgap(plyerIcon,goldbg,"CL",55,"CT",0,true))
	goldbg:addChild(Coord.ingap(goldbg,display.newImage("bjl_ui_1005.png"),"LL",-5,"CC",0))
	local goldtxt = require("src.base.control.ScrollNumberComponent").new(Player.gold,26,Color.dantuhuangse)
	goldtxt:setAnchorPoint( cc.p(0,0.5) )
	goldbg:addChild(Coord.ingap(goldbg,goldtxt,"LL",40,"CC",0))
	self.m_goldtxt = goldtxt
end
--初始化底部面板
function Bjl_Scene:m_initBottomView()
	local layout = display.newLayout(cc.size(D_SIZE.w,121))
	layout:setBackGroundImage("bjl_ui_1019.png",1)
	self:addChild(Coord.ingap(self,layout,"CC",0,"BB",-5))
	
	--筹码选中状态外发光
	local btnflow = display.newImage("bjl_ui_1021.png")
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
		self.bjl_gameMgr:setCurrentBet(t.betvalue,t:getParent():convertToWorldSpace(cc.p(t:getPosition())))
		
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
		btn = require("src.games.baijiale.ui.BetButton").new(config[i])
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
	layout:addChild(Coord.ingap(layout,display.setS9(display.newImage("bjl_ui_1020.png"),cc.rect(120,20,5,5),cc.size(760,52)),"CC",-8,"BB",2))
	
	--银行按钮
	local bankbtn = display.newButton("bjl_ui_1023.png","bjl_ui_1023.png")
	bankbtn:setPressedActionEnabled(true)
	layout:addChild(Coord.ingap(layout,bankbtn,"LL",120,"BB",30))
	bankbtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.ui.window.bank.BankWindows")
	end)
	
	--续投按钮
	local rebetBtn = require("src.ui.item.ExButton").new("bjl_ui_1006.png","bjl_ui_1006.png","bjl_ui_1007.png")
	rebetBtn:setPressedActionEnabled(true)
	rebetBtn:setDisable(true)
	layout:addChild(Coord.ingap(layout,rebetBtn,"RR",-170,"BB",30))
	rebetBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local datas = self.bjl_gameMgr:getBetRecord()
		ConnectMgr.connect("src.games.baijiale.connect.Bjl_BathBetConnect" , datas,function(result)
			if result ~= 0 then return end
			for i = 1,#datas do
				self.bjl_gameMgr:addBetRecord(datas[i].type,datas[i].value,datas[i].pos)
			end
			self.m_betlayout:bathAddMineBet(datas)
		end)
		rebetBtn:setDisable(true)
	end)
	self.m_rebetBtn = rebetBtn
end
--初始化右边面板
function Bjl_Scene:m_initRightLayout()
	local layout = display.newLayout(cc.size(175,D_SIZE.h))
	self:addChild(Coord.ingap(self,layout,"RR",0,"CC",0))
	
	
	local trendLayout = require("src.games.baijiale.ui.TrendLayout").new()
	layout:addChild(Coord.ingap(layout,trendLayout,"CC",0,"TT",-125))
	--圆角蒙版
	layout:addChild(Coord.outgap(trendLayout,display.setS9(display.newImage("bjl_ui_1053.png"),cc.rect(40,10,80,5),cc.size(174,29)),"CC",1,"TC",-7))
	self.m_trendLayout = trendLayout
	
	--规则按钮
	local ruleBtn = display.newButton("bjl_ui_1001.png","bjl_ui_1001.png")
	ruleBtn:setPressedActionEnabled(true)
	layout:addChild(Coord.ingap(layout,ruleBtn,"CC",0,"TT",-30))
	ruleBtn:addChild(Coord.ingap(ruleBtn,display.newImage("bjl_ui_1013.png"),"CC",0,"CC",0))
	ruleBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.games.baijiale.ui.Bjl_RuleWindows")
	end)
	--走势按钮
	local trendBtn = display.newButton("bjl_ui_1001.png","bjl_ui_1001.png")
	trendBtn:setPressedActionEnabled(true)
	layout:addChild(Coord.ingap(layout,trendBtn,"CC",0,"BB",25))
	trendBtn:addChild(Coord.ingap(trendBtn,display.newImage("bjl_ui_1014.png"),"CC",0,"CC",0))
	trendBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.games.baijiale.ui.Bjl_TrendWindows")
	end)
end
function Bjl_Scene:enabledBetButton(bool)
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
		self.bjl_gameMgr:setCurrentBet(nil,nil)
	end
end

--@override
function Bjl_Scene:handlerEvent(event,arg)
	if event == ST.COMMAND_GAMEBJL_BET then
		--下注接收
		self.m_betlayout:bathAddBet(arg)
	elseif event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		--金币更新
		if self.m_currentBetBtn and self.m_currentBetBtn.disable then
			self.m_buttonMgr:cleanCurrentButton()
			self.m_btnflow:setVisible(false)
			self.m_currentBetBtn = nil
			self.bjl_gameMgr:setCurrentBet(nil,nil)
		end
		if not self.m_rebetBtn.disable then
			self.m_rebetBtn:setDisable(not self.bjl_gameMgr:enbaleContinueBet())
		end
		self.m_goldtxt:setString(Player.gold)
		
	elseif event == ST.COMMAND_GAMEBJL_INITROOM then
		--房间初始化完成
		self.m_betlayout:clear()
		self.m_inningsTxt:setString(display.trans("##3001",self.bjl_gameMgr.resultMgr:geInnings()))
		self.m_trendLayout:initData()
		if self.bjl_gameMgr.initstatus == ST.TYPE_GAMEBJL_WAIT then
			self.m_cdItem:setTargetTimeStamp(self.bjl_gameMgr.beganStamp)
		else
			self.m_cdItem:setTargetTimeStamp(self.bjl_gameMgr.openStamp,true)
		end
		self.m_betlayout:setWaitingTips(true)
	elseif event == ST.COOMAND_GAMEBJL_BEGANBET then
		--开始下注
		display.showMsg( display.newImage("bjl_ui_1067.png"))
		SoundsManager.playSound("bjl_bet_start")
		self:delayTimer(function() 
			SoundsManager.playSound("bjl_start")
		end,1)
		self.m_betlayout:clear()
		self:enabledBetButton(true)
		self.m_betlayout:setWaitingTips(false)
		--设置续投按钮状态
		self.m_rebetBtn:setDisable(not self.bjl_gameMgr:enbaleContinueBet())
		
		self.m_inningsTxt:setString(display.trans("##3001",self.bjl_gameMgr.resultMgr:geInnings()))
		self.m_cdItem:setTargetTimeStamp(self.bjl_gameMgr.openStamp,true)
		if self.bjl_gameMgr.isnormal then
			--清理走势图
			self.m_trendLayout:initData()
			display.showMsg(display.trans("##2069"))
		end
	elseif event == ST.COMMAND_GAMEBJL_RESULT then
		self:enabledBetButton(false)
		self.m_cdItem:setTargetTimeStamp(self.bjl_gameMgr.beganStamp)	
		self.m_rebetBtn:setDisable(true)
		self.m_betlayout:setWaitingTips(false)
		SoundsManager.playSound("bjl_bet_end")
		display.showMsg( display.newImage("bjl_ui_1073.png"))
		--显示牌局结果
		self.m_pokerLayout:show()
	elseif event == ST.COMMAND_GAMEBJL_POKER_OVER then
		--牌显示结束
		self.m_trendLayout:updata()
		display.showWindow("src.games.baijiale.ui.Bjl_ResultWindows")
	elseif event == ST.COMMAND_GAMEBJL_RESULT_OVER then
		--结果显示结束
		self.m_betlayout:showResult()
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	elseif event == ST.COMMAND_GAMEBJL_DESKTOP_OVER then
		--桌面显示结果结束
		self.m_betlayout:clear()
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		local room = require("src.games.baijiale.data.Bjl_GameMgr").getInstance().room
		display.enterScene("src.ui.ReloginScene",{room})
	end
end
--@override
function Bjl_Scene:onCleanup()
	self:removeAllEvent()
	self.m_buttonMgr:removeAllEventListeners()
	SoundsManager.stopAllMusic()
	require("src.games.baijiale.data.Bjl_GameMgr").getInstance():destory(self.noNeedClearRes)
end

return Bjl_Scene