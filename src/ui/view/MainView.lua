--[[
*	主界面 主view
*	@author：lqh
]]
local MainView = class("MainView",require("src.base.extend.CCLayerExtend"),IEventListener,function() 
	local layer = display.newLayout(cc.size(D_SIZE.w,D_SIZE.top(180)))
	layer:setTouchEnabled(true)
	return layer
end)
--操作按钮类
local CustomButton = class("CustomButton",require("src.base.extend.CCLayerExtend"),function() 
	local layout = display.newLayout(cc.size(60,85))
	layout:setTouchEnabled(true)
	layout.m_addTouchEventListener = layout.addTouchEventListener
	return layout
end)

function MainView:ctor()
	self:super("ctor")
	
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_PLAYER_HEAD_UPDATE)
	self:addEvent(ST.COMMAND_PLAYER_NAME_UPDATE)
	
	-- self:addChild( Coord.scgap(display.newImage("p_ui_1003.png"),"CC",0,"TT",-20))
	
	self:addChild( Coord.scgap(display.newDynamicImage(display.getResolutionPath("ui_dlxt_jmdb_hygl.png")),"CC",0,"TT",-20))
	local girlSke = display.newSpine("res/images/spine/hall_girl.json", "res/images/spine/hall_girl_tex.atlas")
	girlSke:setScaleX(-1)
	girlSke:setAnimation(0, "newAnimation", true)
	girlSke:setPosition(cc.p(150,50))
	self:addChild(girlSke)
	
	self:m_initPlayerInfoLayout()
	self:m_initOperateLayout()
	self:m_initGameunit()
end
--初始化玩家信息面板
function MainView:m_initPlayerInfoLayout()
	local bg = display.newImage("p_ui_1002.png")
	bg:setTouchEnabled(true)
	self:addChild( Coord.scgap(bg,"LL",0,"TT",0))
	--玩家头像
	local headIcon = display.newDynamicImage(Player.headpath)
	headIcon:setScale(0.6)
	bg:addChild(Coord.ingap(bg,headIcon,"LL",7,"TT",-7,true))
	self.m_headIcon = headIcon
	--玩家名字文本
	local nametxt = display.newText(Player.name,30)
	nametxt:setAnchorPoint( cc.p(0,0.5) )
	bg:addChild( Coord.ingap(bg,nametxt,"LL",120,"CB",5))
	self.m_nametxt = nametxt
	--id文本
	local idtxt = display.newText( display.trans("##2000",Player.id),24,Color.ORANGE)
	bg:addChild( Coord.ingap(bg,idtxt,"LL",120,"CT",-10))
	--复制按钮
	local copyBtn = display.newButton("p_btn_1009.png","p_btn_1009.png")
	copyBtn:setPressedActionEnabled(true)
	display.extendButtonToSound(copyBtn)
	bg:addChild( Coord.ingap(bg,copyBtn,"RR",-50,"CC",-20))
	
	copyBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		--native 接口待实现
		--复制成功后提示
		display.showMsg(display.trans("##20008"))
	end)
	--头像点击
	bg:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.ui.window.InfoSettingWindows")
	end)
	
	local goldbg = display.newImage("p_ui_1006.png")
	display.setS9(goldbg,cc.rect(70,25,10,10),cc.size(280,63))
	goldbg:setTouchEnabled(true)
	display.extendButtonToSound(goldbg)
	self:addChild( Coord.scgap(goldbg,"RR",-5,"TT",-20))
	goldbg:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		display.showWindow("src.ui.window.MartWindows")
	end)
	local goldtxt = display.newText(string.thousandsformat(Player.gold),26,Color.ORANGE)
	goldtxt:setAnchorPoint( cc.p(0,0.5) )
	goldbg:addChild( Coord.ingap(goldbg,goldtxt,"LL",80,"CC",0))
	self.m_goldtxt = goldtxt
end
--初始化操作面板
function MainView:m_initOperateLayout()
	local bg = display.newImage("p_ui_1004.png")
	self:addChild( Coord.ingap(self,bg,"CC",0,"BB",0))
	
	--商城按钮
	local martbtn = display.newLayout(cc.size(130,140))
	display.extendButtonToSound(martbtn,"main_sound_hall_click")
	martbtn:setAnchorPoint( cc.p(0.5,0.5) )
	martbtn:setTouchEnabled(true)
	-- self:addChild( Coord.ingap(self,martbtn,"LL",30,"BB",15))
	local delegaSp = display.newSprite("p_btn_1011.png")
	martbtn:addChild(Coord.ingap(martbtn,delegaSp,"CC",0,"CC",0))
	delegaSp:runAction(cc.RepeatForever:create(resource.getAnimateByKey("hall_martbtn_anim")))
	martbtn:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then 
			t:setScale(1.1)
		elseif e == ccui.TouchEventType.canceled then 
			t:setScale(1)
		elseif e == ccui.TouchEventType.ended then 
			t:setScale(1)
			--商场点击处理
			display.showWindow("src.ui.window.MartWindows")
		end		
	end)
	--返回按钮
	local backbtnBgLayout = display.newLayout(cc.size(120,120))
	self:addChild( Coord.ingap(self,backbtnBgLayout,"RR",-60,"BB",10))
	backbtnBgLayout:setVisible(false)
	self.m_backbtnBgLayout = backbtnBgLayout
	
	local backBtnAnima_1 = display.newSprite("p_ui_1084.png")
	backBtnAnima_1:setScale(1.8)
	backbtnBgLayout:addChild( Coord.ingap(backbtnBgLayout,backBtnAnima_1,"CC",0,"CC",3))
	
	local backbtn = display.newButton("p_btn_1001.png","p_btn_1001.png")
	backbtn:setPressedActionEnabled(true)
	display.extendButtonToSound(backbtn,"main_sound_hall_click")
	backbtnBgLayout:addChild( Coord.ingap(backbtnBgLayout,backbtn,"CC",0,"CC",0))
	
	local backBtnAnima_2 = display.newSprite("p_ui_1085.png")
	backBtnAnima_2:setScale(1.55)
	backbtnBgLayout:addChild( Coord.ingap(backbtnBgLayout,backBtnAnima_2,"CC",-3,"CC",5,true))
	backBtnAnima_2:runAction(cc.RepeatForever:create(
		cc.Sequence:create({
			cc.RotateTo:create(1,180),
			cc.RotateTo:create(1,360),
		})
	))
	
	backbtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		if self.m_grounpLayout then
			self.m_grounpLayout:removeFromParent(true)
			self.m_grounpLayout = nil
			self.m_gameunitLayout:setVisible(true)
			self.m_backbtnBgLayout:setVisible(false)
		end
	end)
	local config = {
		--签到
		-- {icon = "p_btn_1002.png",name = display.trans("##2001"),windowname = "src.ui.window.DailySignWindows"},
		--消息
		-- {icon = "p_btn_1003.png",name = display.trans("##2002"),windowname = "src.ui.window.NoticeWindows"},
		--返利
		{icon = "p_btn_1004.png",name = display.trans("##2003"),windowname = "src.ui.window.AwardWindows"},
		--银行
		{icon = "p_btn_1005.png",name = display.trans("##2004"),windowname = "src.ui.window.bank.BankWindows",windowparams = 1},
		--排行
		{icon = "p_btn_1006.png",name = display.trans("##2005"),windowname = "src.ui.window.leaderboard.LeaderBoardWindows"},
		--客服
		{icon = "p_btn_1007.png",name = display.trans("##2006"),windowname = "src.ui.window.ClientServiceWindows"},
		--设置
		{icon = "p_btn_1008.png",name = display.trans("##2007"),windowname = "src.ui.window.SettingWindows"},
	}
	
	local function touchcallback(t,e)
		if e ~= ccui.TouchEventType.ended then return end
		if t.windowname ~= "" then
			display.showWindow(t.windowname,t.windowparams)
		end
	end
	local item,temp
	for i = 1,#config do
		item = CustomButton.new(config[i].icon,config[i].name)
		item.windowname = config[i].windowname
		item.windowparams = config[i].windowparams
		item:addTouchEventListener(touchcallback)
		if temp then
			bg:addChild(Coord.outgap(temp,item,"RL",80,"BB",0))
		else
			bg:addChild(Coord.ingap(bg,item,"LL",200,"BB",5))
		end
		temp = item
	end
end
--初始化游戏分类按钮
function MainView:m_initGameunit()
	local layout = display.newLayout(cc.size(930,450))
--	display.debugLayout(layout)
	self:addChild(Coord.ingap(self,layout,"RR",-50,"BB",140))
	
	local btn1 = require("src.ui.item.GameHallButton").new(ST.TYPE_GAMEHALL_2,"res/images/spine/solot.json", "res/images/spine/solot_tex.atlas")
	btn1:setLocalZOrder(1)
	layout:addChild(Coord.ingap(layout,btn1,"LL",0,"CC",0))
	btn1:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		--如果是代理不能进入游戏
		-- if(Player.is_agent == 1)then
		-- 	display.showMsg(display.trans("##2073"))
		-- 	return
		-- end
		self:showGameGroups(t.gametype)
		Player.setGameTYpe(t.gametype)  -- 玩家打开游戏类型
	end)
	
	local btn2 = require("src.ui.item.GameHallButton").new(ST.TYPE_GAMEHALL_1,"res/images/spine/chess.json", "res/images/spine/chess_tex.atlas")
	btn2:setLocalZOrder(0)
	layout:addChild(Coord.outgap(btn1,btn2,"RL",55,"CC",0))
	-- layout:addChild(Coord.ingap(layout,btn2,"LL",0,"CC",0))
	btn2:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		-- if(Player.is_agent == 1)then
		-- 	display.showMsg(display.trans("##2073"))
		-- 	return
		-- end
		self:showGameGroups(t.gametype)
		Player.setGameTYpe(t.gametype)-- 玩家打开游戏类型
	end)
	
	local btn3 = require("src.ui.item.GameHallButton").new(ST.TYPE_GAMEHALL_3,"res/images/spine/fishing.json", "res/images/spine/fishing_tex.atlas")
	btn3:setLocalZOrder(1)
	layout:addChild(Coord.outgap(btn2,btn3,"RL",55,"CC",0))
	btn3:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		-- if(Player.is_agent == 1)then
		-- 	display.showMsg(display.trans("##2073"))
		-- 	return
		-- end
		self:showGameGroups(t.gametype)
		Player.setGameTYpe(t.gametype)-- 玩家打开游戏类型
	end)

	self.m_gameunitLayout = layout
	
	if(Player.open_gametype)then
		self:showGameGroups(Player.open_gametype)
	end

end

function MainView:showGameGroups(grouptype)
	
	if Player.gameMgr:isInitGameHall(grouptype) then
		self:m_createGameGroups(grouptype)
	else
		ConnectMgr.connect("gamehall.GameHallConnect" , grouptype,function(result) 
			if result ~= 0 then return end
			self:showGameGroups(grouptype)
		end)
	end
end

function MainView:m_createGameGroups(grouptype)
	self.m_backbtnBgLayout:setVisible(true)
	local games = Player.gameMgr:getGames(grouptype)
	
	self.m_gameunitLayout:setVisible(false)
	local layout = display.newLayout(cc.size(940,470))
--	display.debugLayout(layout)
	self:addChild(Coord.ingap(self,layout,"RR",-50,"BB",140))
	--左提示箭头		
	local leftarrow = display.newImage("p_ui_1008.png")
	leftarrow:setScale(1.3)
	leftarrow:setVisible(false)
	layout:addChild(Coord.ingap(layout,leftarrow,"LR",-5,"CC",0))
	--右提示箭头
	local rightarrow = display.newImage("p_ui_1008.png")
	rightarrow:setScale(1.3)
	rightarrow:setVisible(false)
	layout:addChild(Coord.ingap(layout,rightarrow,"RL",5,"CC",0))
	rightarrow:setRotation(180)
	
	local pageview = ccui.PageView:create()
	pageview:setContentSize( cc.size(940,470) )
	pageview:setTouchEnabled(true)
	pageview:setDirection(2)
	
	layout:addChild(Coord.ingap(layout,pageview,"CC",0,"CC",0))
	local opengame = nil
	local page,item,temp
	for i = 1,#games do
		if not page then 
			page = display.newLayout(cc.size(940,470)) 
			pageview:addPage(page)
		end
		item = require("src.ui.item.GameEntryButton").new(games[i])
		if not temp then
			if i%8 > 4 then
				page:addChild(Coord.ingap(page,item,"LL",10,"CT",-5,true))
			else
				page:addChild(Coord.ingap(page,item,"LL",10,"CB",5,true))
			end
		else
			page:addChild(Coord.outgap(temp,item,"RL",12,"CC",0,true))
		end
		temp = item
		--新的一排
		if i%4 == 0 then temp = nil end
		--新的一页
		if i%8 == 0 then page = nil end

		if(games[i].sid == Player.open_gamesid)then
			opengame = games[i] 
		end
		 
	end



	if #games > 8 then 
		rightarrow:setVisible(true)
	end
	
	pageview:addEventListener(function(t,e) 
		local index = t:getCurrentPageIndex()
		if index > 0 then
			leftarrow:setVisible(true)
		else
			leftarrow:setVisible(false)
		end
		if t:getItem(index + 1) then
			rightarrow:setVisible(true)
		else
			rightarrow:setVisible(false)
		end
	end)
	self.m_grounpLayout = layout

	if(opengame)then

		ConnectMgr.connect("gamehall.GameRoomConnect" , opengame,function(result) 
				if result ~= 0 then return end
				display.showWindow("src.ui.window.room.RoomWindows",opengame)
				
			end)

		-- display.showWindow("src.ui.window.room.RoomWindows",games[i])
		-- Player.setGameSid(0)
	end

end

function MainView:handlerEvent(event,arg)
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		self.m_goldtxt:setString(string.thousandsformat(Player.gold))
	elseif event == ST.COMMAND_PLAYER_HEAD_UPDATE then
		self.m_headIcon:loadTexture(Player.headpath)
	elseif event == ST.COMMAND_PLAYER_NAME_UPDATE then
		self.m_nametxt:setString(Player.name)
	end
end
function MainView:onCleanup()
	self:removeAllEvent()
end
-- ---------------------------@CustomButton-------------------------------------------
function CustomButton:ctor(path,name)
	self:super("ctor")
	self:setAnchorPoint( cc.p(0.5,0.5) )
	local icon = display.newImage(path)
	self:addChild(Coord.ingap(self,icon,"CC",0,"BB",30))
	
	local nametxt = display.newText(name,26,cc.c3b(0xa6,0xa8,0xfb))
	nametxt:setAnchorPoint( cc.p(0.5,0) )
	self:addChild(Coord.ingap(self,nametxt,"CC",0,"BB",0))
	
	self:m_addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then 
			self:setScale(1.1)
			SoundsManager.playSound("main_sound_hall_click")
		elseif e == ccui.TouchEventType.ended then 
			self:setScale(1)
		elseif e == ccui.TouchEventType.canceled then 
			self:setScale(1)
		end		
		if self.m_callback then self.m_callback(t,e) end
	end)
end
function CustomButton:addTouchEventListener(callback)
	self.m_callback = callback
end
function CustomButton:onCleanup()
	self.m_callback = nil
end
return MainView