--[[
 *	飞禽走兽UI
 *	@author gwj
]]
local FeiQingZouShouUIPanel = class("FeiQingZouShouUIPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"),IEventListener)

local BET_RECT = {
	[1] = {rect = cc.rect(246,198,124,150),img_position = cc.p(0,30),location = 1},
	[2] = {rect = cc.rect(246,350,124,150),img_position = cc.p(0,0),location = 0},
	[3] = {rect = cc.rect(376,350,124,150),img_position = cc.p(0,0),location = 0},
	[4] = {rect = cc.rect(376,198,124,150),img_position = cc.p(0,30),location = 1},
	[5] = {rect = cc.rect(764,198,124,150),img_position = cc.p(0,30),location = 1},	--兔子
	[6] = {rect = cc.rect(764,350,124,150),img_position = cc.p(0,0),location = 0},	--熊猫
	[7] = {rect = cc.rect(894,350,124,150),img_position = cc.p(0,0),location = 0},	--猴子
	[8] = {rect = cc.rect(894,198,124,150),img_position = cc.p(0,30),location = 1},	--狮子
	[9] = {rect = cc.rect(569,198,258,150),img_position = cc.p(4,30),location = 1},	--鲨鱼
	[10] = {rect = cc.rect(506,350,124,150),img_position = cc.p(0,0),location = 0},	--飞禽
	[11] = {rect = cc.rect(634,350,124,150),img_position = cc.p(0,0),location = 0},	--走兽
}
local ELEMENT_CONFIG = {
	{2,2,2,9,3,3,3},
	{1,1,1,10,5,5,5},
	{7,7,7,9,6,6,6},
	{8,8,8,10,4,4,4}
}

function FeiQingZouShouUIPanel:ctor(room)
	self.room = room
	self.isReadState = false	--是否在本地状态
	self.dropItemList = {}	 --右边显示项集合
	self.gameItemList = {}	 --游戏项集合
	self.multipleList = {}   --倍数项集合
	self.multipleFontList = {}	--倍数文本集合
	self.scoreItemList = {}	  --得分项集合
	self.betPoint_array = {}	 --筹码的坐标
	self.betItem_array = {}	 --筹码的集合
	self.isStart = false	 --是否开始
	self.nowTime = 0         --当前计时器
	self.speed = 20          --闪动的速度
	self.runTime = 0         --闪动的时间
	self.overTime = 0        --闪动结束的时间
	self.blinkIndex = 0	     --当前闪
	self.resultIndex = 0    --结果索引
	self.slowIndex = 0 		 --减速的步数
	self.isClimb = false     --是否龟速
	self.soundController = require("src.games.feiqingzoushou.data.FeiQingZouShouSoundController").getInstance()
	self.dataController = require("src.games.feiqingzoushou.data.FeiQingZouShouDataController").getInstance()
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_GAMEFQZS_INITWAIT)
	self:addEvent(ST.COMMAND_GAMEFQZS_BETBEGIN)
	self:addEvent(ST.COMMAND_GAMEFQZS_BETEND)
	self:addEvent(ST.COMMAND_GAMEFQZS_BETCHANGE)
	self:addEvent(ST.COMMAND_GAMEFQZS_UPDATEDROP)
	self:addEvent(ST.COMMAND_GAMEFQZS_UPDATEBANKER)
	self:addEvent(ST.COMMAND_GAMEFQZS_UPDATEAPPLY)
	self:addEvent(ST.COMMAND_GAMEFQZS_UPBANKERSTATE)
	self:addEvent(ST.COMMAND_PLAYER_BANK_GOLD_UPDATE)
	local main_layout = display.newImage("#game/feiqingzoushou/fqzs-fly-main-background.png")
	display.extend("CCNodeExtend",main_layout)
	main_layout:setAnchorPoint(cc.p(0,0))
	self:addChild(main_layout)
	self.main_layout = main_layout

	--内容
	local content_layout = display.newImage("#game/feiqingzoushou/fqzs-fly-main-backdrop.png")
	content_layout:setAnchorPoint(cc.p(0,0))
	local content_size = content_layout:getContentSize()
	content_layout:setPosition(cc.p((D_SIZE.width - content_size.width)/2,(D_SIZE.height - content_size.height)/2 + 40))
	self.main_layout:addChild(content_layout,0)
	self.content_layout = content_layout
	--中间上面的菜单
	local middle_menu_layout = display.newImage("fqzs-fly-info-bg.png")
	self.content_layout:addChild(middle_menu_layout)
	Coord.ingap(content_layout,middle_menu_layout,"CC",0,"TT",-110)
	--上庄按钮
	local sz_btn = display.newButton("fqzs_btn_1.png",nil,nil)
	sz_btn:setPosition(cc.p(85,73))
	sz_btn.state = false
	middle_menu_layout:addChild(sz_btn)
	sz_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
	    	if not sender.state then
    			if not display.checkGold(100000000) then
	    			return
	    		end
	    		ConnectMgr.connect("src.games.feiqingzoushou.content.FeiQingZouShouBecomeBankerConnect",function(result)
	    			if result then
	    				display.showMsg(display.trans("##20018"))
	    				self.dataController:setIsbanker(true)
	    			end
	    		end)
	    	else
	    		ConnectMgr.connect("src.games.feiqingzoushou.content.FeiQingZouShouOutGoBankerConnect",function(result)
	    			if result then
	    				display.showMsg(display.trans("##20019"))
	    				self.dataController:setIsbanker(false)
	    			end
	    		end)
	    	end
	    end)
	self.sz_btn = sz_btn

	self.sz_btn:setVisible(false)

	local szsqrs_label = display.newText(display.trans("##20020"),20,Color.GWJ_III)
	middle_menu_layout:addChild(szsqrs_label)
	Coord.outgap(sz_btn,szsqrs_label,"CC",0,"BT",-2)
	self.szsqrs_label = szsqrs_label
	self.szsqrs_label:setVisible(false)
	--总下注
	local zxz_label =  display.newText("",30,Color.GWJ_IIII)
	middle_menu_layout:addChild(zxz_label)
	zxz_label:setPosition(cc.p(355,80))
	self.zxz_label = zxz_label
	local sz_label =  display.newText(display.trans("##20021"),20,Color.GWJ_III)
	middle_menu_layout:addChild(sz_label)
	Coord.outgap(zxz_label,sz_label,"CC",0,"BT",-25)
	sz_label:setVisible(false)

	--庄
	local zhuang_icon = display.newImage("fqzs_icon_1.png")
	zhuang_icon:setPosition(cc.p(572,83))
	middle_menu_layout:addChild(zhuang_icon)
	local zhuangname_label = display.newText("",20,Color.GWJ_IIII)
	middle_menu_layout:addChild(zhuangname_label)
	zhuangname_label:setAnchorPoint(cc.p(0,0.5))
	zhuangname_label:setPosition(cc.p(605,83))
	self.zhuangname_label = zhuangname_label
	--金币图标
	local jinbi_icon = display.newImage("fqzs_icon_2.png")
	jinbi_icon:setPosition(cc.p(572,29))
	middle_menu_layout:addChild(jinbi_icon)
	local jinbi_label = display.newNumberText(Player.gold,20,Color.GWJ_IIII)
	middle_menu_layout:addChild(jinbi_label)
	jinbi_label:setAnchorPoint(cc.p(0,0.5))
	jinbi_label:setPosition(cc.p(605,29))
	self.zhuang_jinbi_label = jinbi_label
	local MultipleImage = require("src.games.feiqingzoushou.ui.MultipleImage")
	local MultipleFontLayout = require("src.games.feiqingzoushou.ui.MultipleFontLayout")
	--创建下注按钮
	for i=1,#BET_RECT do
		local config = BET_RECT[i]
		local item = MultipleImage.new(i,cc.size(config.rect.width,config.rect.height),config.img_position)
		item.sid = i
		item:setPosition(cc.p(config.rect.x,config.rect.y))
		self.content_layout:addChild(item)
		item:setTouchEnabled(true)
		item:addTouchEventListener(function(sender,eventype)
		    if eventype ~= ccui.TouchEventType.ended then return end
		    if self.dataController.state ~= 1 then
		    	display.showMsg(display.trans("##20022"))
		    	return
		    end
		    if not self.m_currentBetBtn then
		    	display.showMsg(display.trans("##20023"))
		    	return 
		    end
		    ConnectMgr.connect("src.games.feiqingzoushou.content.FeiQingZouShouGetBetConnect",self.m_currentBetBtn.betvalue,sender.sid,
			    function(result)
			    	if result then
			    		self.self_isBet = true
			    		if self.m_currentBetBtn then
					    	local current_Position = cc.p(self.m_currentBetBtn:getPositionX(),self.m_currentBetBtn:getPositionY())
					    	self:addBet(self.m_currentBetBtn.betvalue,sender.sid,current_Position)
					    	self.multipleFontList[sender.sid]:addSelfValue(self.m_currentBetBtn.betvalue)
					    	self.multipleFontList[sender.sid]:addTotalValue(self.m_currentBetBtn.betvalue)
					    	self.dataController:addBet(self.m_currentBetBtn.betvalue,sender.sid)
					    	self.jb_value_label:setFormatNumber(Player.gold)
					    	self:checkDisable()
					    end
			    	end
			    end)
	    end)
	    table.insert(self.multipleList,item)

	    local bet_size = cc.size(config.rect.width,config.rect.height)
	    local bet_AnchorPoint = item:getAnchorPoint()
	    local bet_ps = cc.p(item:getPositionX() - bet_size.width * bet_AnchorPoint.x,item:getPositionY() - bet_size.height * bet_AnchorPoint.y)
	    local font_item = MultipleFontLayout.new(i,bet_size,config.location)
	    local world_Ps = item:getParent():convertToWorldSpace(bet_ps)
	    world_Ps = cc.p(world_Ps.x,world_Ps.y)
	    font_item:setPosition(world_Ps)
	    self.main_layout:addChild(font_item,1)
	    table.insert(self.multipleFontList,font_item)
	end
	--右边
	local backdrop_layout = display.newImage("fqzs-fly-main-history-backdrop.png")
	self.main_layout:addChild(backdrop_layout)
	Coord.ingap(self.main_layout,backdrop_layout,"RR",-25,"CC",0)
	self.backdrop_layout = backdrop_layout
	self:initDropItem()
	--右边的遮罩
	local backdrop_mask = display.newImage("fqzs-fly-main-history-backdrop-veil.png")
	self.main_layout:addChild(backdrop_mask)
	backdrop_mask:setPosition(cc.p(backdrop_layout:getPositionX(),backdrop_layout:getPositionY() + 118))
	--规则按钮
	local rule_btn = display.newButton("fqzs_btn_2.png")
	Coord.ingap(self.main_layout,rule_btn,"RR",-5,"TT",-5)
	self.main_layout:addChild(rule_btn)
	rule_btn:addTouchEventListener(function(sender,eventype)
		    if eventype == ccui.TouchEventType.ended then
		    	require("src.games.feiqingzoushou.ui.FeiQingZouShouRulePanel").show()
	        end
	    end)
	--底部
	local bottom_layout = display.newImage("fqzs-fly-main-bottom-box.png")
	self.main_layout:addChild(bottom_layout,1)
	Coord.ingap(self.main_layout,bottom_layout,"CC",0,"BB",0)
	self.bottom_layout = bottom_layout
	require("src.command.NumberFly").extend(self.bottom_layout)
	--庄闲
	local zx_icon_img = display.newImage("fqzs_icon_3.png")
	Coord.ingap(self.bottom_layout,zx_icon_img,"LL",5,"BB",50)
	self.bottom_layout:addChild(zx_icon_img)
	self.zx_icon_img = zx_icon_img
	local zx_name_label = display.newText(Player.name,24)
	zx_name_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(zx_icon_img,zx_name_label,"RL",10,"CC",0)
	self.bottom_layout:addChild(zx_name_label)
	--vip
	local vip_icon = display.newImage("fqzs_icon_5.png")
	self.bottom_layout:addChild(vip_icon)
	Coord.ingap(self.bottom_layout,vip_icon,"LL",275,"BB",55)
	local vip_label = ccui.TextAtlas:create(Player.level,"game/feiqingzoushou/fqzs_vip_142_21.png",14.2,21,0)
    self.bottom_layout:addChild(vip_label)
    Coord.outgap(vip_icon,vip_label,"RL",2,"CC",0)
	--金币
	local jb_icon_img = display.newImage("fqzs_icon_2.png")
	Coord.ingap(self.bottom_layout,jb_icon_img,"LL",5,"BB",5)
	self.bottom_layout:addChild(jb_icon_img)
	local jb_value_label = display.newNumberText(Player.gold,24,Color.GWJ_IIII)
	jb_value_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(jb_icon_img,jb_value_label,"RL",10,"CC",0)
	self.bottom_layout:addChild(jb_value_label)
	self.jb_value_label = jb_value_label
	--银行
	local bank_btn = require("src.ui.item.ExButton").new("fqzs_btn_3_normal.png",nil,"fqzs_btn_3_disable.png")
	bank_btn:setPosition(cc.p(420,33))
	self.bottom_layout:addChild(bank_btn)
	bank_btn:addTouchEventListener(function(sender,eventype)
		    if eventype ~= ccui.TouchEventType.ended then
		    	display.showWindow("src.ui.window.bank.BankWindows")
	        end
	    end)
	self.bank_btn = bank_btn
	--续投按钮
	local continue_btn = require("src.ui.item.ExButton").new("fqzs_btn_4_normal.png",nil,"fqzs_btn_4_disable.png")
	self.bottom_layout:addChild(continue_btn)
	Coord.ingap(self.bottom_layout,continue_btn,"RR",-5,"BB",5)
	continue_btn:addTouchEventListener(function(sender,eventype)
		    if eventype ~= ccui.TouchEventType.ended then
		    	if self.dataController.state ~= 1 then
			    	display.showMsg(display.trans("##20022"))
			    	return
			    end
		    	ConnectMgr.connect("src.games.feiqingzoushou.content.FeiQingZouShouGetBetAgainConnect",self.dataController.againData,function(result)
		    		if result then
		    			self.self_isBet = true
		    			self.continue_btn:setDisable(true)
		    			for i=1,#self.dataController.againData do
		    				local data = self.dataController.againData[i]
		    				local multipleItem = self:getMultipleItemBySid(data.multiplesSid)
		    				self:addBet(data.money,data.multiplesSid,self:getBetPointByValue(data.money))
		    				self.multipleFontList[data.multiplesSid]:addSelfValue(data.money)
		    				self.multipleFontList[data.multiplesSid]:addTotalValue(data.money)
		    			end
		    			self.dataController:betAgain()
		    			self.jb_value_label:setFormatNumber(Player.gold)
		    			self:checkDisable()
		    		end
		    	end)
	        end
	    end)
	self.continue_btn = continue_btn
	self.continue_btn:setDisable(true)
	self:initBetMenus()
	self:initelement()
	self:scheduleUpdateWithPriorityLua(function()
		self:turnAction()
	end,0.01)
end

--@override
function FeiQingZouShouUIPanel:handlerEvent(event,arg)
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		if self.isReadState then return end
		self.jb_value_label:setFormatNumber(Player.gold)
		self:checkDisable()
	elseif event == ST.COMMAND_PLAYER_BANK_GOLD_UPDATE then
		self.jb_value_label:setFormatNumber(Player.gold)
		self:checkDisable()
	elseif event == ST.COMMAND_GAMEFQZS_UPDATEDROP then
		self:updateDropItem()
	elseif event == ST.COMMAND_GAMEFQZS_BETBEGIN then
		if self.dataController.term_count >= 2 then
			display.showMsg(display.newRichText(display.trans("##11002",self.dataController.term_count)))
		end
		self:playReady()
		print("开始准备···························")
	elseif event == ST.COMMAND_GAMEFQZS_BETEND then
		require("src.games.feiqingzoushou.ui.FeiQingZouShouBeautyPanel").show(2)
		Command.performWithDelay(self.main_layout,function()
			self:playGame(self.dataController.winSid)
		end,1)
		print("游戏开始···························")
	elseif event == ST.COMMAND_GAMEFQZS_BETCHANGE then
		local bet_users = arg
		for i=1,#bet_users do
			local bet = bet_users[i]
			local random_delay = math.random(1,8)
			self:addBet(bet.money,bet.multipleSid,self:getStartPoint(),random_delay/10)
		end
		print("下注了···························")
		Command.performWithDelay(self.main_layout,function()
			for i=1,#self.dataController.bets_array do
				local data = self.dataController.bets_array[i]
				-- self.multipleList[i]:setTotalValue(self.dataController.bets_array[i])
				self.multipleFontList[i]:setTotalValue(self.dataController.bets_array[i])
			end
			self:updateAllBetValue(self.dataController.allbetValue)
		end,0.3)
	elseif event == ST.COMMAND_GAMEFQZS_INITWAIT then
		self:showWait()
	elseif event == ST.COMMAND_GAMEFQZS_UPDATEBANKER then
		if arg then
			display.showMsg(display.trans("##4011"))
		end
		if self.dataController:playerIsBanker() then
			self.zx_icon_img:loadTexture("fqzs_icon_4.png",1)
		else
			self.zx_icon_img:loadTexture("fqzs_icon_3.png",1)
		end
		self.zhuangname_label:setString(self.dataController.banker_name)
		self.zhuang_jinbi_label:setFormatNumber(self.dataController.banker_money)
	elseif event == ST.COMMAND_GAMEFQZS_UPDATEAPPLY then
		self.szsqrs_label:setString(display.trans("##20024")..self.dataController.apply_number)
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		display.enterScene("src.ui.ReloginScene",{self.room})
	elseif event == ST.COMMAND_GAMEFQZS_UPBANKERSTATE then
		self:updateShangZhuangState()
	end
end
function FeiQingZouShouUIPanel:turnAction()
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
		self.gameItemList[self.blinkIndex]:blink()
		self:playSpeedSound(self.speed)
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
function FeiQingZouShouUIPanel:getDistanceIndex(index,distance)
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
function FeiQingZouShouUIPanel:initelement()
	local GameImage = require("src.games.feiqingzoushou.ui.GameImage")
	local size = self.content_layout:getContentSize()
	--第一列
	local config = ELEMENT_CONFIG[1]
	for i=1,#config do
		local sid = config[i]
		local item = GameImage.new(sid)
		item:setPosition(cc.p(64 + 13,47 + 90*(i-1) + 10))
		self.content_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
	config = ELEMENT_CONFIG[2]
	for i=1,#config do
		local sid = config[i]
		local item = GameImage.new(sid)
		item:setPosition(cc.p(64 + 13.5 + i*123.5,size.height - 13 - 47))
		self.content_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
	config = ELEMENT_CONFIG[3]
	for i=1,#config do
		local sid = config[i]
		local item = GameImage.new(sid)
		item:setPosition(cc.p(size.width - 13 - 64,size.height - 10 - 47 - 90*(i-1)))
		self.content_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
	config = ELEMENT_CONFIG[4]
	for i=1,#config do
		local sid = config[i]
		local item = GameImage.new(sid)
		item:setPosition(cc.p(size.width - 64 - 13.5 - i*123.5,10 + 47))
		self.content_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
end
function FeiQingZouShouUIPanel:initBetMenus()
	local config = {10,1000,10000,100000,1000000,5000000}
	local btnflow = display.newImage("fqzs_ui_1021.png")
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
		btn = require("src.games.feiqingzoushou.ui.BetButton").new(config[i])
		buttonMgr:addButton(btn)
		if not temp then
			self.bottom_layout:addChild(Coord.ingap(self.bottom_layout,btn,"CC",-120,"BB",0))
		else
			self.bottom_layout:addChild(Coord.outgap(temp,btn,"RL",50,"CC",0))
		end
		temp = btn
		table.insert(self.betPoint_array,cc.p(btn:getPositionX(),btn:getPositionY()))
	end
	local flow_rect_img = display.newImage("fqzs-fly-main-button-box-xin.png")
	Coord.ingap(self.bottom_layout,flow_rect_img,"CC",188,"BB",0)
	self.bottom_layout:addChild(flow_rect_img)
end



function FeiQingZouShouUIPanel:checkDisable()
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
function FeiQingZouShouUIPanel:disableAllBet()
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



function FeiQingZouShouUIPanel:initDropItem()
	local beginPoint = self.backdrop_layout:getContentSize().height
	for i=1,9 do
		local animal_item = display.newLayout(cc.size(70,70))
		local icon = display.newImage()
		icon:setScale(0.5)
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
function FeiQingZouShouUIPanel:updateDropItem()
	for i=1,#self.dataController.dropDatas do
		local item = self.dropItemList[i]
		item.icon:loadTexture("fqzs-fly-icon-"..self.dataController.dropDatas[i]..".png",1)
		if i == #self.dataController.dropDatas then
			if item.rect then
				item.rect:setVisible(true)
			else
				local rect =display.newImage("fqzs-fly-main-icon-new.png")
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
function FeiQingZouShouUIPanel:playGame(animalSid)
	if self.clock_item and self.clock_item:getSurplusTime() > 2 then
		self:removeClock()
		display.showMsg(display.trans("##20025"))
	end
	self:removeScoreItem()
	self:disableAllBet()
	SoundsManager.stopAllMusic()
	self.nowTime = 0
	self.overTime = 0
	local index_array = {}
	for i=1,#self.gameItemList do
		if self.gameItemList[i]:getData().sid == animalSid then
			table.insert(index_array,i)
		end
	end
	self.resultIndex = index_array[Command.random(#index_array)]
	-- self.resultIndex = Command.random(28)
	self.speed = 20
	self.runTime = 0 
	self.isClimb = false
	self.slowIndex = self:getDistanceIndex(self.resultIndex,12)
	print("self.slowIndex------------"..self.slowIndex)
	print("self.resultIndex------------"..self.resultIndex)
	self.isStart = true
end
function FeiQingZouShouUIPanel:gameOver()
	self.isStart = false
	self.main_layout:runAction(cc.Sequence:create({
	    cc.DelayTime:create(1),
	    cc.CallFunc:create(function()
	        local data = self.gameItemList[self.resultIndex]:getData()
	        print("self.resultData------------"..data.sid)
			if data.belong > 0 then
				self.multipleList[data.belong]:blink()
			end
			self.multipleList[data:getMutipleSid()]:blink()
			self.dataController:addDrop(data.sid)
			require("src.games.feiqingzoushou.ui.FeiQingZouShouResultPanel").show(self.self_isBet,data.sid,self.dataController.bankerResultMoney,self.zhuangname_label:getString(),self.dataController.self_winMoney,self.dataController.userdatas,
				function()
					if self.dataController.self_winMoney > 0 then
						self:playAddScore(self.dataController.self_winMoney)
					else
						self.jb_value_label:setFormatNumber(Player.gold)
					end
				end)
	    end)}))
end
--准备阶段
function FeiQingZouShouUIPanel:playReady()
	if self.dataController:playerIsBanker() then
		self:disableAllBet()
	else
		self:checkDisable()
		self:checkContinueState()
	end	
	self.isReadState = true
	self:removeWait()
	self:removeMultipleBlink()
	self.bank_btn:setDisable(false)
	self.soundController:roundOver()
	SoundsManager.playMusic("fqzs_bg",true)
	self.self_isBet = false
	for i=1,#self.betItem_array do
		self.betItem_array[i]:removeFromParent(true)
	end
	self.betItem_array = {}
	for i=1,#self.multipleFontList do
		self.multipleFontList[i]:cleanValue()
	end
	require("src.games.feiqingzoushou.ui.FeiQingZouShouBeautyPanel").show(1)
	local time_Surplus = self.dataController:getTime()
	if time_Surplus > 2 then
		local clock_item = require("src.games.feiqingzoushou.ui.ClockCountDownItem").new(self.dataController:getTime(),true,function()
			self.clock_item = nil
		end)
		self.clock_item = clock_item
		self.main_layout:addChild(clock_item,2)
		Coord.ingap(self.main_layout,clock_item,"CC",380,"CC",180)
	end
end
function FeiQingZouShouUIPanel:getStartPoint()
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
function FeiQingZouShouUIPanel:addBet(value,sid,startPoint,delay)
	self.soundController:playScoreSound()
	startPoint = startPoint or self:getStartPoint()
	local betsp = display.newSprite(string.format("cm_bet_%s.png",value))
	betsp:setScale(0.5)
	betsp:setPosition(startPoint)
	betsp:setAnchorPoint(cc.p(0,0))
	betsp:setOpacity(120)
	self.main_layout:addChild(betsp)
	local bet_size = betsp:getContentSize()
	local multiple_item = self.multipleList[sid]
	local multiple_positon = multiple_item:convertToWorldSpace(cc.p(multiple_item:getBetImage():getPositionX(),multiple_item:getBetImage():getPositionY()))
	local multiple_size = multiple_item:getBetImage():getContentSize()
	-- local temp_layout = display.newLayout(multiple_size)
	-- display.debugLayout(temp_layout)
	-- temp_layout:setPosition(multiple_positon)
	-- self.main_layout:addChild(temp_layout)
	local movex = Command.random(multiple_size.width - bet_size.width)
	local movey = Command.random(multiple_size.height - bet_size.height)
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
	-- 		if #self.betItem_array < 150 then
	-- 			table.insert(self.betItem_array,betsp)
	-- 		else
	-- 			sender:removeFromParent(true)
	-- 		end
	-- 	end)
	-- }))
end

function FeiQingZouShouUIPanel:showShadow()
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
function FeiQingZouShouUIPanel:removeShadow()
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
function FeiQingZouShouUIPanel:removeMultipleBlink()
	for i=1,#self.multipleList do
		self.multipleList[i]:disappear()
	end
end
function FeiQingZouShouUIPanel:removeScoreItem()
	for i=1,#self.scoreItemList do
		self.scoreItemList[i]:removeFromParent(true)
	end
	self.scoreItemList = {}
end
function FeiQingZouShouUIPanel:updateZhuang(name,value)
	self.zhuangname_label:setString(name)
	self.zhuang_jinbi_label:setFormatNumber(value)
end
function FeiQingZouShouUIPanel:updateAllBetValue(value)
	self.zxz_label:setString(display.trans("##20026")..value)
end
function FeiQingZouShouUIPanel:updateSQRS(value)
	self.szsqrs_label:setString(value)
end
function FeiQingZouShouUIPanel:getBetPointByValue(value)
	local config = {100,1000,10000,100000,1000000,5000000}
	for i=1,#config do
		if config[i] == value then
			return self.betPoint_array[i]
		end
	end
end

function FeiQingZouShouUIPanel:getMultipleItemBySid(sid)
	for i=1,#self.multipleList do
		if self.multipleList[i].sid == sid then
			return self.multipleList[i]
		end
	end
end

function FeiQingZouShouUIPanel:removeClock()
	if self.clock_item then
		self.clock_item:removeFromParent(true)
		self.clock_item = nil
	end
end

function FeiQingZouShouUIPanel:showWait()
	local mask = display.newMask()
	self.main_layout:addChild(mask,3)

	local tip_image = display.newImage("fqzs_icon_14.png")
	Coord.ingap(mask,tip_image,"CC",0,"CC",200)
	mask:addChild(tip_image)

	self.waitMask = mask
end

function FeiQingZouShouUIPanel:removeWait()
	if self.waitMask then
		self.waitMask:removeFromParent(true)
		self.waitMask = nil
	end
end

function FeiQingZouShouUIPanel:updateShangZhuangState()
	if self.sz_btn.state == self.dataController.is_banker then return end
	self.sz_btn.state = self.dataController.is_banker
	if self.sz_btn.state then
		self.sz_btn:loadTextureNormal("fqzs_btn_5_normal.png",1)
	else
		self.sz_btn:loadTextureNormal("fqzs_btn_1.png",1)
	end
end

function FeiQingZouShouUIPanel:checkContinueState()
	if self.dataController.state ~= 1 then
		self.continue_btn:setDisable(true)
	else
		self.continue_btn:setDisable(not self.dataController:enbaleContinueBet())
	end
end

function FeiQingZouShouUIPanel:playSpeedSound(speed)
	if speed <= 2 then
		if self.turn_action_handler then return end
		self.turn_action_handler = self.main_layout:schedule(function()
			SoundsManager.playSound("fqzs_turn")
		end,0.05)
	else
		if self.turn_action_handler then
			self.main_layout:stopAction(self.turn_action_handler)
			self.turn_action_handler = nil
		end
		SoundsManager.playSound("fqzs_turn")
	end
end

function FeiQingZouShouUIPanel:playAddScore(value)
	local blink_image = display.newImage("fqzs_icon_15.png")
	blink_image:setScaleX(1.3)
	blink_image:setOpacity(0)
	blink_image:setPosition(cc.p(175,25))
	self.bottom_layout:addChild(blink_image)
	blink_image:runAction(cc.Sequence:create({
			cc.FadeIn:create(0.5),
            cc.FadeOut:create(0.5),
            cc.CallFunc:create(function(sender)
            	self.bottom_layout:showFlyNumber(value,cc.p(200,25),Color.GREEN,24)
            	self.jb_value_label:setNumer(Player.gold,10,0.1)
                sender:removeFromParent(true)
            end)}))

	-- self.bottom_layout
end

function FeiQingZouShouUIPanel:onCleanup()
	self:removeClock()
	self.soundController:roundOver()
	self:removeAllEvent()
end

return FeiQingZouShouUIPanel
