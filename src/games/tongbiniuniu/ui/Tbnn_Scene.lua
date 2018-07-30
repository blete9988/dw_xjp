--[[
*	通比牛牛 scene
*	@author：lqh
]]
local Tbnn_Scene = class("Tbnn_Scene",require("src.base.extend.CCSceneExtend"),IEventListener)
function Tbnn_Scene:ctor(room)
	self:super("ctor")
	self.tbnn_gameMgr = require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance()
	self.tbnn_gameMgr:setRoom(room)
	
	SoundsManager.playMusic("tbnn_bgm",true)
	
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(20)),20)
	
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self:addEvent(ST.COMMAND_GAMETBNN_ENTRYROOM)
	self:addEvent(ST.COOMAND_GAMETBNN_BEGAN)
	self:addEvent(ST.COOMAND_GAMETBNN_SEND_OVER)
	self:addEvent(ST.COMMAND_GAMETBNN_RESULT)
	self:addEvent(ST.COMMAND_GAMETBNN_RESULT_OVER)
	self:addEvent(ST.COMMAND_GAMETBNN_SHOWDOWN)
	self:addEvent(ST.COMMAND_GAMETBNN_SHOWDOWN_OVER)
	self:addEvent(ST.COMMAND_GAMETBNN_PLAYERCHANGE)
	self:addEvent(ST.COMMAND_GAMETBNN_READYSTATUS_UPDATE)
	self:addEvent(ST.COMMAND_GAMETBNN_AWARD_UPDATE)
	
	self:addChild(Coord.ingap(self,display.newImage("#game/tongbiniuniu/tbnn_desktop_background.jpg"),"CC",0,"CC",0))
	--桌面层
	self.m_desktopLayout = require("src.games.tongbiniuniu.ui.DesktopLayout").new()
	self:addChild(Coord.ingap(self,self.m_desktopLayout,"CC",0,"CC",0))
	
	--规则按钮
	local ruleBtn = display.newButton("tbnn_ui_1023.png","tbnn_ui_1023.png")
	ruleBtn:setPressedActionEnabled(true)
	ruleBtn:setScale(0.8)
	self:addChild(Coord.ingap(self,ruleBtn,"RR",-5,"CC",0))
	ruleBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.games.tongbiniuniu.ui.Tbnn_RuleWindows")
	end)
	
	
	self:m_initTopView()
	self:m_initBottomView()
	self:m_initOperateButton()
	
	require("src.ui.item.TalkControl").show(room,self)
	--退出按钮
	local quitebtn = require("src.ui.QuitButton").new("tbnn_ui_1007.png","tbnn_ui_1007.png","tbnn_ui_1008.png","tbnn_ui_1008.png")
	self:addChild(Coord.ingap(self,quitebtn,"LL",5,"TT",0))
	self.m_quitebtn = quitebtn
	
	self.tbnn_gameMgr:initgame()
end
--初始化操作按钮
function Tbnn_Scene:m_initOperateButton()
	--换桌按钮
	local changeBtn = display.newTextButton("tbnn_ui_1001.png","tbnn_ui_1002.png","",nil,display.trans("##5004"),36)
	self:addChild(Coord.ingap(self,changeBtn,"RR",-5,"TT",-80))
	self.m_changeBtn = changeBtn
	--自动按钮
	local autoBtn = display.newTextButton("tbnn_ui_1001.png","tbnn_ui_1002.png","",nil,display.trans("##5007"),36)
	self:addChild(Coord.ingap(self,autoBtn,"RR",-5,"BB",115))
	autoBtn.status = ST.TYPE_GAMETBNN_NOT_AUTO
	self.m_autoBtn = autoBtn
	--准备按钮
	local operateBtn = display.newTextButton("tbnn_ui_1001.png","tbnn_ui_1002.png","",nil,display.trans("##5005"),36)
	self:addChild(Coord.ingap(self,operateBtn,"CC",0,"BB",20))
	self.m_operateBtn = operateBtn
	--换桌按钮点击
	changeBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		ConnectMgr.connect("src.games.tongbiniuniu.connect.Tbnn_ChangeRoomConnect")
	end)
	--自动执行按钮点击
	autoBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local myinfo = self.tbnn_gameMgr:getMineInfo()
		if autoBtn.status == ST.TYPE_GAMETBNN_NOT_AUTO then
			autoBtn.status = ST.TYPE_GAMETBNN_AUTO
			--自动执行
			autoBtn:setTitleText(display.trans("##5008"))
			self:updateButtonStatus()
			self:onAutoExcute()
		else
			--取消自动执行
			autoBtn.status = ST.TYPE_GAMETBNN_NOT_AUTO
			autoBtn:setTitleText(display.trans("##5007"))
			self:updateButtonStatus()
		end
	end)
	--操作按钮点击
	operateBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local myinfo = self.tbnn_gameMgr:getMineInfo()
		if self.tbnn_gameMgr:isPlaying() then
			--已经开始
			if not myinfo:isShowdown() then
				--未摊牌，请求摊牌
				self:connectRequestShowdown()
			end
		else
			--未开始下注
			if myinfo:isReady() then
				--已准备,请求取消准备
				ConnectMgr.connect("src.games.tongbiniuniu.connect.Tbnn_ReadyStatusConnect",3,function(result)
					if result ~= 0 then return end
					changeBtn:setVisible(true)
					operateBtn:setTitleText(display.trans("##5005"))
				end)
			else
				--未准备,请求准备
				self:connectRequestReady()
			end
		end
	end)
end
--初始化顶部面板
function Tbnn_Scene:m_initTopView()
	local layout = display.newLayout(cc.size(D_SIZE.w,120))
	self:addChild(Coord.ingap(self,layout,"CC",0,"TT",0))
		
	--底注显示
	local baseBetBg = display.newImage("tbnn_panel_1002.png")
	display.setS9(baseBetBg,cc.rect(20,15,120,10),cc.size(250,42))
	layout:addChild(Coord.ingap(layout,baseBetBg,"CC",0,"TT",-60))
	baseBetBg:addChild(Coord.ingap(baseBetBg,display.newText(display.trans("##5001",self.tbnn_gameMgr.room.minBets),26,Color.GREY),"CC",0,"CC",0))
	
	--金币背景
	local goldbg = display.newImage("tbnn_panel_1004.png")
	display.setS9(goldbg,cc.rect(20,10,150,10),cc.size(280,50))
	layout:addChild(Coord.ingap(layout,goldbg,"RR",-20,"TT",-20))
	local goldIcon = display.newImage("tbnn_ui_1024.png")
	goldIcon:setScale(1.3)
	goldbg:addChild(Coord.ingap(goldbg,goldIcon,"LC",0,"CC",0,true))
	--玩家金币文本
	local goldTxt = cc.Label:createWithCharMap("game/tongbiniuniu/tbnn_number_1.png",24,34,string.byte("0"))
	goldTxt = require("src.base.control.ScrollNumberComponent").extend(goldTxt)
	goldTxt:setNmbFormatFunction(function(value) return value end)
	goldTxt:setAnchorPoint( cc.p(0,0.5) )
	goldTxt:setString(Player.gold,true)
	goldbg:addChild(Coord.ingap(goldbg,goldTxt,"LL",30,"CC",0))
	self.m_goldTxt = goldTxt
end
--初始化底部面板
function Tbnn_Scene:m_initBottomView()
	local layout = display.newLayout(cc.size(D_SIZE.w,160))
	self:addChild(Coord.ingap(self,layout,"CC",0,"BB",0))
	
	--彩金
	local awardbg = display.newImage("tbnn_ui_1017.png")
	layout:addChild(Coord.ingap(layout,awardbg,"LL",60,"BB",30))
	self.m_awardbg = awardbg
	local awardTxt = require("src.base.control.ScrollNumberComponent").new(0,26)
	awardTxt:setAnchorPoint( cc.p(1,0.5) )
	awardbg:addChild(Coord.ingap(awardbg,awardTxt,"RR",-75,"CC",-27))
	self.m_awardText = awardTxt
	awardbg:setVisible(false)
	
	--历史成绩底板
	local historyBg = display.newImage("tbnn_ui_1022.png")
	layout:addChild(Coord.ingap(layout,historyBg,"RR",0,"BB",0))
	--标题
	local titleTxt = display.newText(display.trans("##5002"),26)
	titleTxt:setAnchorPoint(cc.p(1,0.5))
	historyBg:addChild(Coord.ingap(historyBg,titleTxt,"CR",-30,"TT",-13))
	titleTxt = display.newText(display.trans("##5003"),26)
	titleTxt:setAnchorPoint(cc.p(1,0.5))
	historyBg:addChild(Coord.ingap(historyBg,titleTxt,"CR",-30,"BB",10))
	--历史战绩金币文本
	local historyTxt = require("src.base.control.ScrollNumberComponent").new("0",26)
	historyTxt:setAnchorPoint(cc.p(0,0.5))
	historyBg:addChild(Coord.ingap(historyBg,historyTxt,"CL",-25,"TT",-13))
	--上一局金币文本
	local previousTxt = require("src.base.control.ScrollNumberComponent").new("0",26)
	previousTxt:setAnchorPoint(cc.p(0,0.5))
	historyBg:addChild(Coord.ingap(historyBg,previousTxt,"CL",-25,"BB",10))
	self.m_historyTxt = historyTxt
	self.m_previousTxt = previousTxt
end
--显示彩金获得特效
function Tbnn_Scene:showAwardEffect()
	if not self.tbnn_gameMgr:hadAward() then return end
	local layout = display.newLayout()
	self:addChild(Coord.ingap(self,layout,"LL",60,"BB",30))
	
	local effectBg = display.newImage("tbnn_ui_1016.png")
	effectBg:setLocalZOrder(1)
	layout:addChild(Coord.difgap(self.m_awardbg,effectBg,layout,"CC",0,"CC",-20))
	local txt = display.newText(self.tbnn_gameMgr.selfAward,32)
	effectBg:addChild(Coord.ingap(effectBg,txt,"RR",-35,"CC",-10))
	
	local effectSprite = display.newSprite("tbnn_ui_1015.png")
	effectSprite:setScale(1.2)
	effectSprite:setLocalZOrder(0)
	layout:addChild(Coord.outgap(effectBg,effectSprite,"CC",50,"CC",0))
	effectSprite:runAction(cc.Sequence:create({
		cc.RotateTo:create(2,220),
		cc.CallFunc:create(function(t) 
			if not t then return end
			layout:removeFromParent(true)
		end),
	}))
end
--更新按钮状态
function Tbnn_Scene:updateButtonStatus()
	self.m_autoBtn:setVisible(true)
	if self.m_autoBtn.status == ST.TYPE_GAMETBNN_AUTO then
		--正在自动执行中，隐藏操作按钮和换桌按钮状态
		self.m_changeBtn:setVisible(false)
		self.m_operateBtn:setVisible(false)
		return
	end
	
	local myinfo = self.tbnn_gameMgr:getMineInfo()
	if self.tbnn_gameMgr:isPlaying() then
		--已经开始,隐藏换桌按钮
		self.m_changeBtn:setVisible(false)
		if myinfo:isShowdown() then
			--已摊牌
			self.m_operateBtn:setVisible(false)
		else
			--未摊牌
			self.m_operateBtn:setTitleText(display.trans("##5009"))
			self.m_operateBtn:setVisible(true)
		end
	else
		self.m_operateBtn:setVisible(true)
		--未开始下注
		if myinfo:isReady() then
			--已准备,隐藏换桌按钮
			self.m_changeBtn:setVisible(false)
			self.m_operateBtn:setTitleText(display.trans("##5006"))
		else
			--未准备,显示换桌按钮
			self.m_changeBtn:setVisible(true)
			self.m_operateBtn:setTitleText(display.trans("##5005"))
		end
	end
end
--请求准备
function Tbnn_Scene:connectRequestReady()
	if self.tbnn_gameMgr:getMineInfo():isReady() then return end
	ConnectMgr.connect("src.games.tongbiniuniu.connect.Tbnn_ReadyStatusConnect",2,function(result)
		if result ~= 0 then return end
		self.m_changeBtn:setVisible(false)
		self.m_operateBtn:setTitleText(display.trans("##5006"))
		--self.m_desktopLayout:updatePlayersReadyStatus()
	end)
end
--请求摊牌
function Tbnn_Scene:connectRequestShowdown()	
	if self.tbnn_gameMgr:getMineInfo():isShowdown() then return end
	ConnectMgr.connect("src.games.tongbiniuniu.connect.Tbnn_ShowdownConnect",function(result)
		if result ~= 0 then return end
		self.m_operateBtn:setVisible(false)
		--self.m_desktopLayout:showdown(self.tbnn_gameMgr:getMineInfo())
	end)
end
--自动执行
function Tbnn_Scene:onAutoExcute()
	if self.m_autoBtn.status ~= ST.TYPE_GAMETBNN_AUTO then return end
	
	if self.tbnn_gameMgr:isPlaying() then
		if not self.tbnn_gameMgr:getMineInfo():isShowdown() then
			--请求摊牌
			SoundsManager.playSound("main_sound_click")
			self:connectRequestShowdown()
		end
	elseif not self.tbnn_gameMgr:getMineInfo():isReady() then
		--请求准备
		SoundsManager.playSound("main_sound_click")
		self:connectRequestReady()
	end
end
--@override
function Tbnn_Scene:handlerEvent(event,arg)	
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		--金币更新
		self.m_goldTxt:setString(Player.gold)
	elseif event == ST.COMMAND_GAMETBNN_ENTRYROOM then
		--进入房间
		self.m_desktopLayout:initPlayers()
		
		self.m_quitebtn:disabledExitButton(self.tbnn_gameMgr:isPlaying())
		
		if self.tbnn_gameMgr.awardPool < 0 then
			self.m_awardbg:setVisible(false)
		else
			self.m_awardText:setString(self.tbnn_gameMgr.awardPool,true)
			self.m_awardbg:setVisible(true)
		end
		
		--重置自动按钮的状态
		self.m_autoBtn:setTitleText(display.trans("##5007"))
		self.m_autoBtn.status = ST.TYPE_GAMETBNN_NOT_AUTO
		self:updateButtonStatus()
		
		self.m_goldTxt:setString(Player.gold,true)
		self.m_historyTxt:setString(0,true)
		self.m_previousTxt:setString(0,true)
	elseif event == ST.COOMAND_GAMETBNN_BEGAN then
		--开始发牌
		SoundsManager.playSound("tbnn_start")
		--移除准备状态改变监听
		self:removeEvent(ST.COMMAND_GAMETBNN_READYSTATUS_UPDATE)
		self.m_quitebtn:disabledExitButton(true)
		self.m_changeBtn:setVisible(false)
		self.m_operateBtn:setVisible(false)
		self.m_autoBtn:setVisible(false)
		--执行发牌
		self.m_desktopLayout:beganDeal()
	elseif event == ST.COOMAND_GAMETBNN_SEND_OVER then
		--发牌结束
		self:updateButtonStatus()
		self:onAutoExcute()
	elseif event == ST.COMMAND_GAMETBNN_SHOWDOWN then
		--摊牌
		SoundsManager.playSound("tbnn_showdown")
		self.m_desktopLayout:showdownPoker(arg)
		if arg.id == Player.id then
			self.m_operateBtn:setVisible(false)
		end
	elseif event == ST.COMMAND_GAMETBNN_RESULT then
		--收到比牌结果
		SoundsManager.playSound("tbnn_kaipai")
		self.m_quitebtn:disabledExitButton(false)
		self:showAwardEffect()
		self.m_desktopLayout:showWinnerEffect()
	elseif event == ST.COMMAND_GAMETBNN_SHOWDOWN_OVER then
		--显示结果结束
		display.showWindow("src.games.tongbiniuniu.ui.Tbnn_ResultWindows")
	elseif event == ST.COMMAND_GAMETBNN_RESULT_OVER then
		--结果显示结束
		self.m_historyTxt:setString(self.tbnn_gameMgr.allRecord)
		self.m_previousTxt:setString(self.tbnn_gameMgr.curentRecord,true)
		self.m_desktopLayout:delayClear(function() 
			self:updateButtonStatus()
			self:onAutoExcute()
			self:addEvent(ST.COMMAND_GAMETBNN_READYSTATUS_UPDATE)
		end)
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	elseif event == ST.COMMAND_GAMETBNN_READYSTATUS_UPDATE then
		--玩家准备状态发生改变
		self.m_desktopLayout:updatePlayersReadyStatus()
	elseif event == ST.COMMAND_GAMETBNN_AWARD_UPDATE then
		--彩金变化
		self.m_awardText:setString(self.tbnn_gameMgr.awardPool)
	elseif event == ST.COMMAND_GAMETBNN_PLAYERCHANGE then
		--玩家变动
		if arg.type then
			--加入房间
			self.m_desktopLayout:addPlayer(arg.playerInfo)
		else
			--离开房间
			self.m_desktopLayout:removePlayer(arg.playerInfo)
		end
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		local room = require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance().room
		display.enterScene("src.ui.ReloginScene",{room})
	end
end
--@override
function Tbnn_Scene:onCleanup()
	self:removeAllEvent()
	SoundsManager.stopAllMusic()
	require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance():destory(self.noNeedClearRes)
end

return Tbnn_Scene