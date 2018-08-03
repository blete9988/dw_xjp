--[[
*	三公 scene
*	@author：lqh
]]
local Sangong_Scene = class("Sangong_Scene",require("src.base.extend.CCSceneExtend"),IEventListener)
function Sangong_Scene:ctor(room)
	self:super("ctor")
	self.sangong_gameMgr = require("src.games.sangong.data.Sangong_GameMgr").getInstance()
	self.sangong_gameMgr:setRoom(room)
	self.sangong_gameMgr:setSangongSelf(self)

	SoundsManager.playMusic("qznn_bgm",true)
	
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(20)),20)
	
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self:addEvent(ST.COMMAND_GAMESANGONG_ENTRYROOM)
	self:addEvent(ST.COOMAND_GAMESANGONG_BEGAN)
	self:addEvent(ST.COOMAND_GAMESANGONG_SEND_OVER)
	self:addEvent(ST.COMMAND_GAMESANGONG_RESULT)
	self:addEvent(ST.COMMAND_GAMESANGONG_RESULT_OVER)
	self:addEvent(ST.COMMAND_GAMESANGONG_SHOWDOWN)
	self:addEvent(ST.COMMAND_GAMESANGONG_PLAYERCHANGE)
	self:addEvent(ST.COMMAND_GAMESANGONG_READYSTATUS_UPDATE)
	self:addEvent(ST.COMMAND_GAMESANGONG_BEGAN_GET_MASTER)
	self:addEvent(ST.COMMAND_GAMESANGONG_MASTER_VALUE)
	self:addEvent(ST.COMMAND_GAMESANGONG_BEGAN_ADD_TIMES)
	self:addEvent(ST.COMMAND_GAMESANGONG_TIMES_VALUE)
	
	self:addChild(Coord.ingap(self,display.newImage("#game/sangong/sangong_desktop_background.jpg"),"CC",0,"CC",0))
	--桌面层
	self.m_desktopLayout = require("src.games.sangong.ui.DesktopLayout").new()
	self:addChild(Coord.ingap(self,self.m_desktopLayout,"CC",0,"CC",0))
	
	--规则按钮
	local ruleBtn = display.newButton("qznn_ui_1023.png","qznn_ui_1023.png")
	ruleBtn:setPressedActionEnabled(true)
	ruleBtn:setScale(0.8)
	self:addChild(Coord.ingap(self,ruleBtn,"RR",-5,"CC",0))
	ruleBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.games.sangong.ui.Sangong_RuleWindows")
	end)
	
	self:m_initTopView()
	self:m_initBottomView()
	self:m_initOperateButton()
	
	
	require("src.ui.item.TalkControl").show(room,self)
	--退出按钮
	local quitebtn = require("src.ui.QuitButton").new("qznn_ui_1007.png","qznn_ui_1007.png","qznn_ui_1008.png","qznn_ui_1008.png")
	self:addChild(Coord.ingap(self,quitebtn,"LL",5,"TT",0))
	self.m_quitebtn = quitebtn
	
	self.sangong_gameMgr:initgame()
end
--初始化操作按钮
function Sangong_Scene:m_initOperateButton()
	--换桌按钮
	local changeBtn = display.newTextButton("qznn_ui_1001.png","qznn_ui_1002.png","",nil,display.trans("##7004"),36)
	self:addChild(Coord.ingap(self,changeBtn,"RR",-5,"TT",-80))
	self.m_changeBtn = changeBtn
	--自动按钮
	local autoBtn = display.newTextButton("qznn_ui_1001.png","qznn_ui_1002.png","",nil,display.trans("##7007"),36)
	self:addChild(Coord.ingap(self,autoBtn,"RR",-5,"BB",115))
	autoBtn.status = ST.TYPE_GAMESANGONG_NOT_AUTO
	self.m_autoBtn = autoBtn
	--准备按钮
	local operateBtn = display.newTextButton("qznn_ui_1001.png","qznn_ui_1002.png","",nil,display.trans("##7005"),36)
	self:addChild(Coord.ingap(self,operateBtn,"CC",0,"BB",20))
	self.m_operateBtn = operateBtn
	--换桌按钮点击
	changeBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		ConnectMgr.connect("src.games.sangong.connect.Sangong_ChangeRoomConnect")
	end)
	--自动执行按钮点击
	autoBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local myinfo = self.sangong_gameMgr:getMineInfo()
		if autoBtn.status == ST.TYPE_GAMESANGONG_NOT_AUTO then
			autoBtn.status = ST.TYPE_GAMESANGONG_AUTO
			--自动执行
			autoBtn:setTitleText(display.trans("##7008"))
			self:updateButtonStatus()
			self:onAutoExcute()
		else
			--取消自动执行
			autoBtn.status = ST.TYPE_GAMESANGONG_NOT_AUTO
			autoBtn:setTitleText(display.trans("##7007"))
			self:updateButtonStatus()
		end
	end)
	--操作按钮点击
	operateBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local myinfo = self.sangong_gameMgr:getMineInfo()
		if self.sangong_gameMgr:isPlaying() then
			--已经开始
			if not myinfo:isShowdown() then
				--未摊牌，请求摊牌
				self:connectRequestShowdown()
			end
		else
			--未开始下注
			if myinfo and myinfo:isReady() then
				--已准备,请求取消准备
				ConnectMgr.connect("src.games.sangong.connect.Sangong_ReadyStatusConnect",3,function(result)
					if result ~= 0 then return end
					changeBtn:setVisible(true)
					operateBtn:setTitleText(display.trans("##7005"))
				end)
			else
				--未准备,请求准备
				self:connectRequestReady()
			end
		end
	end)
	
	--银行按钮
	local bankbtn = display.newButton("qznn_ui_1029.png","qznn_ui_1030.png")
	self:addChild(Coord.ingap(self,bankbtn,"LL",5,"BB",20))
	bankbtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.ui.window.bank.BankWindows")
	end)
end
--初始化顶部面板
function Sangong_Scene:m_initTopView()
	local layout = display.newLayout(cc.size(D_SIZE.w,120))
	self:addChild(Coord.ingap(self,layout,"CC",0,"TT",0))
		
	--底注显示
	local baseBetBg = display.newImage("qznn_panel_1002.png")
	display.setS9(baseBetBg,cc.rect(20,15,120,10),cc.size(250,42))
	layout:addChild(Coord.ingap(layout,baseBetBg,"CC",0,"TT",-60))
	baseBetBg:addChild(Coord.ingap(baseBetBg,display.newText(display.trans("##7001",self.sangong_gameMgr.room.minBets),26,Color.GREY),"CC",0,"CC",0))
	
	--金币背景
	local goldbg = display.newImage("qznn_panel_1004.png")
	display.setS9(goldbg,cc.rect(20,10,150,10),cc.size(280,50))
	layout:addChild(Coord.ingap(layout,goldbg,"RR",-20,"TT",-20))
	local goldIcon = display.newImage("qznn_ui_1024.png")
	goldIcon:setScale(1.3)
	goldbg:addChild(Coord.ingap(goldbg,goldIcon,"LC",0,"CC",0,true))
	--玩家金币文本
	local goldTxt = cc.Label:createWithCharMap("game/sangong/sangong_number_1.png",24,34,string.byte("0"))
	goldTxt = require("src.base.control.ScrollNumberComponent").extend(goldTxt)
	goldTxt:setNmbFormatFunction(function(value) return value end)
	goldTxt:setAnchorPoint( cc.p(0,0.5) )
	goldTxt:setString(Player.gold,true)
	goldbg:addChild(Coord.ingap(goldbg,goldTxt,"LL",30,"CC",0))
	self.m_goldTxt = goldTxt
end
--初始化底部面板
function Sangong_Scene:m_initBottomView()
	local layout = display.newLayout(cc.size(D_SIZE.w,160))
	self:addChild(Coord.ingap(self,layout,"CC",0,"BB",0))
	
	--历史成绩底板
	local historyBg = display.newImage("qznn_ui_1022.png")
	layout:addChild(Coord.ingap(layout,historyBg,"RR",0,"BB",0))
	--标题
	local titleTxt = display.newText(display.trans("##7002"),26)
	titleTxt:setAnchorPoint(cc.p(1,0.5))
	historyBg:addChild(Coord.ingap(historyBg,titleTxt,"CR",-30,"TT",-13))
	titleTxt = display.newText(display.trans("##7003"),26)
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

--更新按钮状态
function Sangong_Scene:updateButtonStatus()
	self.m_autoBtn:setVisible(true)
	if self.m_autoBtn.status == ST.TYPE_GAMESANGONG_AUTO then
		--正在自动执行中，隐藏操作按钮和换桌按钮状态
		self.m_changeBtn:setVisible(false)
		self.m_operateBtn:setVisible(false)
		return
	end
	
	local myinfo = self.sangong_gameMgr:getMineInfo()
	if self.sangong_gameMgr.gamestatus == ST.TYPE_GAMESANGONG_PLAYING then
		--已经开始,隐藏换桌按钮
		self.m_changeBtn:setVisible(false)
		if self.sangong_gameMgr.playStatus == ST.TYPE_GAMESANGONG_PLAYSTATUS_PLAYING then
			if myinfo:isShowdown() then
				--已摊牌
				self.m_operateBtn:setVisible(false)
			else
				--未摊牌
				self.m_operateBtn:setTitleText(display.trans("##7009"))
				self.m_operateBtn:setVisible(true)
			end
		else
			self.m_operateBtn:setVisible(false)
		end
	else
		self.m_operateBtn:setVisible(true)
		--未开始下注
		if myinfo:isReady() then
			--已准备,隐藏换桌按钮
			self.m_changeBtn:setVisible(false)
			self.m_operateBtn:setTitleText(display.trans("##7006"))
		else
			--未准备,显示换桌按钮
			self.m_changeBtn:setVisible(true)
			self.m_operateBtn:setTitleText(display.trans("##7005"))
		end
	end
end
--请求准备
function Sangong_Scene:connectRequestReady()
	if self.sangong_gameMgr:getMineInfo():isReady() then return end
	ConnectMgr.connect("src.games.sangong.connect.Sangong_ReadyStatusConnect",2,function(result)
		if result ~= 0 then return end
		self.m_changeBtn:setVisible(false)
		self.m_operateBtn:setTitleText(display.trans("##7006"))
		--self.m_desktopLayout:updatePlayersReadyStatus()
	end)
end
--请求摊牌
function Sangong_Scene:connectRequestShowdown()	
	if self.sangong_gameMgr:getMineInfo():isShowdown() then return end
	ConnectMgr.connect("src.games.sangong.connect.Sangong_ShowdownConnect",function(result)
		if result ~= 0 then return end
		self.m_operateBtn:setVisible(false)
		--self.m_desktopLayout:showdown(self.sangong_gameMgr:getMineInfo())
	end)
end
--自动执行
function Sangong_Scene:onAutoExcute()
	if self.m_autoBtn.status ~= ST.TYPE_GAMESANGONG_AUTO then return end
	
	if self.sangong_gameMgr:isPlaying() then
		if not self.sangong_gameMgr:getMineInfo():isShowdown() then
			--请求摊牌
			SoundsManager.playSound("main_sound_click")
			self:connectRequestShowdown()
		end
	elseif not self.sangong_gameMgr:getMineInfo():isReady() then
		--请求准备
		SoundsManager.playSound("main_sound_click")
		self:connectRequestReady()
	end
end
--@override
function Sangong_Scene:handlerEvent(event,arg)	
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		--金币更新
		self.m_goldTxt:setString(Player.gold)
	elseif event == ST.COMMAND_GAMESANGONG_ENTRYROOM then
		--进入房间
		self.m_desktopLayout:init()
		
		self.m_quitebtn:disabledExitButton(self.sangong_gameMgr.gamestatus == ST.TYPE_GAMESANGONG_PLAYING)
		
		--重置自动按钮的状态
		self.m_autoBtn:setTitleText(display.trans("##7007"))
		self.m_autoBtn.status = ST.TYPE_GAMESANGONG_NOT_AUTO
		self:updateButtonStatus()
		
		self.m_goldTxt:setString(Player.gold,true)
		self.m_historyTxt:setString(0,true)
		self.m_previousTxt:setString(0,true)
	elseif event == ST.COMMAND_GAMESANGONG_BEGAN_GET_MASTER then
		--开始抢庄
		
		--移除准备状态改变监听
		self:removeEvent(ST.COMMAND_GAMESANGONG_READYSTATUS_UPDATE)
		
		self.m_quitebtn:disabledExitButton(true)
		self.m_changeBtn:setVisible(false)
		self.m_operateBtn:setVisible(false)
		self.m_autoBtn:setVisible(false)
		self.m_desktopLayout:updatePlayersReadyStatus()
		self.m_desktopLayout:showTimesOperateBtn(true)
	elseif event == ST.COMMAND_GAMESANGONG_MASTER_VALUE or event == ST.COMMAND_GAMESANGONG_TIMES_VALUE then
		--抢庄倍数 和 加倍倍数 接收
		self.m_desktopLayout:updatePlayersTimesStatus()
	elseif event == ST.COMMAND_GAMESANGONG_BEGAN_ADD_TIMES then
		--开始加倍
		self.m_desktopLayout:showTimesOperateBtn()
		self.m_desktopLayout:updatePlayersTimesStatus(true)
	elseif event == ST.COOMAND_GAMESANGONG_BEGAN then
		--开始发牌
		SoundsManager.playSound("qznn_start")
		--执行发牌
		self.m_desktopLayout:beganDeal()
	elseif event == ST.COOMAND_GAMESANGONG_SEND_OVER then
		--发牌结束
		self:updateButtonStatus()
		self:onAutoExcute()
	elseif event == ST.COMMAND_GAMESANGONG_SHOWDOWN then
		--摊牌
		SoundsManager.playSound("qznn_showdown")
		self.m_desktopLayout:showdownPoker(arg)
		if arg.id == Player.id then
			self.m_operateBtn:setVisible(false)
		end
	elseif event == ST.COMMAND_GAMESANGONG_RESULT then
		--收到比牌结果
		SoundsManager.playSound("qznn_kaipai")
		self.m_quitebtn:disabledExitButton(false)
		self.m_desktopLayout:showResultEffect()
		
	elseif event == ST.COMMAND_GAMESANGONG_RESULT_OVER then
		--结果显示结束
		self.m_historyTxt:setString(self.sangong_gameMgr.allRecord)
		self.m_previousTxt:setString(self.sangong_gameMgr.curentRecord,true)
		self:updateButtonStatus()
		self:onAutoExcute()
		self:addEvent(ST.COMMAND_GAMESANGONG_READYSTATUS_UPDATE)
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	elseif event == ST.COMMAND_GAMESANGONG_READYSTATUS_UPDATE then
		--玩家准备状态发生改变
		self.m_desktopLayout:updatePlayersReadyStatus()
	elseif event == ST.COMMAND_GAMESANGONG_PLAYERCHANGE then
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
		local room = require("src.games.sangong.data.Sangong_GameMgr").getInstance().room
		display.enterScene("src.ui.ReloginScene",{room})
	end
end

function Sangong_Scene:Quit()
	ConnectMgr.connect("gamehall.QuitRoomConnect")
	display.enterScene("src.ui.scene.MainScene")
end

--@override
function Sangong_Scene:onCleanup()
	mlog("关闭面板。。。。。")
	self:removeAllEvent()
	-- self:removeFromParent(true)
	SoundsManager.stopAllMusic()
	require("src.games.sangong.data.Sangong_GameMgr").getInstance():destory(self.noNeedClearRes)
	self:Quit()
end

return Sangong_Scene