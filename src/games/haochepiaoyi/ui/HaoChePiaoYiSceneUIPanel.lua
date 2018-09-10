--[[
 *	飞禽走兽UI
 *	@author gwj
]]
local HaoChePiaoYiSceneUIPanel = class("HaoChePiaoYiSceneUIPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"),IEventListener)

local MULTIPLE_POINTS ={cc.p(377,250),cc.p(563,244),cc.p(749,244),cc.p(933,250),cc.p(377,462),cc.p(564,462),cc.p(749,462),cc.p(933,462)}
local POLYS_POINTS ={
	{cc.p(373,456),cc.p(555,456),cc.p(555,248),cc.p(531,253),cc.p(507,265),cc.p(490,272),cc.p(472,282),cc.p(455,298),cc.p(432,315),cc.p(417,333),cc.p(402,353)
	,cc.p(392,375),cc.p(384,398),cc.p(379,414),cc.p(376,434),cc.p(374,452)},
	{cc.p(561,247),cc.p(561,454),cc.p(739,454),cc.p(741,243),cc.p(587,243),cc.p(568,246)},
	{cc.p(747,245),cc.p(747,454),cc.p(923,454),cc.p(922,248),cc.p(898,243),cc.p(752,243)},
	{cc.p(930,247),cc.p(930,454),cc.p(1114,454),cc.p(1108,418),cc.p(1101,378),cc.p(1075,335),cc.p(1035,298),cc.p(1016,281),cc.p(978,260),cc.p(940,247),cc.p(929,247)},
	{cc.p(373,459),cc.p(376,494),cc.p(389,538),cc.p(431,602),cc.p(479,638),cc.p(522,659),cc.p(555,669),cc.p(555,459)},
	{cc.p(561,461),cc.p(561,669),cc.p(590,674),cc.p(741,674),cc.p(741,461)},
	{cc.p(746,461),cc.p(746,674),cc.p(890,674),cc.p(922,672),cc.p(923,461)},
	{cc.p(930,461),cc.p(930,669),cc.p(980,653),cc.p(1030,623),cc.p(1069,585),cc.p(1098,538),cc.p(1115,461),cc.p(933,461)}
}
local LIGHT_PONITS = {
{point = cc.p(284,288),flipX = false,flipY = false},
{point = cc.p(1028,288),flipX = true,flipY = false},
{point = cc.p(1016,635),flipX = true,flipY = true},
{point = cc.p(282,633),flipX = false,flipY = true}}

--小保时捷 1 小宝马 2 小奔驰 3 小大众 4 大保时捷 5 大宝马 6 大奔驰 7 大大众 8
local ELEMENT_CONFIG = {
	{sid = 6,point = cc.p(248,238)},
	{sid = 2,point = cc.p(187,296)},
	{sid = 7,point = cc.p(149,370)},
	{sid = 3,point = cc.p(137,453)},
	{sid = 8,point = cc.p(149,536)},
	{sid = 4,point = cc.p(187,610)},
	{sid = 5,point = cc.p(245,666)},
	{sid = 1,point = cc.p(320,705)},
	{sid = 6,point = cc.p(402,716)},
	{sid = 2,point = cc.p(484,716)},
	{sid = 7,point = cc.p(565,716)},
	{sid = 3,point = cc.p(650,716)},
	{sid = 8,point = cc.p(731,716)},
	{sid = 4,point = cc.p(814,716)},
	{sid = 5,point = cc.p(897,716)},
	{sid = 1,point = cc.p(978,704)},
	{sid = 6,point = cc.p(1054,665)},
	{sid = 2,point = cc.p(1116,610)},
	{sid = 7,point = cc.p(1153,535)},
	{sid = 3,point = cc.p(1168,453)},
	{sid = 8,point = cc.p(1156,370)},
	{sid = 4,point = cc.p(1116,295)},
	{sid = 5,point = cc.p(1055,239)},
	{sid = 1,point = cc.p(978,204)},
	{sid = 6,point = cc.p(897,192)},
	{sid = 2,point = cc.p(814,192)},
	{sid = 7,point = cc.p(731,192)},
	{sid = 3,point = cc.p(648,192)},
	{sid = 8,point = cc.p(566,192)},
	{sid = 4,point = cc.p(484,192)},
	{sid = 5,point = cc.p(402,192)},
	{sid = 1,point = cc.p(320,205)}
}

--筹码区域
local bet_region_rects = {cc.rect(450,300,100,140),cc.rect(600,300,100,140),cc.rect(785,300,100,140),cc.rect(935,300,100,140),cc.rect(430,462,100,140),cc.rect(579,462,140,150),cc.rect(765,462,140,150),cc.rect(940,462,100,140)}

local soundController = require("src.games.haochepiaoyi.data.HaoChePiaoYiSoundController").getInstance()
function HaoChePiaoYiSceneUIPanel:ctor(room)
	self.room = room
	self.isReadState = false	--是否在本地状态
	self.multipleList = {}		--倍数列表
	self.autoLight_List = {}	--车灯列表
	self.gameItemList = {}		--元素列表gameItemList
	self.dropItemList = {}		--右边控件集合
	self.betPoint_array = {}	 --筹码的坐标
	self.betItem_array = {}	 --筹码的集合
	self.multipleFontList = {}
	self.isStart = false	 --是否开始
	self.nowTime = 0         --当前计时器
	self.speed = 20          --闪动的速度
	self.runTime = 0         --闪动的时间
	self.overTime = 0        --闪动结束的时间
	self.blinkIndex = 0	     --当前闪
	self.resultIndex = 0     --结果索引
	self.slowIndex = 0 		 --减速的步数
	self.isClimb = false     --是否龟速
	self.isLastTurn = false  --是否最后一回合
	self.gameState = 0       --游戏状态 1 准备下注 2可以下注 3下注结束游戏开始 4 游戏结束
	self.soundController = require("src.games.haochepiaoyi.data.HaoChePiaoYiSoundController").getInstance()
	self.dataController = require("src.games.haochepiaoyi.data.HaoChePiaoYiDataController").getInstance()

	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_GAMEHCPY_INITWAIT)
	self:addEvent(ST.COMMAND_GAMEHCPY_BETBEGIN)
	self:addEvent(ST.COMMAND_GAMEHCPY_BETEND)
	self:addEvent(ST.COMMAND_GAMEHCPY_BETCHANGE)
	self:addEvent(ST.COMMAND_GAMEHCPY_UPDATEDROP)
	self:addEvent(ST.COMMAND_GAMEHCPY_UPDATEBANKER)
	self:addEvent(ST.COMMAND_GAMEHCPY_UPDATEAPPLY)
	self:addEvent(ST.COMMAND_GAMEHCPY_UPBANKERSTATE)
	self:addEvent(ST.COMMAND_PLAYER_BANK_GOLD_UPDATE)
	local main_layout = display.newImage("#game/haochepiaoyi/fcpy_bg.png")
	display.extend("CCNodeExtend",main_layout)
	main_layout:setAnchorPoint(cc.p(0,0))
	self:addChild(main_layout)
	self.main_layout = main_layout

	--右边
	local backdrop_layout = display.newImage("fcpy_icon_18.png")
	self.main_layout:addChild(backdrop_layout)
	Coord.ingap(self.main_layout,backdrop_layout,"RR",-25,"CC",0)
	self.backdrop_layout = backdrop_layout

	--规则按钮
	local rule_btn = display.newButton("fcpy_btn_12.png","fcpy_btn_13.png",nil)
	Coord.ingap(self.main_layout,rule_btn,"RR",-5,"TT",-5)
	self.main_layout:addChild(rule_btn)
	rule_btn:addTouchEventListener(function(sender,eventype)
		    if eventype == ccui.TouchEventType.ended then
		    	require("src.games.haochepiaoyi.ui.HaoChePiaoYiRulePanel").show()
	        end
	    end)

	--底部
	local bottom_layout = display.newImage("fcpy_icon_17.png")
	self.main_layout:addChild(bottom_layout,1)
	Coord.ingap(self.main_layout,bottom_layout,"LL",-5,"BB",-5)
	self.bottom_layout = bottom_layout
	--底部的框
	local bottom_rect_img = display.newImage("fcpy_icon_16.png")
	self.main_layout:addChild(bottom_rect_img,1)
	Coord.ingap(self.main_layout,bottom_rect_img,"CC",0,"BB",0)

	--庄闲
	local zx_icon_img = display.newImage("fcpy_icon_41.png")
	Coord.ingap(self.bottom_layout,zx_icon_img,"LL",10,"BB",65)
	self.bottom_layout:addChild(zx_icon_img)
	self.zx_icon_img = zx_icon_img
	local zx_name_label = display.newText(Player.name,24)
	zx_name_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(zx_icon_img,zx_name_label,"RL",10,"CC",0)
	self.bottom_layout:addChild(zx_name_label)
	--vip
	local vip_icon = display.newImage("fcpy_icon_43.png")
	self.bottom_layout:addChild(vip_icon)
	Coord.ingap(self.bottom_layout,vip_icon,"LL",250,"BB",75)
	local vip_label = ccui.TextAtlas:create(Player.level,"game/haochepiaoyi/fcpy_vip_142_21.png",14.2,21,0)
    self.bottom_layout:addChild(vip_label)
    Coord.outgap(vip_icon,vip_label,"RL",2,"CC",0)
	--金币
	local jb_icon_img = display.newImage("fcpy_icon_40.png")
	Coord.ingap(self.bottom_layout,jb_icon_img,"LL",10,"BB",20)
	self.bottom_layout:addChild(jb_icon_img)
	local jb_value_label = display.newNumberText(Player.gold,24,Color.GWJ_IIII)
	jb_value_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(jb_icon_img,jb_value_label,"RL",10,"CC",0)
	self.bottom_layout:addChild(jb_value_label)
	self.jb_value_label = jb_value_label
	--银行
	local bank_btn = require("src.ui.item.ExButton").new("fcpy_btn_1.png","fcpy_btn_2.png","fcpy_btn_3.png")
	Coord.outgap(self.bottom_layout,bank_btn,"RL",5,"CC",0)
	self.main_layout:addChild(bank_btn)
	bank_btn:addTouchEventListener(function(sender,eventype)
		    if eventype ~= ccui.TouchEventType.ended then
		    	display.showWindow("src.ui.window.bank.BankWindows")
	        end
	    end)
	self.bank_btn = bank_btn

	--续投按钮
	local continue_btn = require("src.ui.item.ExButton").new("fcpy_btn_7.png","fcpy_btn_8.png","fcpy_btn_9.png")
	self.main_layout:addChild(continue_btn)
	Coord.outgap(bank_btn,continue_btn,"RL",15,"CC",0)
	continue_btn:addTouchEventListener(function(sender,eventype)
		    if eventype ~= ccui.TouchEventType.ended then return end
	    	if self.dataController.state ~= 1 then
		    	display.showMsg(display.trans("##20022"))
		    	return
		    end
	    	ConnectMgr.connect("src.games.haochepiaoyi.content.HaoChePiaoYiGetBetAgainConnect",self.dataController.againData,function(result)
	    		if result then
	    			self.self_isBet = true
	    			self.continue_btn:setDisable(true)
	    			for i=1,#self.dataController.againData do
	    				local data = self.dataController.againData[i]
	    				local multipleItem = self.multipleList[data.multiplesSid]
	    				local point = self:getBetPointByValue(data.money)
	    				self:addBet(data.money,data.multiplesSid,self:getBetPointByValue(data.money))
	    				self.multipleFontList[data.multiplesSid]:addSelfValue(data.money)
	    				self.multipleFontList[data.multiplesSid]:addTotalValue(data.money)
	    			end
	    			self.dataController:betAgain()
	    			self.jb_value_label:setFormatNumber(Player.gold)
	    			self:checkDisable()
	    		end
	    	end)
	    end)
	self.continue_btn = continue_btn
	self.continue_btn:setDisable(true)
	--上庄按钮
	local sz_btn = display.newButton("fcpy_btn_14.png","fcpy_btn_15.png",nil)
	Coord.ingap(self.main_layout,sz_btn,"LL",220,"CC",77)
	self.main_layout:addChild(sz_btn)
	sz_btn.state = false
	sz_btn:addTouchEventListener(function(sender,eventype)
		    if eventype ~= ccui.TouchEventType.ended then
		    	if not sender.state then
		    		if not display.checkGold(100000000) then
		    			return
		    		end
		    		ConnectMgr.connect("src.games.haochepiaoyi.content.HaoChePiaoYiBecomeBankerConnect",function(result)
		    			if result then
		    				display.showMsg(display.trans("##20018"))
		    				self.dataController:setIsbanker(true)
		    			end
		    		end)
		    	else
		    		ConnectMgr.connect("src.games.haochepiaoyi.content.HaoChePiaoYiOutGoBankerConnect",function(result)
		    			if result then
		    				display.showMsg(display.trans("##20019"))
		    				self.dataController:setIsbanker(false)
		    			end
		    		end)
		    	end
	        end
	    end)
	self.sz_btn = sz_btn
	self.sz_btn:setVisible(false)

	--庄家金币
	local zjjb_icon_img = display.newImage("fcpy_icon_40.png")
	Coord.outgap(sz_btn,zjjb_icon_img,"LR",15,"TB",0)
	self.main_layout:addChild(zjjb_icon_img)
	zjjb_icon_img:setScale(0.8)
	local zjjb_value_label = display.newNumberText("",20,Color.GWJ_IIII)
	zjjb_value_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(zjjb_icon_img,zjjb_value_label,"RL",5,"CC",0)
	self.main_layout:addChild(zjjb_value_label)
	self.zhuang_jinbi_label = zjjb_value_label

	--庄家名字
	local zhuangname_icon = display.newImage("fcpy_icon_39.png")
	Coord.outgap(zjjb_icon_img,zhuangname_icon,"LL",0,"TB",-5)
	zhuangname_icon:setScale(0.8)
	self.main_layout:addChild(zhuangname_icon)
	local zhuangname_label = display.newText("",20,Color.GWJ_F)
	self.main_layout:addChild(zhuangname_label)
	zhuangname_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(zhuangname_icon,zhuangname_label,"RL",0,"CC",-4)
	self.zhuangname_label = zhuangname_label

	--申请人数
	local sqrs_label = display.newText("",18,Color.GWJ_F)
	sqrs_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(sz_btn,sqrs_label,"LL",0,"BT",-19)
	self.main_layout:addChild(sqrs_label)
	self.szsqrs_label = sqrs_label
	self.szsqrs_label:setVisible(false)

	--上庄需要
	local szxy_label = display.newText(display.trans("##20021"),20,Color.GWJ_F)
	szxy_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(sqrs_label,szxy_label,"LL",5,"BT",-19)
	self.main_layout:addChild(szxy_label)
	szxy_label:setVisible(false)
	--总下注
	local zxz_icon_img = display.newImage("fcpy_icon_45.png")
	Coord.ingap(self.main_layout,zxz_icon_img,"CC",20,"CC",270)
	self.bottom_layout:addChild(zxz_icon_img)
	local zxz_value_label = ccui.TextAtlas:create("","game/haochepiaoyi/fcpy_number_3.png",22,30,0)
	zxz_value_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(zxz_icon_img,zxz_value_label,"RL",5,"CC",0)
	self.bottom_layout:addChild(zxz_value_label)
	self.zxz_label = zxz_value_label

	self:initBetMenus()
	self:initMultiple()
	self:initelement()
	self:initDropItem()
	--绘制多边形
	-- local draw = cc.DrawNode:create()
	-- draw:drawPoly(POLYS_POINTS[8], #POLYS_POINTS[8], true, cc.c4f(math.random(0,1), math.random(0,1), math.random(0,1), 1))
	-- self.main_layout:addChild(draw)

	local function onTouchesBegan(touch,event)
		local begin_positon = touch:getLocation()
		for i=1,#POLYS_POINTS do
			local poly = POLYS_POINTS[i]
			if Command.IsPtInPoly(begin_positon, poly) then
				self:multipleClick(i)				
				break
			end
		end
		-- print(begin_positon.x,begin_positon.y)
		return true
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCH_BEGAN)
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,self)
    self:scheduleUpdateWithPriorityLua(function()
		self:runAction()
	end,0.01)
end

--@override
function HaoChePiaoYiSceneUIPanel:handlerEvent(event,arg)
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		if self.isReadState then return end
		self.jb_value_label:setFormatNumber(Player.gold)
		self:checkDisable()
	elseif event == ST.COMMAND_GAMEHCPY_UPDATEDROP then
		self:updateDropItem()
	elseif event == ST.COMMAND_PLAYER_BANK_GOLD_UPDATE then
		self.jb_value_label:setFormatNumber(Player.gold)
		self:checkDisable()
	elseif event == ST.COMMAND_GAMEHCPY_BETBEGIN then
		self:playReady()
		if self.dataController.term_count >= 2 then
			display.showMsg(display.newRichText(display.trans("##11001",self.dataController.term_count)))
		end
		print("开始准备···························")
	elseif event == ST.COMMAND_GAMEHCPY_BETEND then
		require("src.games.haochepiaoyi.ui.HaoChePiaoYiBeautyPanel").show(2)
		self.main_layout:performWithDelay(function()
			self:playGame(self.dataController.winSid)
		end,1)
		print("游戏开始···························")
	elseif event == ST.COMMAND_GAMEHCPY_BETCHANGE then
		local bet_users = arg
		for i=1,#bet_users do
			local bet = bet_users[i]
			local random_delay = math.random(1,8)
			self:addBet(bet.money,bet.multipleSid,self:getStartPoint(),random_delay/10)
		end
		print("下注了···························")
		self.main_layout:performWithDelay(function()
			for i=1,#self.dataController.bets_array do
				local data = self.dataController.bets_array[i]
				self.multipleFontList[i]:setTotalValue(self.dataController.bets_array[i])
			end
			self:updateAllBetValue(self.dataController.allbetValue)
		end,0.3)
	elseif event == ST.COMMAND_GAMEHCPY_INITWAIT then
		self:showWait()
	elseif event == ST.COMMAND_GAMEHCPY_UPDATEBANKER then
		if arg then
			display.showMsg(display.trans("##4011"))
		end
		if self.dataController:playerIsBanker() then
			self.zx_icon_img:loadTexture("fcpy_icon_42.png",1)
		else
			self.zx_icon_img:loadTexture("fcpy_icon_41.png",1)
		end
		self.zhuangname_label:setString(self.dataController.banker_name)
		self.zhuang_jinbi_label:setFormatNumber(self.dataController.banker_money)
	elseif event == ST.COMMAND_GAMEHCPY_UPDATEAPPLY then
		self.szsqrs_label:setString(display.trans("##20024")..self.dataController.apply_number)
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		display.enterScene("src.ui.ReloginScene",{self.room})
	elseif event == ST.COMMAND_GAMEHCPY_UPBANKERSTATE then
		self:updateShangZhuangState()
	end
end

function HaoChePiaoYiSceneUIPanel:checkDisable()
	local btn_list = self.m_buttonMgr:getButtonList()
	for i=1,#btn_list do
		btn_list[i]:checkDisable()
	end
	if self.m_currentBetBtn and self.m_currentBetBtn.disable then
		self.m_buttonMgr:cleanCurrentButton()
		self.m_btnflow:setVisible(false)
		self.m_currentBetBtn = nil
	end
	self:checkContinueState()
end
--禁用所有投注按钮
function HaoChePiaoYiSceneUIPanel:disableAllBet()
	self.m_buttonMgr:cleanCurrentButton()
	self.m_btnflow:setVisible(false)
	local btn_list = self.m_buttonMgr:getButtonList()
	for i=1,#btn_list do
		btn_list[i]:setDisable(true)
	end
	self.continue_btn:setDisable(true)
	self.bank_btn:setDisable(true)
	self.m_currentBetBtn = nil
	self.isReadState = false
end
function HaoChePiaoYiSceneUIPanel:multipleClick(index)
	local sender = self.multipleList[index]
	sender:blink()
	if self.dataController.state ~= 1 then
    	display.showMsg(display.trans("##20022"))
    	return
    end
    if not self.m_currentBetBtn then return end
    ConnectMgr.connect("src.games.haochepiaoyi.content.HaoChePiaoYiGetBetConnect",self.m_currentBetBtn.betvalue,sender:getSid(),
	    function(result)
	    	if result then
	    		self.self_isBet = true
	    		if self.m_currentBetBtn then
			    	local current_Position = cc.p(self.m_currentBetBtn:getPositionX(),self.m_currentBetBtn:getPositionY())
			    	self:addBet(self.m_currentBetBtn.betvalue,sender:getSid(),current_Position)
			    	self.multipleFontList[sender:getSid()]:addSelfValue(self.m_currentBetBtn.betvalue)
			    	self.multipleFontList[sender:getSid()]:addTotalValue(self.m_currentBetBtn.betvalue)
			    	self.dataController:addBet(self.m_currentBetBtn.betvalue,sender:getSid())
			    	self.jb_value_label:setFormatNumber(Player.gold)
					self:checkDisable()
					self:checkContinueState()
				else
					display.showMsg(display.trans("##20023"))
			    end
	    	end
	    end)
end
function HaoChePiaoYiSceneUIPanel:runAction()
	if not self.isStart then return end
	self.nowTime = self.nowTime+1
	if self.nowTime == self.speed then
		self.nowTime = 0
		if self.blinkIndex > 0 then
			self.gameItemList[self.blinkIndex]:disappear()
		end
		self.blinkIndex = self.blinkIndex + 1
		self.runTime = self.runTime + 1
		if self.blinkIndex > #self.gameItemList then
			self.blinkIndex = 1
		end
		if self.isLastTurn and self.blinkIndex == self.resultIndex then
			SoundsManager.playSound("fcpy_turn_end")
		else
			self:playSpeedSound(self.speed)
		end
		self.gameItemList[self.blinkIndex]:blink()
		if self.runTime < 3 then
			self.speed = 20
		elseif self.runTime < 6 then
			self.speed = 15
		elseif self.runTime < 12 then
			self.speed = 10
		elseif self.runTime < 18 then
			self.speed = 5
		elseif self.runTime < 24 then
			self.speed = 2
		else
			if self.runTime > 60 then   --计算结果
				if self.blinkIndex == self.slowIndex then
					self.isClimb = true
					self:removeShadow()
				end
				if self.isClimb then
					self.overTime = self.overTime + 1
					if self.overTime < 4 then
						self.speed = 5
					elseif self.overTime < 8 then
						self.speed = 20
					-- elseif self.overTime < 18 then
					-- 	self.speed = 20
					elseif self.overTime >= 12 then
						self.speed = 60
						self.isLastTurn = true
						if self.blinkIndex == self.resultIndex then
							self:gameOver()
						end
					end
				else
					self.speed = 2
					self:showShadow()
				end
			else
				self.speed = 2
				self:showShadow()
			end
		end
	end
end
function HaoChePiaoYiSceneUIPanel:showShadow()
	local tempIndex = self.blinkIndex
	local opacityList = {200,140,80}
	if self.blinkIndex > 0 then
		for i=1,4 do
			tempIndex = tempIndex - 1
			if tempIndex < 1 then
				tempIndex = #self.gameItemList
			end
			if i > #opacityList then
				self.gameItemList[tempIndex]:disappear() 
				self.gameItemList[tempIndex]:setRectOpacity(255)
			else
				self.gameItemList[tempIndex]:blink()
				self.gameItemList[tempIndex]:setRectOpacity(opacityList[i])
			end
		end
	end
end
function HaoChePiaoYiSceneUIPanel:removeShadow()
	local tempIndex = self.blinkIndex
	for i=1,4 do
		tempIndex = tempIndex - 1
		if tempIndex < 1 then
			tempIndex = #self.gameItemList
		end
		self.gameItemList[tempIndex]:disappear() 
		self.gameItemList[tempIndex]:setRectOpacity(255)
	end
end
function HaoChePiaoYiSceneUIPanel:getDistanceIndex(index,distance)
	local length = #self.gameItemList
	if distance > length then
		distance = distance % length
	end
	local temp = index - distance
	if temp <= 0 then
		temp = length - math.abs(temp)
	end
	return temp
end
function HaoChePiaoYiSceneUIPanel:initDropItem()
	local beginPoint = self.backdrop_layout:getContentSize().height - 100
	for i=1,8 do
		local animal_item = display.newLayout(cc.size(70,70))
		local icon = display.newImage()
		icon:setPosition(cc.p(35,35))
		animal_item:addChild(icon)
		animal_item:setPosition(cc.p((self.backdrop_layout:getContentSize().width - 70 )/2,beginPoint -  (i-1)*70))
		animal_item.icon = icon
		self.backdrop_layout:addChild(animal_item)
		table.insert(self.dropItemList,animal_item)

		-- local rect = display.newImage("fqzs-fly-main-icon-new.png")
		-- rect:setPosition(cc.p(35,35))
		-- animal_item:addChild(rect)
	end
end
function HaoChePiaoYiSceneUIPanel:updateDropItem()
	for i=1,#self.dataController.dropDatas do
		local sid = self.dataController.dropDatas[i]
		print("drop i -------------------------",i)
		local item = self.dropItemList[i]
		item.icon:loadTexture("fcpy_car_"..sid..".png",1)
		-- if data.isbig then
		-- 	item.icon:setScale(0.8)
		-- else
		-- 	item.icon:setScale(0.6)
		-- end
		if i == #self.dataController.dropDatas then
			if item.rect then
				item.rect:setVisible(true)
			else
				local rect =display.newImage("fcpy_icon_26.png")
				rect:setPosition(cc.p(35,35))
				item:addChild(rect)
				item.rect = rect
			end
		else
			if item.rect then
				item.rect:setVisible(false)
			end
		end
	end
end
--准备阶段
function HaoChePiaoYiSceneUIPanel:playReady()
	self:removeWait()
	if self.dataController:playerIsBanker() then
		self:disableAllBet()
	else
		self:checkDisable()
		self:checkContinueState()
	end
	self.bank_btn:setDisable(false)
	self:atuolightSwitch(false,false)
	self.isReadState = true
	for i=1,#self.betItem_array do
		self.betItem_array[i]:removeFromParent(true)
	end
	self.betItem_array = {}
	for i=1,#self.multipleFontList do
		self.multipleFontList[i]:cleanValue()
	end
	require("src.games.haochepiaoyi.ui.HaoChePiaoYiBeautyPanel").show(1)
	local surplus_time = self.dataController:getTime()
	if surplus_time > 2 then
		local clock_item = require("src.games.haochepiaoyi.ui.ClockCountDownItem").new(self.dataController:getTime(),true,function()
			self.clock_item = nil
		end)
		self.clock_item = clock_item
		self.main_layout:addChild(clock_item,2)
		Coord.ingap(self.main_layout,clock_item,"LL",300,"CC",220)
	end
end
function HaoChePiaoYiSceneUIPanel:playGame()
	if self.clock_item and self.clock_item:getSurplusTime() > 2 then
		self:removeClock()
		display.showMsg(display.trans("##20025"))
	end
	self.nowTime = 0
	self.overTime = 0
	self:disableAllBet()
	self:atuolightSwitch(true,true)
	local index_array = {}
	for i=1,#self.gameItemList do
		if self.gameItemList[i]:getSid() == self.dataController.winSid then
			table.insert(index_array,i)
		end
	end
	self.resultIndex = index_array[Command.random(#index_array)]
	self.speed = 20
	self.runTime = 0 
	self.isClimb = false
	self.isLastTurn = false
	self.slowIndex = self:getDistanceIndex(self.resultIndex,12)
	self.isStart = true
	SoundsManager.stopAllMusic()
	SoundsManager.playMusic("fcpy_award_bg",true)
end
function HaoChePiaoYiSceneUIPanel:gameOver()
	self.isStart = false
	self.main_layout:runAction(cc.Sequence:create({
		cc.DelayTime:create(1),
		cc.CallFunc:create(function()
			self.gameItemList[self.resultIndex]:showEffect()
		end),
	    cc.DelayTime:create(2),
	    cc.CallFunc:create(function()
	        local sid = self.gameItemList[self.resultIndex]:getSid()
	        self.dataController:addDrop(sid)
	        if self.dataController.self_winMoney < 0 then
	        	require("src.games.haochepiaoyi.ui.HaoChePiaoYiLostPanel").show(self.dataController.winSid,self.dataController.self_winMoney,self.dataController.banker_name,self.dataController.bankerResultMoney,self.dataController.userdatas)
	       	else
	       		require("src.games.haochepiaoyi.ui.HaoChePiaoYiWinPanel").show(self.dataController.winSid,self.dataController.self_winMoney,self.dataController.banker_name,self.dataController.bankerResultMoney,self.dataController.userdatas)
	       	end
	       	self.jb_value_label:setFormatNumber(Player.gold)
	    end)}))
end
function HaoChePiaoYiSceneUIPanel:initBetMenus()
	local config = {10,1000,10000,100000,1000000,5000000}
	local btnflow = display.newImage("fcpy_ui_1021.png")
	btnflow:setVisible(false)
	btnflow:setScale(1.35)
	btnflow:runAction(cc.RepeatForever:create(cc.Sequence:create({
		cc.ScaleTo:create(0.8,1),
		cc.ScaleTo:create(0.8,1.35)
	})))
	Coord.ingap(self.bottom_layout,btnflow,"CC",0,"CC",0)
	self.bottom_layout:addChild(btnflow)
	self.m_btnflow = btnflow
	local buttonMgr = require("src.base.control.RadioButtonControl").new()
	--单选按钮
	buttonMgr:addEventListener(buttonMgr.EVT_SELECT,function(e,t) 
		self.m_currentBetBtn = t
		btnflow:setVisible(true)
		Coord.outgap(t,btnflow,"CC",0,"CC",4,true)
	end)
	self.m_buttonMgr = buttonMgr
	--下注按钮
	local btn,temp
	for i = 1,#config do
		btn = require("src.games.haochepiaoyi.ui.BetButton").new(config[i])
		buttonMgr:addButton(btn)
		if not temp then
			self.bottom_layout:addChild(Coord.ingap(self.bottom_layout,btn,"CC",-145,"BB",0))
		else
			self.bottom_layout:addChild(Coord.outgap(temp,btn,"RL",15,"CC",0))
		end
		temp = btn
		table.insert(self.betPoint_array,cc.p(btn:getPositionX(),btn:getPositionY()))
	end
end
function HaoChePiaoYiSceneUIPanel:initMultiple()
	local font_points = {cc.p(435,345),cc.p(435,345),cc.p(435,345),
	cc.p(435,345),cc.p(435,345),cc.p(435,345),cc.p(435,345),cc.p(435,345)}
	local model = require("src.games.haochepiaoyi.ui.MultipleControl")
	local font_model = require("src.games.haochepiaoyi.ui.MultipleFontLayout")
	for i=1,#MULTIPLE_POINTS do
		local item = model.new(i)
		item:setPosition(MULTIPLE_POINTS[i])
		self.main_layout:addChild(item)
		table.insert(self.multipleList,item)

		local font_item = font_model.new(i)
		local font_ps = item:convertToWorldSpace(item:getSignPosition())
		font_ps = cc.p(font_ps.x,font_ps.y - 20)
		font_item:setPosition(font_ps)
		self.main_layout:addChild(font_item,2)
		table.insert(self.multipleFontList,font_item)
	end
end
function HaoChePiaoYiSceneUIPanel:initelement()
	local model = require("src.games.haochepiaoyi.ui.GameImage")
	for i=1,#ELEMENT_CONFIG do
		local data = ELEMENT_CONFIG[i]
		local item = model.new(data.sid,data.isbig)
		item:setPosition(data.point)
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
end
function HaoChePiaoYiSceneUIPanel:atuolightSwitch(isOn,isbreath)
	if isOn then 
		if #self.autoLight_List == 0 then
			for i=1,#LIGHT_PONITS do
				local light_img = display.newImage("fcpy_icon_28.png")
				light_img:setPosition(LIGHT_PONITS[i].point)
				light_img:setScale(1.7)
				if LIGHT_PONITS[i].flipX then
					light_img:setFlippedX(true)
				end
				if LIGHT_PONITS[i].flipY then
					light_img:setFlippedY(true)
				end
				self.main_layout:addChild(light_img)
				table.insert(self.autoLight_List,light_img)
			end
		else
			for i=1,#self.autoLight_List do
				self.autoLight_List[i]:setVisible(true)
			end
		end
		if isbreath then
			for i=1,#self.autoLight_List do
				self.autoLight_List[i]:setVisible(true)
				self.autoLight_List[i]:runAction(cc.RepeatForever:create(cc.Sequence:create({
					cc.FadeTo:create(1,100),
					cc.FadeIn:create(1)
				})))
			end
		end
	else
		for i=1,#self.autoLight_List do
			self.autoLight_List[i]:setVisible(false)
			self.autoLight_List[i]:stopAllActions()
		end
	end
end
function HaoChePiaoYiSceneUIPanel:getStartPoint()
	local startPoint = cc.p(0,0)
	if math.random(1,100)%2 == 0 then
		--上下出筹码
		startPoint.x = math.random(0,D_SIZE.width)
		if math.random(1,100)%2 == 0 then	
			--上
			startPoint.y = D_SIZE.height + 50 + math.random(0,100)
		else
			--下
			startPoint.y = -50 - math.random(0,100)
		end	
	else
		--左右出筹码
		startPoint.y = math.random(-50,D_SIZE.width + 50)
		if math.random(1,100)%2 == 0 then	
			--左
			startPoint.x = -50 - math.random(0,100)
		else
			--右
			startPoint.x = D_SIZE.width + 50 + math.random(0,100)
		end	
	end
	return startPoint
end
function HaoChePiaoYiSceneUIPanel:addBet(value,sid,startPoint,delay)
	self.soundController:playScoreSound()
	startPoint = startPoint or self:getStartPoint()
	local betsp = display.newSprite(string.format("sglb2_bet_%s.png",value))
	betsp:setScale(0.5)
	betsp:setPosition(startPoint)
	betsp:setAnchorPoint(cc.p(0,0))
	betsp:setOpacity(120)
	local bet_size = betsp:getContentSize()
	self.main_layout:addChild(betsp)
	local multiple_rect = bet_region_rects[sid]
	local multiple_positon = cc.p(multiple_rect.x,multiple_rect.y)
	local movex = Command.random(multiple_rect.width - bet_size.width)
	local movey = Command.random(multiple_rect.height - bet_size.height)
	local sequence = {}
	if delay then
		table.insert(sequence,cc.DelayTime:create(delay))
	end
	table.insert(sequence,cc.FadeIn:create(0.3))
	table.insert(sequence,cc.EaseExponentialOut:create(cc.MoveTo:create(0.3,cc.p(multiple_positon.x + movex + bet_size.width/2,multiple_positon.y + movey + bet_size.height/2))))
	table.insert(sequence,		cc.CallFunc:create(function(sender)
			if #self.betItem_array < 150 then
				table.insert(self.betItem_array,betsp)
			else
				sender:removeFromParent(true)
			end
		end))
	betsp:runAction(cc.Sequence:create(sequence))

	-- betsp:runAction(cc.Sequence:create({
	-- 	cc.FadeIn:create(0.3),
	-- 	cc.EaseExponentialOut:create(cc.MoveTo:create(0.3,cc.p(multiple_positon.x + movex + bet_size.width/2,multiple_positon.y + movey + bet_size.height/2))),
	-- 	cc.CallFunc:create(function(sender)
	-- 		if #self.betItem_array < 80 then
	-- 			table.insert(self.betItem_array,betsp)
	-- 		else
	-- 			sender:removeFromParent(true)
	-- 		end
	-- 	end)
	-- }))
end
function HaoChePiaoYiSceneUIPanel:removeScoreItem()
	for i=1,#self.scoreItemList do
		self.scoreItemList[i]:removeFromParent(true)
	end
	self.scoreItemList = {}
end
function HaoChePiaoYiSceneUIPanel:updateZhuang(name,value)
	self.zhuangname_label:setString(name)
	self.zhuang_jinbi_label:setFormatNumber(value)
end
function HaoChePiaoYiSceneUIPanel:updateAllBetValue(value)
	self.zxz_label:setString(value)
end
function HaoChePiaoYiSceneUIPanel:updateSQRS(value)
	self.szsqrs_label:setString(value)
end
function HaoChePiaoYiSceneUIPanel:getBetPointByValue(value)
	local config = {10,1000,10000,100000,1000000,5000000}
	for i=1,#config do
		if config[i] == value then
			return self.betPoint_array[i]
		end
	end
end
function HaoChePiaoYiSceneUIPanel:removeClock()
	if self.clock_item then
		self.clock_item:removeFromParent(true)
		self.clock_item = nil
	end
end
function HaoChePiaoYiSceneUIPanel:showWait()
	local mask = display.newMask()
	self.main_layout:addChild(mask,3)
	local tip_image = display.newImage("fcpy_icon_50.png")
	Coord.ingap(mask,tip_image,"CC",0,"CC",200)
	mask:addChild(tip_image)
	self.waitMask = mask
end
function HaoChePiaoYiSceneUIPanel:removeWait()
	if self.waitMask then
		self.waitMask:removeFromParent(true)
		self.waitMask = nil
	end
end
function HaoChePiaoYiSceneUIPanel:updateShangZhuangState()
	if self.sz_btn.state == self.dataController.is_banker then return end
	self.sz_btn.state = self.dataController.is_banker
	if self.sz_btn.state then
		self.sz_btn:loadTextures("fcpy_btn_10.png","fcpy_btn_11.png",nil,1)
	else
		self.sz_btn:loadTextures("fcpy_btn_14.png","fcpy_btn_15.png",nil,1)
	end
end
function HaoChePiaoYiSceneUIPanel:checkContinueState()
	if self.dataController.state ~= 1 then
		self.continue_btn:setDisable(true)
	else
		self.continue_btn:setDisable(not self.dataController:enbaleContinueBet())
	end
end

function HaoChePiaoYiSceneUIPanel:playSpeedSound(speed)
	if speed <= 2 then
		if self.turn_action_handler then return end
		self.turn_action_handler = self.main_layout:schedule(function()
			SoundsManager.playSound("fcpy_turn")
		end,0.05)
	else
		if self.turn_action_handler then
			self.main_layout:stopAction(self.turn_action_handler)
			self.turn_action_handler = nil
		end
		SoundsManager.playSound("fcpy_turn")
	end
end

return HaoChePiaoYiSceneUIPanel
