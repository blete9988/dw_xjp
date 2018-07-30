--[[
*	红黑大战 主window
*	@author：lqh
]]
local Hhdz_Scene = class("Hhdz_Scene",require("src.base.extend.CCSceneExtend"),IEventListener)
function Hhdz_Scene:ctor(room)
	self.hhdz_gameMgr = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance()
	self.hhdz_gameMgr:setRoom(room)
	self:super("ctor")
	SoundsManager.playMusic("hhdz_bgm",true)
	
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(120)),20)
	
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self:addEvent(ST.COMMAND_GAMEHHDZ_INITROOM)
	self:addEvent(ST.COOMAND_GAMEHHDZ_BEGAN)
	self:addEvent(ST.COOMAND_GAMEHHDZ_OVER)
	self:addEvent(ST.COOMAND_GAMEHHDZ_BET)
	self:addEvent(ST.COOMAND_GAMEHHDZ_BEGAN_ANIM_OVER)
	self:addEvent(ST.COOMAND_GAMEHHDZ_OPEN_POKER_OVER)
	
	local bg = display.newImage("#game/hongheidazhan/hhdz_desktop_background.jpg")
	bg:setScale(1.19718)
	self:addChild(Coord.ingap(self,bg,"CC",0,"CC",0,true))
	
	--下注层
	self.m_betlayout = require("src.games.hongheidazhan.ui.BetLayout").new()
	self:addChild(Coord.ingap(self,self.m_betlayout,"CC",0,"CC",0))
	
	--扑克层
	self.m_pokerLayout = require("src.games.hongheidazhan.ui.PokerLayout").new()
	self:addChild(Coord.ingap(self,self.m_pokerLayout,"CC",0,"TT",0))
	
	
	self:m_initBottomView()
	self:m_initTrend()
	self:init_operateButton()
	
	require("src.ui.item.TalkControl").show(room,self)
	--退出按钮
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",5,"TT",0))
	
	self.hhdz_gameMgr:initgame()
end
--初始化所有按钮
function Hhdz_Scene:init_operateButton()
	
	--规则按钮
	local ruleBtn = display.newButton("ui_hhdz_1003.png","ui_hhdz_1004.png")
	self:addChild(Coord.ingap(self,ruleBtn,"RR",-10,"TT",0))
	ruleBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.games.hongheidazhan.ui.Hhdz_RuleWindows")
	end)
	
	--银行按钮
	local bankbtn = display.newButton("ui_hhdz_1001.png","ui_hhdz_1002.png")
	self:addChild(Coord.ingap(self,bankbtn,"LL",5,"BB",120))
	bankbtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.ui.window.bank.BankWindows")
	end)
	--路子按钮
	local trendBtn = display.newButton("ui_hhdz_1005.png","ui_hhdz_1005.png")
	trendBtn:setScale(1.19718)
	self:addChild(Coord.difscgap(self,trendBtn,"CL",285,"TT",-125,true))
	trendBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.games.hongheidazhan.ui.Hhdz_TrendWindows")
	end)
	
	--续投按钮
	local rebetBtn = require("src.ui.item.ExButton").new("ui_hhdz_1007.png","ui_hhdz_1007.png","ui_hhdz_1008.png")
	rebetBtn:setPressedActionEnabled(true)
	rebetBtn:setDisable(true)
	self:addChild(Coord.ingap(self,rebetBtn,"RR",-10,"BB",10))
	rebetBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local datas = self.hhdz_gameMgr:getBetRecord()
		ConnectMgr.connect("src.games.hongheidazhan.connect.Hhdz_BathBetConnect" , datas,function(result)
			if result ~= 0 then return end
			for i = 1,#datas do
				self.hhdz_gameMgr:addBetRecord(datas[i].type,datas[i].value,datas[i].pos)
			end
			self.m_betlayout:bathAddMineBet(datas)
		end)
		rebetBtn:setDisable(true)
	end)
	self.m_rebetBtn = rebetBtn
end
--初始化底部面板
function Hhdz_Scene:m_initBottomView()
	local layout = display.newLayout(cc.size(D_SIZE.w,121))
	self:addChild(Coord.ingap(self,layout,"CC",0,"BB",-5))
	
	--筹码选中状态外发光
	local btnflow = display.newImage("ui_hhdz_1031.png")
	btnflow:setLocalZOrder(1)
	btnflow:setVisible(false)
	btnflow:setScale(1.19718)
	Coord.ingap(layout,btnflow,"CC",0,"CC",0)
	layout:addChild(btnflow)
	self.m_btnflow = btnflow
	local buttonMgr = require("src.base.control.RadioButtonControl").new()
	--单选按钮
	buttonMgr:addEventListener(buttonMgr.EVT_SELECT,function(e,t) 
		self.m_currentBetBtn = t
		--记录当前所选赌注的数据
		self.hhdz_gameMgr:setCurrentBet(t.betvalue,t:getParent():convertToWorldSpace(cc.p(t:getPosition())))
		
		btnflow:setVisible(true)
		Coord.outgap(t,btnflow,"CC",0,"CC",4,true)
	end)
	self.m_buttonMgr = buttonMgr
	--下注金额配置
	local config = {1000,10000,100000,1000000,5000000}
	self.m_betButtons = {}
	--下注按钮
	local btn,temp
	for i = 1,#config do
		btn = require("src.games.hongheidazhan.ui.BetButton").new(config[i])
		buttonMgr:addButton(btn)
		if not temp then
			layout:addChild(Coord.ingap(layout,btn,"CC",-280,"CC",5,true))
		else
			layout:addChild(Coord.outgap(temp,btn,"RL",5,"CC",0,true))
		end
		btn:setShowStatus(false)
		self.m_betButtons[i] = btn
		temp = btn
	end
	
	--金币显示
	
	local goldbg = display.newImage("ui_hhdz_1009.png")
	layout:addChild(Coord.ingap(layout,goldbg,"LL",10,"BB",15))
	local goldtxt = require("src.base.control.ScrollNumberComponent").new(Player.gold,30)
	goldtxt:setAnchorPoint( cc.p(0,0.5) )
	goldbg:addChild(Coord.ingap(goldbg,goldtxt,"LL",70,"CC",0))
	self.m_goldtxt = goldtxt
	--玩家名字
	local nameTxt = display.newText(Player.name,26)
	layout:addChild(Coord.outgap(goldbg,nameTxt,"LL",0,"TC",30))
	--玩家等级
	local leveltxt = display.newRichText(display.trans("##6001",Player.level))
	leveltxt:setAnchorPoint(cc.p(1,0.5))
	layout:addChild(Coord.outgap(nameTxt,leveltxt,"RL",30,"CC",0))
end
--初始化路子
function Hhdz_Scene:m_initTrend()
	local looplist_1 = require("src.base.control.LoopListView").new(nil,30)
	looplist_1:setAnchorPoint( cc.p(0.5,0.5) )
	looplist_1:setContentSize(cc.size(25,653))
	looplist_1:setTouchEnabled(false)
	looplist_1:setGap(5)
	looplist_1:setRotation(-90)
	self:addChild(Coord.ingap(self,looplist_1,"CC",-49,"TC",-138))
	
	looplist_1:addExtendListener(function(params)
		if params.event == looplist_1.EVT_UPDATE then
			if params.data.blackWin then
				params.target:loadTexture("ui_hhdz_1016.png",1)
			else
				params.target:loadTexture("ui_hhdz_1013.png",1)
			end
		elseif params.event == looplist_1.EVT_NEW then
			if params.data.blackWin then
				return display.newImage("ui_hhdz_1016.png")
			else
				return display.newImage("ui_hhdz_1013.png")
			end
		end
	end)
	self.m_looplist_1 = looplist_1
	
	local looplist_2 = require("src.base.control.LoopListView").new(nil,10)
	looplist_2:setAnchorPoint( cc.p(0.5,0.5) )
	looplist_2:setContentSize(cc.size(40,653))
	looplist_2:setTouchEnabled(false)
	looplist_2:setGap(8)
	looplist_2:setRotation(-90)
	self:addChild(Coord.outgap(looplist_1,looplist_2,"CC",-3,"CC",-35))
	
	looplist_2:addExtendListener(function(params)
		if params.event == looplist_2.EVT_UPDATE then
			params.target:loadTexture(string.format("poker_type_trend_rotate_%s.png",params.data.groupType),1)
		elseif params.event == looplist_2.EVT_NEW then
			return display.newImage(string.format("poker_type_trend_rotate_%s.png",params.data.groupType))
		end
	end)
	self.m_looplist_2 = looplist_2
end
--初始化设置路子
function Hhdz_Scene:m_initSetTrend()
	self.m_looplist_1:setDatas(self.hhdz_gameMgr.resultMgr:getResults())
	self.m_looplist_1:excute(true,true)
	self.m_looplist_2:setDatas(self.hhdz_gameMgr.resultMgr:getResults())
	self.m_looplist_2:excute(true,true)
end
function Hhdz_Scene:m_updateTrend()
	local curResult = self.hhdz_gameMgr.resultMgr:getCuurentResult()
	self.m_looplist_1:appendDatas({curResult},true)
	self.m_looplist_2:appendDatas({curResult},true)
	
	self.hhdz_gameMgr.resultMgr:pushCuurentResultToCache()
end
function Hhdz_Scene:enabledBetButton(bool)
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
		self.hhdz_gameMgr:setCurrentBet(nil,nil)
	end
end
--显示金币变化
function Hhdz_Scene:showGoldChange()
	local value = self.hhdz_gameMgr.resultMgr.winGold
	if value ~= 0 then
		local goldTxt
		if value > 0 then
			goldTxt = cc.Label:createWithCharMap(display.getTexture("game/hongheidazhan/hhdz_number_3.png"),24,34,string.byte("0"))
			goldTxt:setString(":" .. value)
			SoundsManager.playSound("hhdz_getGold")
		else
			goldTxt = cc.Label:createWithCharMap(display.getTexture("game/hongheidazhan/hhdz_number_4.png"),26,34,string.byte("0"))
			goldTxt:setString(";" .. math.abs(value))
		end
		goldTxt:setLocalZOrder(10)
		goldTxt:setAnchorPoint( cc.p(0.5,0.5) )
		goldTxt:setOpacity(0)
		self:addChild(Coord.ingap(self,goldTxt,"CC",0,"BB",130))
		goldTxt:runAction(cc.Sequence:create({
			cc.Spawn:create({
				cc.MoveTo:create(1.6,cc.p(D_SIZE.hw,300)),
				cc.ScaleTo:create(1.6,1.3),
				cc.Sequence:create({
					cc.FadeIn:create(0.3),
					cc.DelayTime:create(0.8),
					cc.FadeOut:create(0.5)
				})
			}),
			cc.CallFunc:create(function(t) 
				if not t then return end
				goldTxt:removeFromParent()
			end),
		}))
		
	end
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(3),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self.m_betlayout:clear()
		end),
	}))
end

--@override
function Hhdz_Scene:handlerEvent(event,arg)
	if event == ST.COOMAND_GAMEHHDZ_BET then
		--下注接收
		self.m_betlayout:bathAddBet(arg)
	elseif event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		--金币更新
		if self.m_currentBetBtn and self.m_currentBetBtn.disable then
			self.m_buttonMgr:cleanCurrentButton()
			self.m_btnflow:setVisible(false)
			self.m_currentBetBtn = nil
			self.hhdz_gameMgr:setCurrentBet(nil,nil)
		end
		if not self.m_rebetBtn.disable then
			self.m_rebetBtn:setDisable(not self.hhdz_gameMgr:enbaleContinueBet())
		end
		self.m_goldtxt:setString(Player.gold)
		
	elseif event == ST.COMMAND_GAMEHHDZ_INITROOM then
		--房间初始化完成
		if self.hhdz_gameMgr.initstatus == ST.TYPE_GAMEHHDZ_ON_BET then
			self.m_pokerLayout:initShowPoker()
		end
		self.m_betlayout:setWaitingTips(true)
		self:m_initSetTrend()
	elseif event == ST.COOMAND_GAMEHHDZ_BEGAN then
		--开始下注
		self:stopAllActions()
		self.m_betlayout:setWaitingTips(false)
		self.m_betlayout:clear()
		self.m_pokerLayout:clear()
		self.m_goldtxt:setString(Player.gold,true)
		--添加阻止下注蒙版
		self.m_betlayout:setMaskStatus(true)
		self:addChild(require("src.games.hongheidazhan.ui.Hhdz_ScreenAnimaLayout").new():playPKBoomAnim(function() 
			--播放发牌动画
			self.m_pokerLayout:beganDeal()
		end))
	elseif event == ST.COOMAND_GAMEHHDZ_BEGAN_ANIM_OVER then
		--开始下注全屏动画播放结束
		self:enabledBetButton(true)
		--设置续投按钮状态
		self.m_rebetBtn:setDisable(not self.hhdz_gameMgr:enbaleContinueBet())
		--开始倒计时
		self.m_betlayout:beganCountDown()
		--移除阻止下注蒙版
		self.m_betlayout:setMaskStatus(false)
	elseif event == ST.COOMAND_GAMEHHDZ_OVER then
		--结束下注
		self:enabledBetButton(false)
		self.m_rebetBtn:setDisable(true)
		self.m_betlayout:setWaitingTips(false)
		self.m_betlayout:stopCountDown()
		
		self:addChild(require("src.games.hongheidazhan.ui.Hhdz_ScreenAnimaLayout").new():playOverAnim(function() 
			--停止下注全屏动画播放结束
			self.m_pokerLayout:turnPoker()
		end))
	elseif event == ST.COOMAND_GAMEHHDZ_OPEN_POKER_OVER then
		self.m_betlayout:blinkWinArea()
		self:m_updateTrend()
		self:showGoldChange()
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		local room = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().room
		display.enterScene("src.ui.ReloginScene",{room})
	end
end
--@override
function Hhdz_Scene:onCleanup()
	self:removeAllEvent()
	self.m_buttonMgr:removeAllEventListeners()
	SoundsManager.stopAllMusic()
	require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance():destory(self.noNeedClearRes)
end

return Hhdz_Scene