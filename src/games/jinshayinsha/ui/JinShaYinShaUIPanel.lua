--[[
 *	金沙银沙UI
 *	@author gwj
]]
local JinShaYinShaUIPanel = class("JinShaYinShaUIPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"),IEventListener)

local ELEMENT_CONFIG = {
	{9,3,3,10,2,2,9},
	{4,4,4,10,8,8,8},
	{9,6,6,10,7,7,9},
	{5,5,5,10,1,1,1}
}
local ELEMENT_RECT = {
1,1,1,3,1,1,1,
1,1,1,3,2,2,2,
2,2,2,3,2,2,2,
2,2,2,3,1,1,1}
local BET_RECT = {1,3,11,12,7,5,2,4,10,9,8,6}
function JinShaYinShaUIPanel:ctor(room)
	self.isReadState = false	--是否在本地状态
	self.gameItemList = {}	 --游戏项集合
	self.multipleList = {}   --倍数项集合
	self.dropItemList = {}	 --右边显示项集合
	self.betPoint_array = {}	--筹码坐标集合
	self.betItem_array = {}		--筹码的集合
	self.isStart = false	 --是否开始
	self.nowTime = 0         --当前计时器
	self.speed = 20          --闪动的速度
	self.runTime = 0         --闪动的时间
	self.overTime = 0        --闪动结束的时间
	self.blinkIndex = 1	     --当前闪
	self.resultIndex = 0    --结果索引
	self.slowIndex = 0 		 --减速的步数
	self.lastStep = {}        --上一个显示的步数
	self.isClimb = false     --是否龟速
	self.isFirst = true		--是否第一次进游戏
	self.isFree = false		--是否进入免费模式
	self.room = room
	self.dataController = require("src.games.jinshayinsha.data.JinShaYinShaDataController").getInstance()

	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_GAMEJSYS_UPDATEDROP)
	self:addEvent(ST.COMMAND_GAMEJSYS_BETBEGIN)
	self:addEvent(ST.COMMAND_GAMEJSYS_BETEND)
	self:addEvent(ST.COMMAND_GAMEJSYS_BETCHANGE)
	self:addEvent(ST.COMMAND_GAMEJSYS_INITWAIT)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self:addEvent(ST.COMMAND_PLAYER_BANK_GOLD_UPDATE)
	local main_layout = display.newImage("#game/jinshayinsha/jsys_main_bg.jpg")
	main_layout:setAnchorPoint(cc.p(0,0))
	self:addChild(main_layout)
	self.main_layout = main_layout

	local multiple_image = display.newImage("jsys_panel_1.png")		--倍数背景
	display.setS9(multiple_image,cc.rect(10,10,10,10),cc.size(760,300))
	multiple_image:setPosition(cc.p(674,351))
	self.main_layout:addChild(multiple_image)
	self.multiple_layout = multiple_image
	local multiple_value_image = display.newImage("jsys_icon_4.png")
	multiple_value_image:setPosition(cc.p(633,580))
	self.main_layout:addChild(multiple_value_image)
	multiple_value_image:setVisible(false)
	self.multiple_value_image = multiple_value_image
	local multiple_value_label = ccui.TextAtlas:create("","game/jinshayinsha/jsys_number_6.png",42,56,0)
	multiple_value_label:setAnchorPoint(cc.p(0,0.5))
	multiple_value_label:setPosition(cc.p(665,580))
	self.main_layout:addChild(multiple_value_label)
	multiple_value_label:setVisible(false)
	self.multiple_value_label = multiple_value_label
	

	-- local content_img = display.newImage("#game/jinshayinsha/jsys_rule_1.png")


	local winmoney_font_img = display.newImage("jsys_font_1.png")
	winmoney_font_img:setPosition(cc.p(639,526))
	self.main_layout:addChild(winmoney_font_img)
	winmoney_font_img:setVisible(false)
	self.winmoney_font_img = winmoney_font_img
	local winmoney_value_label = ccui.TextAtlas:create("","game/jinshayinsha/jsys_number_3.png",18,26,0)
	winmoney_value_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(winmoney_font_img,winmoney_value_label,"RL",5,"CC",0)
	winmoney_value_label:setVisible(false)
	self.main_layout:addChild(winmoney_value_label)
	self.winmoney_value_label = winmoney_value_label
	--右边
	local backdrop_layout = display.newImage("jsys_panel_3.png")
	self.main_layout:addChild(backdrop_layout)
	Coord.ingap(self.main_layout,backdrop_layout,"RR",-60,"CC",0)
	self.backdrop_layout = backdrop_layout
	self:initDropItem()
	--右边的遮罩
	local backdrop_mask = display.newImage("jsys_panel_4.png")
	self.main_layout:addChild(backdrop_mask)
	backdrop_mask:setPosition(cc.p(backdrop_layout:getPositionX(),backdrop_layout:getPositionY() + 118))

	--规则按钮
	local rule_btn = display.newButton("jsys_btn_3.png")
	Coord.ingap(self.main_layout,rule_btn,"RR",-30,"TT",-5)
	self.main_layout:addChild(rule_btn)
	rule_btn:addTouchEventListener(function(sender,eventype)
		    if eventype == ccui.TouchEventType.ended then
		    	require("src.games.jinshayinsha.ui.JinShaYinShaRulePanel").show()
	        end
	    end)
	--底部
	local bottom_layout = display.newImage("jsys_bottom_panel.png")
	self.main_layout:addChild(bottom_layout,1)
	Coord.ingap(self.main_layout,bottom_layout,"CC",0,"BB",0)
	self.bottom_layout = bottom_layout
	local zx_name_label = display.newText("blank",24)
	zx_name_label:setAnchorPoint(cc.p(0,0.5))
	Coord.ingap(self.bottom_layout,zx_name_label,"LL",5,"BB",50)
	self.bottom_layout:addChild(zx_name_label)
	--vip
	local vip_icon = display.newImage("jsys_icon_2.png")
	self.bottom_layout:addChild(vip_icon)
	Coord.ingap(self.bottom_layout,vip_icon,"LL",275,"BB",55)
	local vip_label = ccui.TextAtlas:create(Player.level,"game/jinshayinsha/jsys_number_5.png",14.2,21,0)
    self.bottom_layout:addChild(vip_label)
    Coord.outgap(vip_icon,vip_label,"RL",2,"CC",0)
	--金币
	local jb_icon_img = display.newImage("jsys_icon_1.png")
	Coord.ingap(self.bottom_layout,jb_icon_img,"LL",5,"BB",5)
	self.bottom_layout:addChild(jb_icon_img)
	local jb_value_label = display.newText(Player.gold,24,Color.GWJ_IIII)
	jb_value_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(jb_icon_img,jb_value_label,"RL",10,"CC",0)
	self.bottom_layout:addChild(jb_value_label)
	self.jb_value_label = jb_value_label
	--银行
	local bank_btn = require("src.ui.item.ExButton").new("jsys_btn_1_normal.png",nil,"jsys_btn_1_disable.png")
	bank_btn:setPosition(cc.p(420,33))
	self.bottom_layout:addChild(bank_btn)
	bank_btn:addTouchEventListener(function(sender,eventype)
		    if eventype ~= ccui.TouchEventType.ended then
		    	display.showWindow("src.ui.window.bank.BankWindows")
	        end
	    end)
	self.bank_btn = bank_btn
	--续投按钮
	local continue_btn = require("src.ui.item.ExButton").new("jsys_btn_2_normal.png",nil,"jsys_btn_2_disable.png")
	self.bottom_layout:addChild(continue_btn)
	Coord.ingap(self.bottom_layout,continue_btn,"RR",-5,"BB",5)
	continue_btn:addTouchEventListener(function(sender,eventype)
		    if eventype ~= ccui.TouchEventType.ended then return end
		    	if self.dataController.state ~= 1 then
			    	display.showMsg("还未到下注时间")
			    	return
			    end
			    ConnectMgr.connect("src.games.jinshayinsha.content.JinShaYinShaGetBetAgainConnect",self.dataController.againData,function(result)
		    		if result then
		    			self.continue_btn:setDisable(true)
		    			for i=1,#self.dataController.againData do
		    				local data = self.dataController.againData[i]
		    				local multipleItem = self:getMultipleItemBySid(data.multiplesSid)
		    				self:addBet(data.money,data.multiplesSid,self:getBetPointByValue(data.money))
		    				multipleItem:addSelfValue(data.money)
					    	multipleItem:addTotalValue(data.money)
		    			end
		    			self.dataController:betAgain()
		    			self.jb_value_label:setString(Player.gold)
						self:checkDisable()
		    		end
		    	end)
	    end)

		--押分
	local yafen_layout = display.newImage("#game/jinshayinsha/sglb_icon_6.png")
	yafen_layout:setPosition(cc.p(680,520))
	self.main_layout:addChild(yafen_layout)
	local yafen_icon = display.newImage("#game/jinshayinsha/sglb_icon_5.png")
	Coord.ingap(yafen_layout,yafen_icon,"LL",10,"CC",0)
	yafen_layout:addChild(yafen_icon)
	local yafen_label = display.newText(0,24)
	yafen_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(yafen_icon,yafen_label,"RL",20,"CC",0)
	yafen_layout:addChild(yafen_label)
	self.yafen_label = yafen_label

	self.dataController:addEventListener("SGLB_BETALL_UPDATE",function(e,t) 
		self:updateYaFen()
	end)
	
	self.continue_btn = continue_btn
	self.continue_btn:setDisable(true)
	self:initelement()
	self:initmultiple()
	self:initBetMenus()
	self:scheduleUpdateWithPriorityLua(function()
		self:runAction()
		self:runFree()
	end,0.01)
end

--禁用所有投注按钮
function JinShaYinShaUIPanel:disableAllBet()
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

function JinShaYinShaUIPanel:checkDisable()
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

function JinShaYinShaUIPanel:handlerEvent(event,arg)
	--金币发生改变
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		if self.isReadState then return end
		self.jb_value_label:setString(Player.gold)
		self:checkDisable()
	elseif event == ST.COMMAND_PLAYER_BANK_GOLD_UPDATE then
		self.jb_value_label:setFormatNumber(Player.gold)
		self:checkDisable()
	elseif event == ST.COMMAND_GAMEJSYS_UPDATEDROP then
		self:updateDropItem()
	elseif event == ST.COMMAND_GAMEJSYS_BETBEGIN then
		self:playReady()
		print("开始准备···························")
	elseif event == ST.COMMAND_GAMEJSYS_BETEND then
		Command.performWithDelay(self.main_layout,function()
			self:playGame()
		end,1)
		print("游戏开始···························")
	elseif event == ST.COMMAND_GAMEJSYS_BETCHANGE then
		local bet_users = arg
		for i=1,#bet_users do
			local bet = bet_users[i]
			local random_delay = math.random(1,8)
			self:addBet(bet.money,bet.multipleSid,self:getStartPoint(),random_delay/10)
		end
		Command.performWithDelay(self.main_layout,function()
			for i=1,#self.dataController.bets_array do
				local data = self.dataController.bets_array[i]
				self:getMultipleItemBySid(i):setTotalValue(self.dataController.bets_array[i])
			end
			-- self:updateAllBetValue(self.dataController.allbetValue)
		end,0.3)
	elseif event == ST.COMMAND_GAMEJSYS_INITWAIT then
		self:showWait()
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		display.enterScene("src.ui.ReloginScene",{self.room})
	end
end
function JinShaYinShaUIPanel:runAction()
	if not self.isStart then return end
	self.nowTime = self.nowTime+1
	if self.nowTime == self.speed then
		self.nowTime = 0
		self.runTime = self.runTime + 1
		if self.runTime < 5 then
			self.gameItemList[self.blinkIndex]:blink()
			self.speed = 10
			self:goStep(1)
		else
			if self.runTime > 60 and self:getdistance(self.resultIndex,self.blinkIndex) <= self.slowIndex and self.resultIndex ~= self.blinkIndex then
				self.speed = 10
				self:goStep(1)
				self:removeShadow()
				self.gameItemList[self.blinkIndex]:blink()
				if self.blinkIndex == self.resultIndex then
					-- self:removeShadow()
					self.gameItemList[self.blinkIndex]:playRectAni()
					self:gameOver()
				end
			else
				self.speed = 3
				self:goStep(2)
				self:showShadow(4)
			end
		end
	end
end
function JinShaYinShaUIPanel:runFree()
	if not self.isFree then return end
	self.nowTime = self.nowTime+1
	if self.nowTime == self.speed then
		self.nowTime = 0
		self.runTime = self.runTime + 1
		self:goStep(1)
		self:removeShadow()
		self.gameItemList[self.blinkIndex]:blink()
		if self.runTime > 10 and self.blinkIndex == self.extraIndex then
			self.isFree = false
			self.nowTime = 0
			self.runTime = 0
			self.gameItemList[self.blinkIndex]:playRectAni()
			local data = self.gameItemList[self.blinkIndex]:getData()
			self:showWinAnimation(data.sid,self.dataController.extraMoney)
			self.dataController:addDrop(data.sid)
			self:showMultipleFont(self:getMultipleItemBySid(data.sid):getMultipleValue())
		end
	end
end
function JinShaYinShaUIPanel:showShadow(value)
	self:removeShadow()
	local tempIndex = self.blinkIndex
	if self.blinkIndex > 0 then
		for i=1,value do
			tempIndex = tempIndex - 1
			if tempIndex < 1 then
				tempIndex = #self.gameItemList
			end
			self.gameItemList[tempIndex]:blink()
		end
	end
end
function JinShaYinShaUIPanel:removeShadow()
	for i=1,#self.gameItemList do
		self.gameItemList[i]:disappear() 
	end
end
function JinShaYinShaUIPanel:playGame()
	-- self:removeScoreItem()
	self:disableAllBet()
	self.multiple_layout:setOpacity(100)
	self:removeClock()
	self.nowTime = 0    
	self.overTime = 0
	self:setBetDisable(true)
	local index_array = {}
	for i=1,#self.gameItemList do
		if self.gameItemList[i]:getData().sid == self.dataController.winSid then
			table.insert(index_array,i)
		end
	end
	self.resultIndex = index_array[Command.random(#index_array)]
	if self.dataController.extraSid > 0 then
		local extra_array = {}
		for i=1,#self.gameItemList do
			if self.gameItemList[i]:getData().sid == self.dataController.extraSid then
				table.insert(extra_array,i)
			end
		end
		self.extraIndex = extra_array[Command.random(#extra_array)]
	else
		self.extraIndex = 0
	end

	SoundsManager.stopAllMusic()
	SoundsManager.playMusic("jsys_trun",true)
	-- self.resultIndex = Command.random(28)
	-- self.resultIndex = 1
	self.speed = 20
	self.runTime = 0 
	self.isClimb = false
	self.slowIndex = math.random(8,15)
	print("self.slowIndex------------"..self.slowIndex)
	print("self.resultIndex------------"..self.resultIndex)
	self.isStart = true
end
function JinShaYinShaUIPanel:gameOver()
	self.isStart = false
	self.main_layout:runAction(cc.Sequence:create({
	    cc.DelayTime:create(1),
	    cc.CallFunc:create(function()
	    	local data = self.gameItemList[self.resultIndex]:getData()
	    	self:showWinAnimation(data.sid,self.dataController.self_winMoney)	
	    	self.dataController:addDrop(data.sid)
	    	self.jb_value_label:setString(Player.gold)
	  --       print("self.resultData------------"..data.sid)
			-- if data.belong > 0 then
			-- 	self.multipleList[data.belong]:blink()
			-- 	self.multipleList[data.sid]:blink()
			-- end
			-- self.dataController:addDrop(data.sid)
			-- require("src.games.feiqingzoushou.ui.FeiQingZouShouResultPanel").show(data.sid)
	    end)}))
end
function JinShaYinShaUIPanel:getDistanceIndex(index,distance)
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
function JinShaYinShaUIPanel:goStep(value)
	local length = #self.gameItemList
	if value > length then
		value = value % length
	end
	local temp = self.blinkIndex + value
	if temp > length then
		temp = temp - length
	end
	self.blinkIndex = temp
end
function JinShaYinShaUIPanel:getdistance(p1,p2)
	local max = #self.gameItemList
	local temp = p1 - p2
	if temp < 0 then
		temp = max - math.abs(temp)
	end
	return temp
end
function JinShaYinShaUIPanel:initelement()
	local GameImage = require("src.games.jinshayinsha.ui.GameImage")
	local rect_index = 0
	--第一列
	local config = ELEMENT_CONFIG[1]
	local lastPy = 0
	for i=1,#config do
		rect_index = rect_index + 1
		local sid = config[i]
		local item = GameImage.new(sid,ELEMENT_RECT[rect_index])
		item:setPosition(cc.p(174,100 + 95*(i-1)))
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
		if i == #config then
			lastPy = item:getPositionY()
		end
	end
	config = ELEMENT_CONFIG[2]
	local lastPx = 0
	for i=1,#config do
		rect_index = rect_index + 1
		local sid = config[i]
		local item = GameImage.new(sid,ELEMENT_RECT[rect_index])
		item:setPosition(cc.p(174 + i*111,lastPy))
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
		if i == #config then
			lastPx = item:getPositionX()
		end
	end
	config = ELEMENT_CONFIG[3]
	for i=1,#config do
		rect_index = rect_index + 1
		local sid = config[i]
		local item = GameImage.new(sid,ELEMENT_RECT[rect_index])
		item:setPosition(cc.p(lastPx + 111,lastPy - 95*(i-1)))
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
	config = ELEMENT_CONFIG[4]
	for i=1,#config do
		rect_index = rect_index + 1
		local sid = config[i]
		local item = GameImage.new(sid,ELEMENT_RECT[rect_index])
		item:setPosition(cc.p(lastPx - (i-1)*111,100))
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
end

function JinShaYinShaUIPanel:initmultiple()
	local function multiple_Click(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
	    if self.dataController.state ~= 1 then
	    	display.showMsg("还未到下注时间")
	    	return
	    end
	    if not self.m_currentBetBtn then return end
	    ConnectMgr.connect("src.games.jinshayinsha.content.JinShaYinShaGetBetConnect",self.m_currentBetBtn.betvalue,sender:getSid(),
		    function(result)
		    	if result then
		    		if self.m_currentBetBtn then
				    	local current_Position = cc.p(self.m_currentBetBtn:getPositionX(),self.m_currentBetBtn:getPositionY())
				    	self:addBet(self.m_currentBetBtn.betvalue,sender:getSid(),current_Position)
				    	sender:addSelfValue(self.m_currentBetBtn.betvalue)
				    	sender:addTotalValue(self.m_currentBetBtn.betvalue)
				    	self.dataController:addBet(self.m_currentBetBtn.betvalue,sender:getSid())
				    	self.jb_value_label:setString(Player.gold)
						self:checkDisable()
						self:checkContinueState()
					else
						display.showMsg("请选择筹码再进行下注")
				    end
		    	end
		    end)
	end
	local MultipleImage = require("src.games.jinshayinsha.ui.MultipleImage")
	local length = #BET_RECT/2
	for i=1,length do
		local item = MultipleImage.new(BET_RECT[i])
		item:setPosition(cc.p(68 + (i-1)*125,76))
		item:setTouchEnabled(true)
		item:addTouchEventListener(multiple_Click)
		self.multiple_layout:addChild(item)
		table.insert(self.multipleList,item)
	end
	length = length + 1
	local index = 0
	for i=length,#BET_RECT do
		local item = MultipleImage.new(BET_RECT[i])
		item:setPosition(cc.p(68 + index*125,224))
		item:setTouchEnabled(true)
		item:addTouchEventListener(multiple_Click)
		self.multiple_layout:addChild(item)
		index = index + 1
		table.insert(self.multipleList,item)
	end
end

function JinShaYinShaUIPanel:setBetDisable(value)
	self.m_buttonMgr:cleanCurrentButton()
	self.m_btnflow:setVisible(false)
	local btn_list = self.m_buttonMgr:getButtonList()
	for i=1,#btn_list do
		btn_list[i]:setDisable(value)
	end
	self.continue_btn:setDisable(value)
	self.bank_btn:setDisable(value)
	self.m_currentBetBtn = nil
end

function JinShaYinShaUIPanel:initDropItem()
	local beginPoint = self.backdrop_layout:getContentSize().height - 30
	for i=1,9 do
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

function JinShaYinShaUIPanel:initBetMenus()
	local config = {1000,10000,100000,1000000,5000000,10000000}
	local btnflow = display.newImage("jsys_ui_1021.png")
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
		btn = require("src.games.jinshayinsha.ui.BetButton").new(config[i])
		buttonMgr:addButton(btn)
		if not temp then
			self.bottom_layout:addChild(Coord.ingap(self.bottom_layout,btn,"CC",-120,"BB",0))
		else
			self.bottom_layout:addChild(Coord.outgap(temp,btn,"RL",50,"CC",0))
		end
		temp = btn
		table.insert(self.betPoint_array,cc.p(btn:getPositionX(),btn:getPositionY()))
	end
	local flow_rect_img = display.newImage("jsys_bottom_rect.png")
	Coord.ingap(self.bottom_layout,flow_rect_img,"CC",188,"BB",0)
	self.bottom_layout:addChild(flow_rect_img)
end

function JinShaYinShaUIPanel:updateDropItem()
	for i=1,#self.dataController.dropDatas do
		local item = self.dropItemList[i]
		item.icon:loadTexture("jsys_drop_"..self.dataController.dropDatas[i]..".png",1)
		if i == #self.dataController.dropDatas then
			if item.rect then
				item.rect:setVisible(true)
			else
				local rect =display.newImage("jsys_panel_2.png")
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

function JinShaYinShaUIPanel:addBet(value,sid,startPoint,delay)
	SoundsManager.playSound("jsys_chouma")
	startPoint = startPoint or self:getStartPoint()
	local betsp = display.newSprite(string.format("jsys_bet_%s.png",value))
	betsp:setScale(0.5)
	betsp:setPosition(startPoint)
	betsp:setAnchorPoint(cc.p(0,0))
	-- betsp:setOpacity(50)
	self.main_layout:addChild(betsp)
	local betSize = betsp:getContentSize()
	local multiple_item = self:getMultipleItemBySid(sid)
	local multiple_size = multiple_item:getContentSize()

	local multiple_positon = multiple_item:getParent():convertToWorldSpace(cc.p(multiple_item:getPositionX(),multiple_item:getPositionY()))
	multiple_positon = cc.p(multiple_positon.x - multiple_size.width/2,multiple_positon.y - multiple_size.height/2)
	multiple_size = cc.size(multiple_size.width,multiple_size.height - 40)
	multiple_positon = cc.p(multiple_positon.x,multiple_positon.y + 20)
	local movex = Command.random(multiple_size.width - betSize.width/2 - 5)
	local movey = Command.random(multiple_size.height - betSize.height/2 - 5)
	local sequence = {}
	if delay then
		table.insert(sequence,cc.DelayTime:create(delay))
	end
	table.insert(sequence,cc.FadeTo:create(0.3,50))
	table.insert(sequence,cc.EaseExponentialOut:create(cc.MoveTo:create(0.3,cc.p(multiple_positon.x + movex,multiple_positon.y + movey))))
	table.insert(sequence,		cc.CallFunc:create(function(sender)
			if #self.betItem_array < 150 then
				table.insert(self.betItem_array,betsp)
			else
				sender:removeFromParent(true)
			end
		end))
	betsp:runAction(cc.Sequence:create(sequence))


	-- local temp_layout = display.newLayout(multiple_size)
	-- display.debugLayout(temp_layout)
	-- temp_layout:setPosition(multiple_positon)
	-- self.main_layout:addChild(temp_layout)

	-- betsp:runAction(cc.Sequence:create({
	-- 	cc.FadeTo:create(0.3,100),
	-- 	cc.EaseExponentialOut:create(cc.MoveTo:create(0.3,cc.p(multiple_positon.x + movex,multiple_positon.y + movey))),
	-- 	cc.CallFunc:create(function(sender)
	-- 		if #self.betItem_array < 150 then
	-- 			table.insert(self.betItem_array,betsp)
	-- 		else
	-- 			sender:removeFromParent(true)
	-- 		end
	-- 	end)
	-- }))
end

function JinShaYinShaUIPanel:getStartPoint()
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
function JinShaYinShaUIPanel:getMultipleItemBySid(sid)
	for i=1,#self.multipleList do
		if self.multipleList[i]:getSid() == sid then
			return self.multipleList[i]
		end
	end
end
--准备阶段
function JinShaYinShaUIPanel:playReady()
	self.multiple_layout:setOpacity(255)
	self.isReadState = true
	self:checkDisable()
	if self.waitMask then
		self.waitMask:removeFromParent(true)
		self.waitMask = nil
	end
	if self.isFirst then
		self.isFirst = false
	else
		SoundsManager.stopAllMusic()
		SoundsManager.playMusic("jsys_music_game_"..Command.random(2),true)
	end
	self:cleanUI()
	-- self:removeMultipleBlink()
	local clock_item = require("src.games.jinshayinsha.ui.ClockCountDownItem").new()
	clock_item:setPosition(cc.p(675,582))
	self.main_layout:addChild(clock_item,2)
	clock_item:setCountDown(self.dataController:getTime(),true,function()
		clock_item:removeFromParent(true)
		self.clock_item = nil
	end)
	self.clock_item = clock_item
	--更新下注的倍数
	for i=1,#self.multipleList do
		local sid = self.multipleList[i]:getSid()
		local multipes = self.dataController:getMultipe()
		if sid <= #multipes then
			self.multipleList[i]:setMultipleValue(multipes[sid])
		end
	end
	self:checkContinueState()
end
function JinShaYinShaUIPanel:showMultipleFont(value)
	self.multiple_value_image:setVisible(true)
	self.multiple_value_label:setVisible(true)
	self.multiple_value_label:setString(value)
end
function JinShaYinShaUIPanel:hideMultipleFont()
	self.multiple_value_image:setVisible(false)
	self.multiple_value_label:setVisible(false)
	self:hideMoney()
end

function JinShaYinShaUIPanel:setWinMoney(value)
	self.winmoney_value_label:setString(value)
	self.winmoney_value_label:setVisible(true)
	self.winmoney_font_img:setVisible(true)
end
function JinShaYinShaUIPanel:hideMoney()
	self.winmoney_value_label:setVisible(false)
	self.winmoney_font_img:setVisible(false)
end
function JinShaYinShaUIPanel:showWinAnimation(sid,winmoney)
	local model = require("src.games.jinshayinsha.data.JinShaYinSha_element_data").new(sid)
	local points = {cc.p(422,578),cc.p(918,578)}
	local animation_items = {}
	SoundsManager.playSound(model.sound)
	for i=1,#points do
		local animation_i = display.newSprite()
		animation_i:setPosition(points[i])
		self.main_layout:addChild(animation_i)
		table.insert(animation_items,animation_i)
	end
	local function playAnimation(aniName,isDestroy,backfunction)
		for i=1,#animation_items do
			animation_items[i]:runAction(cc.Sequence:create({
				cc.Repeat:create(resource.getAnimateByKey(aniName),4),
				cc.CallFunc:create(function(sender)
					self:hideMultipleFont()
					if backfunction then
						backfunction()
					end
					if isDestroy then
						sender:removeFromParent(true)
					end
				end)}))
		end
	end

	local function Waterpistol()
		SoundsManager.playSound("jsys_jiqiang")
		for i=1,#self.gameItemList do
			local data = self.gameItemList[i]:getData()
			if data.sid == 10 or data.sid == 9 then
				self.gameItemList[i]:playRectAni()
			end
		end
		self.main_layout:runAction(cc.Sequence:create({
			cc.DelayTime:create(4),
			cc.CallFunc:create(function()
				self.runTime = 0
				self.speed = 2
				self.nowTime = 0
				self.isFree = true
			end)
		}))
	end

	if sid < 9 then
		self:showMultipleFont(self:getMultipleItemBySid(sid):getMultipleValue())
		if winmoney > 0 then
			self:setWinMoney(winmoney)
		end
		playAnimation(model.animation,true)
	elseif sid == 9 then
		if self.dataController.sharkMoney > 0 then
			self:setWinMoney(self.dataController.sharkMoney)
		end
		self:showMultipleFont(24)
		playAnimation(model.animation,true,function()
			Waterpistol()
		end)
	else
		if self.dataController.sharkMoney > 0 then
			self:setWinMoney(self.dataController.sharkMoney)
		end
		self:showMultipleFont(self.dataController.goldShark_multiple)
		playAnimation(model.animation,false,function()
			self:showMultipleFont(self.dataController.handsel_multipe)
			if self.dataController.lotteryMoney > 0 then
				self:setWinMoney(self.dataController.lotteryMoney)
			end
			playAnimation("jsys_prizes",true,function()
				Waterpistol()
			end)
		end)
	end
end
function JinShaYinShaUIPanel:cleanUI()
	self:hideMultipleFont()
	self.winmoney_value_label:setVisible(false)
	self.winmoney_font_img:setVisible(false)
	for i=1,#self.gameItemList do
		self.gameItemList[i]:stopRectAni()
		self.gameItemList[i]:disappear()
	end
	for i=1,#self.betItem_array do
		self.betItem_array[i]:removeFromParent(true)
	end
	for i=1,#self.multipleList do
		self.multipleList[i]:cleanValue()
	end
	self.betItem_array = {}
end
function JinShaYinShaUIPanel:showWait()
	local mask = display.newMask()
	self:addChild(mask,2)

	local tip_image = display.newImage("jsys_icon_5.png")
	Coord.ingap(mask,tip_image,"CC",0,"CC",200)
	mask:addChild(tip_image)

	self.waitMask = mask
end
function JinShaYinShaUIPanel:getBetPointByValue(value)
	local config = {1000,10000,100000,1000000,5000000,10000000}
	for i=1,#config do
		if config[i] == value then
			return self.betPoint_array[i]
		end
	end
end
function JinShaYinShaUIPanel:checkContinueState()
	if self.dataController.state ~= 1 then
		self.continue_btn:setDisable(true)
	else
		self.continue_btn:setDisable(not self.dataController:enbaleContinueBet())
	end
end
function JinShaYinShaUIPanel:removeClock()
	if self.clock_item then
		self.clock_item:removeFromParent(true)
		self.clock_item = nil
	end
end
-- function JinShaYinShaUIPanel:removeMultipleBlink()
-- 	for i=1,#self.multipleList do
-- 		self.multipleList[i]:disappear()
-- 	end
-- end

function JinShaYinShaUIPanel:updateYaFen()
	self.yafen_label:setString(self.dataController:getBetAllMoney())
end

function JinShaYinShaUIPanel:onCleanup()
	self:removeAllEvent()
end

return JinShaYinShaUIPanel
