--[[
*	水浒传骰子
*	@author：gwj
]]
local ShuiHuZhuanDiceWindows = class("ShuiHuZhuanDiceWindows",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"))
local instance = nil

function ShuiHuZhuanDiceWindows:ctor(winMoney)
	self.winMoney = winMoney
	self.betMoney = 0
	self:initUI()
end

function ShuiHuZhuanDiceWindows:initUI()
	SoundsManager.playMusic("shz_dice_bg",true)
	self:setTouchEnabled(true)
	self.stake = 0
	self.dice_items = {}
	self.stakeBright_array = {}
	self.brand_width = 70
	local main_layout = display.newImage("#game/shuihuzhuan/shz_dice_bg.png")
	main_layout:setAnchorPoint(cc.p(0,0))
	self:addChild(main_layout)
	self.main_layout = main_layout

	local boss_sprite = display.newSprite()
	boss_sprite:setPosition(cc.p(680,497))
	boss_sprite:setScale(1.5)
	boss_sprite:runAction(resource.getAnimateByKey("shz_action_boss_wait",true))
	self:addChild(boss_sprite)
	self.boss_sprite = boss_sprite

	local bottom_layout = display.newImage("#game/shuihuzhuan/shz_dice_bottom.png")
	bottom_layout:setPosition(cc.p(680,67))
	self:addChild(bottom_layout)
	--金币
	local gold_image = display.newImage("shz_icon_1.png")
	gold_image:setPosition(cc.p(99,50))
	self:addChild(gold_image)
	local gold_label = display.newText(Player.gold,24,Color.WHITE)
	gold_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(gold_image,gold_label,"RL",20,"CC",0)
	self:addChild(gold_label)

	local yafen_layout = display.newImage("shz_icon_2.png")
	display.setS9(yafen_layout,cc.rect(30,10,30,10),cc.size(480,39))
	yafen_layout:setPosition(cc.p(695,97))
	self:addChild(yafen_layout)
	local yaxian_icon = display.newImage("shz_icon_20.png")
	Coord.ingap(yafen_layout,yaxian_icon,"LL",10,"CC",0)
	yafen_layout:addChild(yaxian_icon)
	local yaxian_label = display.newText(0,24,Color.WHITE)
	yaxian_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(yaxian_icon,yaxian_label,"RL",10,"CC",0)
	yafen_layout:addChild(yaxian_label)
	self.yaxian_label = yaxian_label

	local defen_icon = display.newImage("shz_icon_24.png")
	Coord.ingap(yafen_layout,defen_icon,"LL",280,"CC",0)
	yafen_layout:addChild(defen_icon)
	local defen_label = display.newText(0,24,Color.WHITE)
	defen_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(defen_icon,defen_label,"RL",10,"CC",0)
	yafen_layout:addChild(defen_label)
	self.defen_label = defen_label


	local function proportionFunction(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
		if sender.state == 3 then
			if Player.gold < self.winMoney * 2 then
				display.showMsg(display.trans("##20042"))
				return 
			end
		end
		self.proportion = sender.state
		if self.proportion == 1 then
			self.betMoney = math.ceil(self.winMoney * 0.5)
		elseif self.proportion == 2 then
			self.betMoney = self.winMoney
		else
			self.betMoney = self.winMoney * 2
		end
		self.yaxian_label:setString(self.betMoney)
		self:stakeMode()
	end

	--半比
	local banbi_btn = require("src.ui.item.ExButton").new("shz_btn_15_normal.png","shz_btn_15_click.png","shz_btn_15_disable.png")
	banbi_btn.state = 1
	banbi_btn:setPosition(cc.p(518,38))
	bottom_layout:addChild(banbi_btn)
	banbi_btn:addTouchEventListener(proportionFunction)
	self.banbi_btn = banbi_btn

	--全比
	local quanbi_btn =require("src.ui.item.ExButton").new("shz_btn_19_normal.png","shz_btn_19_click.png","shz_btn_19_disable.png")
	quanbi_btn.state = 2
	quanbi_btn:setPosition(cc.p(695,38))
	bottom_layout:addChild(quanbi_btn)
	quanbi_btn:addTouchEventListener(proportionFunction)
	self.quanbi_btn = quanbi_btn

	--倍比
	local beibi_btn = require("src.ui.item.ExButton").new("shz_btn_16_normal.png","shz_btn_16_click.png","shz_btn_16_disable.png")
	beibi_btn.state = 3
	beibi_btn:setPosition(cc.p(872,38))
	bottom_layout:addChild(beibi_btn)
	beibi_btn:addTouchEventListener(proportionFunction)
	self.beibi_btn = beibi_btn

	local function stakeFunction(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
		self.stake = sender.stake
		self:showGoldHeap(self.stake)
		ConnectMgr.connect("src.games.shuihuzhuan.content.ShuiHuZhuanDiceConnect",self:multipleClientToServer(self.proportion),self:chooseClientToServer(self.stake),function(result)
			if result ~= false then
				self:diceStart(result)
			end
		end)
	end

	--押小
	local yaxiao_btn = require("src.ui.item.ExButton").new("shz_btn_21_normal.png","shz_btn_21_click.png","shz_btn_21_disable.png")
	yaxiao_btn:setPosition(cc.p(518,38))
	bottom_layout:addChild(yaxiao_btn)
	yaxiao_btn:setVisible(false)
	yaxiao_btn.stake = 1
	yaxiao_btn:addTouchEventListener(stakeFunction)
	self.yaxiao_btn = yaxiao_btn

	--押和
	local yahe_btn =require("src.ui.item.ExButton").new("shz_btn_18_normal.png","shz_btn_18_click.png","shz_btn_18_disable.png")
	yahe_btn:setVisible(false)
	yahe_btn:setPosition(cc.p(695,38))
	bottom_layout:addChild(yahe_btn)
	yahe_btn.stake = 2
	yahe_btn:addTouchEventListener(stakeFunction)
	self.yahe_btn = yahe_btn

	--押大
	local yada_btn = require("src.ui.item.ExButton").new("shz_btn_17_normal.png","shz_btn_17_click.png","shz_btn_17_disable.png")
	yada_btn:setVisible(false)
	yada_btn:setPosition(cc.p(872,38))
	bottom_layout:addChild(yada_btn)
	yada_btn.stake = 3
	yada_btn:addTouchEventListener(stakeFunction)
	self.yada_btn = yada_btn

	--取分
	local qufen_btn = require("src.ui.item.ExButton").new("shz_btn_20_normal.png","shz_btn_20_click.png","shz_btn_20_disable.png")
	qufen_btn:setPosition(cc.p(1133,57))
	bottom_layout:addChild(qufen_btn)
	qufen_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			self:outGame()
	    end)
	self.qufen_btn = qufen_btn

	--元宝堆
	local goldheap_panel = display.newLayout(cc.size(250,120))
	goldheap_panel:setVisible(false)
	self:addChild(goldheap_panel,1)
	local gold_points = {cc.p(67,38),cc.p(180,38),cc.p(130,71)}
	for i=1,#gold_points do
		local item = display.newImage("shz_icon_12.png")
		item:setPosition(gold_points[i])
		goldheap_panel:addChild(item)
	end
	self.goldheap_panel = goldheap_panel
	--亮框
	local bright_points = {cc.p(289,200),cc.p(686,200),cc.p(1065,200)}
	local bright_icons = {"shz_icon_15.png","shz_icon_16.png","shz_icon_14.png"}
	for i=1,#bright_points do
		local bright_item = display.newImage(bright_icons[i])
		bright_item:setPosition(bright_points[i])
		bright_item:setVisible(false)
		self:addChild(bright_item)
		table.insert(self.stakeBright_array,bright_item)
	end
	--前筛子
	local frontdice_points = {cc.p(54,43),cc.p(163,43)}
	local frontdice_panel = display.newLayout(cc.size(220,85))
	frontdice_panel:setVisible(false)
	self:addChild(frontdice_panel,2)
	frontdice_panel.child_array = {}
	for i=1,#frontdice_points do
		local front_item = display.newImage()
		front_item:setPosition(frontdice_points[i])
		frontdice_panel:addChild(front_item)
		table.insert(frontdice_panel.child_array,front_item)
	end
	self.frontdice_panel = frontdice_panel
	--绳子
	local pope_image = display.newImage("shz_icon_10.png")
	pope_image:setPosition(cc.p(680,737))
	self:addChild(pope_image)
	self:beginWaitTime()
end

function ShuiHuZhuanDiceWindows:outGame()
	ConnectMgr.connect("src.games.shuihuzhuan.content.ShuiHuZhuanDiceOutConnect",function(result)
		SoundsManager.stopAllMusic()
		self:dispatchEvent("SHZ_DICE_WINDOW_OUT")
		self:removeFromParent(true)
		instance = nil
	end)	
end

function ShuiHuZhuanDiceWindows:runMode()
	self.yaxiao_btn:setDisable(true)
	self.yahe_btn:setDisable(true)
	self.yada_btn:setDisable(true)
	self.qufen_btn:setDisable(true)
end

function ShuiHuZhuanDiceWindows:normalMode()
	self.yaxiao_btn:setVisibleTouch(false)
	self.yahe_btn:setVisibleTouch(false)
	self.yada_btn:setVisibleTouch(false)
	self.qufen_btn:setDisable(false)
	self.banbi_btn:setVisibleTouch(true)
	self.quanbi_btn:setVisibleTouch(true)
	self.beibi_btn:setVisibleTouch(true)
	self:beginWaitTime()
end

function ShuiHuZhuanDiceWindows:stakeMode()
	self.banbi_btn:setVisibleTouch(false)
	self.quanbi_btn:setVisibleTouch(false)
	self.beibi_btn:setVisibleTouch(false)
	self.yaxiao_btn:setVisibleTouch(true)
	self.yahe_btn:setVisibleTouch(true)
	self.yada_btn:setVisibleTouch(true)
	self.yaxiao_btn:setDisable(false)
	self.yahe_btn:setDisable(false)
	self.yada_btn:setDisable(false)
end

function ShuiHuZhuanDiceWindows:diceStart(choosedata)
	choosedata.chooseResult = self:chooseServerToClient(choosedata.chooseResult)
	self:removeWaitTime()
	self:removePlateDice()
	self:runMode()
	self:hideBright()
	self:hideFrontDice()
	local dice_value_1 = choosedata.diceI
	local dice_value_2 = choosedata.diceII
	print("dice_value_1----------------------",dice_value_1)
	print("dice_value_2----------------------",dice_value_2)
	local sum = dice_value_1 + dice_value_2 
	local over_point = nil
	local over_aniname = nil
	self:runMode()
	self.boss_sprite:stopAllActions()
	self.boss_sprite:setPosition(cc.p(668,531))
	SoundsManager.playSound("shz_dice_rock")
	if not choosedata.isWin then
		self.boss_sprite:runAction(cc.Sequence:create({
	       resource.getAnimateByKey("shz_action_boss_dice_1"),
	       cc.CallFunc:create(function(sender)
	       		sender:setPosition(cc.p(659,516))
	       end),
	       resource.getAnimateByKey("shz_action_boss_dice_2"),
	       cc.CallFunc:create(function(sender)
	       		self:showPlateDice({dice_value_1,dice_value_2})
	       		SoundsManager.playSound("shz_dice_point"..sum)
	       end),
	       resource.getAnimateByKey("shz_action_boss_dice_3"),
	       cc.CallFunc:create(function(sender)
	       		sender:setPosition(cc.p(641,511))
	       		self:showBright(choosedata.chooseResult)
	       		self:showFrontDice(choosedata.chooseResult,dice_value_1,dice_value_2)
	       		SoundsManager.playSound("shz_dice_lose")
	       end),
       	   resource.getAnimateByKey("shz_action_boss_win"),
       	   cc.DelayTime:create(1),
       	   cc.CallFunc:create(function(sender)
	       		self:outGame()
	       end)}))
	else
		self.boss_sprite:runAction(cc.Sequence:create({
	       resource.getAnimateByKey("shz_action_boss_dice_1"),
	       cc.CallFunc:create(function(sender)
	       		sender:setPosition(cc.p(659,516))
	       end),
	       resource.getAnimateByKey("shz_action_boss_dice_2"),
	       cc.CallFunc:create(function(sender)
	       		self:showPlateDice({dice_value_1,dice_value_2})
	       		SoundsManager.playSound("shz_dice_point"..sum)
	       end),
	       resource.getAnimateByKey("shz_action_boss_dice_3"),
	       cc.CallFunc:create(function(sender)
	       		sender:setPosition(cc.p(665,530))
	       		self:showBright(choosedata.chooseResult)
	       		self:showFrontDice(choosedata.chooseResult,dice_value_1,dice_value_2)
	       end),
       	   resource.getAnimateByKey("shz_action_boss_lose_1"),
       	   cc.CallFunc:create(function(sender)
	       		self:removePlateDice()
	       		SoundsManager.playSound("shz_dice_win")
	       end),
	       resource.getAnimateByKey("shz_action_boss_lose_2"),
	       cc.CallFunc:create(function(sender)
	       		self.winMoney = self.betMoney * choosedata.multiples
	       		self.defen_label:setString(self.winMoney)
	       		self.yaxian_label:setString(0)
	       		self:addBrand(choosedata.chooseResult)
	       		self:normalMode()
	       end)}))
	end
end

function ShuiHuZhuanDiceWindows:multipleClientToServer(value)
	local newValue = 0
	if value == 1 then
		newValue = 0
	elseif value == 2 then
		newValue = 1
	else
		newValue = 2
	end
	return newValue
end

function ShuiHuZhuanDiceWindows:chooseClientToServer(value)
	local newValue = nil
	if value == 1 then
		newValue = 2
	elseif value == 2 then
		newValue = 0
	else
		newValue = 1
	end
	return newValue
end

function ShuiHuZhuanDiceWindows:chooseServerToClient(value)
	local newValue = nil
	if value == 0 then
		newValue = 2
	elseif value == 1 then
		newValue = 3
	else
		newValue = 1
	end
	return newValue
end

function ShuiHuZhuanDiceWindows:getNumerByChooseResult(chooseResult)
	local numbers = {}
	if chooseResult == 1 then
		numbers[1] = Command.random(6)
		numbers[2] = Command.random(6 - numbers[1])
	elseif chooseResult == 2 then
		numbers[1] = Command.random(6)
		numbers[2] = 7 - numbers[1]
	else
		numbers[1] = math.random(2,6)
		numbers[2] = math.random(8 - numbers[1],6)
	end
	return numbers
end

function ShuiHuZhuanDiceWindows:showPlateDice(values)
	local points = {cc.p(638,331),cc.p(667,323)}
	for i=1,#points do
		local item = display.newImage("shz_dice_2_"..values[i]..".png")
		item:setPosition(points[i])
		self:addChild(item)
		table.insert(self.dice_items,item)
	end
end

function ShuiHuZhuanDiceWindows:removePlateDice()
	if #self.dice_items == 0 then return end
	for i=1,#self.dice_items do
		self.dice_items[i]:removeFromParent(true)
	end
	self.dice_items = {}
end

function ShuiHuZhuanDiceWindows:showGoldHeap(index)
	local points = {cc.p(171,151),cc.p(558,151),cc.p(926,151)}
	self.goldheap_panel:setPosition(points[index])
	self.goldheap_panel:setVisible(true)
end

function ShuiHuZhuanDiceWindows:hideGoldHeap()
	self.goldheap_panel:setVisible(false)
end

function ShuiHuZhuanDiceWindows:showBright(index)
	self.stakeBright_array[index]:setVisible(true)
end

function ShuiHuZhuanDiceWindows:hideBright()
	for i=1,#self.stakeBright_array do
		self.stakeBright_array[i]:setVisible(false)
	end
end

function ShuiHuZhuanDiceWindows:showFrontDice(index,dice_value_1,dice_value_2)
	local points = {cc.p(210,170),cc.p(575,170),cc.p(935,170)}
	self.frontdice_panel:setPosition(points[index])
	self.frontdice_panel:setVisible(true)
	self.frontdice_panel.child_array[1]:loadTexture("shz_dice_1_"..dice_value_1..".png",1)
	self.frontdice_panel.child_array[2]:loadTexture("shz_dice_1_"..dice_value_2..".png",1)
end
function ShuiHuZhuanDiceWindows:hideFrontDice()
	self.frontdice_panel:setVisible(false)
end
function ShuiHuZhuanDiceWindows:addBrand(value)
	local icon_str = nil
	if value == 1 then
		icon_str = "shz_icon_8.png"
	elseif value == 2 then
		icon_str = "shz_icon_6.png"
	else
		icon_str = "shz_icon_5.png"
	end
	local item = display.newImage(icon_str)
	self.brand_width = self.brand_width + 70
	item:setPosition(self.brand_width,718)
	self:addChild(item)
end

function ShuiHuZhuanDiceWindows:beginWaitTime()
	if self.wait_action then return end
	--开始计时
	self.wait_action = self:schedule(function()
		SoundsManager.playSound("shz_dice_wait_"..Command.random(5))
	end,10)
end

function ShuiHuZhuanDiceWindows:removeWaitTime()
	if self.wait_action then
		self:stopAction(self.wait_action)
	end
end

function ShuiHuZhuanDiceWindows.show(winMoney)
	if instance ~= nil then return end
	instance = ShuiHuZhuanDiceWindows.new(winMoney)
	display.getRunningScene():addChild(instance)
	return instance
end

return ShuiHuZhuanDiceWindows