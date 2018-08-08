--[[
 *	水果拉霸UI
 *	@author gwj
]]
local ShuiGuoLaBaUIPanel = class("ShuiGuoLaBaUIPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"),IEventListener)

function ShuiGuoLaBaUIPanel:ctor()
	self.gameItemList = {}	 --游戏项集合
	self.multipleList = {}   --倍数项集合
	self.dropItemList = {}	 --右边显示项集合
	self.betItemList = {}	 --下注项集合
	self.betPoint_array = {}	--筹码集合
	self.isStart = false	 --是否开始
	self.nowTime = 0         --当前计时器
	self.speed = 20          --闪动的速度
	self.runTime = 0         --闪动的时间
	self.overTime = 0        --闪动结束的时间
	self.blinkIndex = 1	     --当前闪
	self.resultIndex = 0    --结果索引
	self.slowIndex = 0 		 --减速的步数
	self.isClimb = false     --是否龟速
	self.state = 0           --状态
	self.dataController = require("src.games.shuiguolaba.data.ShuiGuoLaBaController").getInstance()
	self.effect_config = require("src.games.shuiguolaba.data.ShuiGuoLaBa_effect_config")
	self.soundController = require("src.games.shuiguolaba.data.ShuiGuoLaBaSoundController").getInstance()

	local main_layout = display.newImage("#game/shuiguolaba/sglb_bg.png")
	main_layout:setAnchorPoint(cc.p(0,0))
	self:addChild(main_layout)
	self.main_layout = main_layout
	--右边
	local backdrop_layout = display.newImage("sglb_icon_7.png")
	self.main_layout:addChild(backdrop_layout)
	Coord.ingap(self.main_layout,backdrop_layout,"RR",-30,"CC",0)
	self.backdrop_layout = backdrop_layout
	--中间
	local djxftb_image = display.newImage("sglb_icon_2.png")
	djxftb_image:setPosition(cc.p(422,570))
	self.main_layout:addChild(djxftb_image)
	--押分
	local yafen_layout = display.newImage("sglb_icon_6.png")
	yafen_layout:setPosition(cc.p(675,570))
	self.main_layout:addChild(yafen_layout)
	local yafen_icon = display.newImage("sglb_icon_5.png")
	Coord.ingap(yafen_layout,yafen_icon,"LL",10,"CC",0)
	yafen_layout:addChild(yafen_icon)
	local yafen_label = display.newText(95712,24)
	yafen_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(yafen_icon,yafen_label,"RL",20,"CC",0)
	yafen_layout:addChild(yafen_label)
	self.yafen_label = yafen_label
	--得分
	local defen_layout = display.newImage("sglb_icon_6.png")
	defen_layout:setPosition(cc.p(920,570))
	self.main_layout:addChild(defen_layout)
	local defen_icon = display.newImage("sglb_icon_12.png")
	Coord.ingap(defen_layout,defen_icon,"LL",10,"CC",0)
	defen_layout:addChild(defen_icon)
	local defen_label = display.newText(0,24)
	defen_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(defen_icon,defen_label,"RL",20,"CC",0)
	defen_layout:addChild(defen_label)
	self.defen_label = defen_label
	local defen_rect = display.newImage("sglb_icon_13.png")
	-- defen_rect:setAnchorPoint(cc.p(0,0))
	defen_rect:setPosition(cc.p(defen_layout:getPositionX(),defen_layout:getPositionY()))
	self.main_layout:addChild(defen_rect)
	defen_rect:setVisible(false)
	self.defen_rect = defen_rect

	--金币
	local self_gold_label = ccui.TextAtlas:create(Player.gold,"game/shuiguolaba/sglb_number_5.png",18,32,0)
	self_gold_label:setAnchorPoint(cc.p(0,0.5))
	self_gold_label:setPosition(cc.p(80,29))
	self.main_layout:addChild(self_gold_label)
	self.self_gold_label = self_gold_label

	--名字
	local self_name_label = display.newText(Player.username,24)
	self_name_label:setAnchorPoint(cc.p(0,0.5))
	self_name_label:setPosition(cc.p(27,81))
	self.main_layout:addChild(self_name_label)
	--vip
	local vip_icon = display.newImage("sglb_icon_1.png")
	vip_icon:setPosition(cc.p(225,81))
	self.main_layout:addChild(vip_icon)
	local vip_label = ccui.TextAtlas:create(Player.level,"game/shuiguolaba/sglb_number_6.png",14.2,21,0)
    self.main_layout:addChild(vip_label)
    Coord.outgap(vip_icon,vip_label,"RL",2,"CC",0)

    --银行
    local bank_btn = require("src.ui.item.ExButton").new("sglb_btn_4_normal.png","sglb_btn_4_disable.png",nil)
    bank_btn:setPosition(cc.p(63,200))
    self.main_layout:addChild(bank_btn)
    bank_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			display.showWindow("src.ui.window.bank.BankWindows")
		end)
    self.bank_btn = bank_btn

    --开始
    local start_btn = require("src.ui.item.ExButton").new("sglb_btn_5_normal.png","sglb_btn_5_click.png","sglb_btn_5_disable.png")
    start_btn:setPosition(cc.p(1261,57))
    self.main_layout:addChild(start_btn)
    start_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			-- if self.state == 0 then
			-- 	self:playGame()
			-- elseif self.state == 2 then
			-- 	self:readyState()
			-- end
			if self.dataController:getBetAllMoney() > Player.gold then
				display.showMsg("金币不足!")
				return
			end
			self:playGame()
		end)
    self.start_btn = start_btn
    --比倍
    local bibei_bg = display.newImage("b_bg.png")
    bibei_bg:setPosition(cc.p(1240,45))
    bibei_bg:setScale(2)
    self.main_layout:addChild(bibei_bg)
    -- local bibei_num = display.newImage("b_0.png")
    local bibei_num = display.newSprite()
    bibei_bg:addChild(bibei_num)
    bibei_num:setAnchorPoint(0.5,0.5)
    bibei_num:setPosition(27,31)

    bibei_bg:setVisible(false)
    self.bibei_num = bibei_num
    self.bibei_bg = bibei_bg
    --0 :是大 1是小
    local function gambleRequest(type)
	    ConnectMgr.connect("src.games.shuiguolaba.content.ShuiGuoLaBaGambleConnect",type,function(result)
			if result ~= false  then
				self:overState()
				self:setBeiBiState(false)
				self:bigSamll(result)
			end
		end)
    end

    --大
    local big_btn = require("src.ui.item.ExButton").new("sglb_btn_1_normal.png","sglb_btn_1_click.png","sglb_btn_1_disable.png")
    big_btn:setPosition(cc.p(935,55))
    self.main_layout:addChild(big_btn)
    big_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			gambleRequest(1)
		end)
    big_btn:setDisable(true)
    self.big_btn = big_btn
    --小
    local samll_btn = require("src.ui.item.ExButton").new("sglb_btn_2_normal.png","sglb_btn_2_click.png","sglb_btn_2_disable.png")
    samll_btn:setPosition(cc.p(1090,55))
    self.main_layout:addChild(samll_btn)
    samll_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			gambleRequest(0)
		end)
    samll_btn:setDisable(true)
    self.samll_btn = samll_btn

    --规则按钮
	local rule_btn = display.newButton("sglb_btn_3_normal.png","sglb_btn_3_click.png")
	Coord.ingap(self.main_layout,rule_btn,"RR",-5,"TT",-5)
	self.main_layout:addChild(rule_btn)
	rule_btn:addTouchEventListener(function(sender,eventype)
		    if eventype == ccui.TouchEventType.ended then
		    	require("src.games.shuiguolaba.ui.ShuiGuoLaBaRulePanel").show()
	        end
	    end)

	self.dataController:addEventListener("SGLB_BETALL_UPDATE",function(e,t) 
		self:updateYaFen()
		if self.m_currentBetBtn then
			if self.dataController:getSurplusMoney() < self.m_currentBetBtn.betvalue then
				self.m_buttonMgr:cleanCurrentButton()
				self.m_btnflow:setVisible(false)
				self.m_currentBetBtn = nil
			end
		end
	end)
	self.dataController:addEventListener("SGLB_DROPLIST_UPDATE",function(e,t)
		self:updateDropItem()
	end)

    self:initmultiple()
    self:initBetMenus()
    self:initElement()
    self:initDropItem()
    self:updateDropItem()
    -- self:readyState()
    -- self:showRandomAction()
    self:scheduleUpdateWithPriorityLua(function()
		self:runAction()
		self:runFree()
	end,0.01)
end

--比大小
function ShuiGuoLaBaUIPanel:bigSamll(result)
		self.start_btn:setVisible(false)
		self.start_btn:setTouchEnabled(false)
		self.bibei_bg:setVisible(true)
		local index = 0
		local act1 = cc.DelayTime:create(0.12)
		local act2 = cc.CallFunc:create(function ()
			index = index + 1
			if(index == 15)then
				local gamble = result.gamble
				mlog(gamble,"返回大小！")
				local rand_min = 0
				local rand_max = 0
				if(tonumber(gamble) == 1)then
					rand_min = 5
					rand_max = 9
				else
					rand_min = 0
					rand_max = 4
				end
				local ran_num = math.random(rand_min,rand_max)
				mlog(ran_num,"ran_num")
				self.bibei_num:setSpriteFrame(string.format("b_%d.png",ran_num))

				self:updateGold()
				self:updateDeFen(result.winMoney)
				if result.winMoney > 0 then
					SoundsManager.playSound("sglb_dx_win")
					self:effectDefen()
				else
					SoundsManager.playSound("sglb_dx_lose")
				end
				return
			elseif(index > 15)then
				if(index >= 40)then
					self.start_btn:setVisible(true)
					self.start_btn:setTouchEnabled(true)
					self.bibei_bg:setVisible(false)				
					self.bibei_bg:stopAllActions()
				end
				return	 
			end
			self.bibei_num:setSpriteFrame(string.format("b_%d.png",math.random(0,9)))
		end)

		local act3 = cc.Sequence:create({act1,act2})
		local act4 = cc.RepeatForever:create(act3)
		self.bibei_bg:runAction(act4)		

		SoundsManager.playSound("bibei")
				-- self:updateGold()
				-- self:updateDeFen(result.winMoney)
				-- if result.winMoney > 0 then
				-- 	SoundsManager.playSound("sglb_dx_win")
				-- 	self:effectDefen()
				-- else
				-- 	SoundsManager.playSound("sglb_dx_lose")
				-- end	
end

function ShuiGuoLaBaUIPanel:runAction()
	if not self.isStart then return end
	self.nowTime = self.nowTime+1
	if self.nowTime == self.speed then
		self.nowTime = 0
		self.runTime = self.runTime + 1
		self:removeShadow()
		self.blinkIndex = self:goStep(self.blinkIndex,1)
		self.gameItemList[self.blinkIndex]:blink()
		SoundsManager.playSound("sglb_turn")
		if self.runTime < 5 then
			self.speed = 15
		else
			if self.runTime > 40 then
				if self:getdistance(self.resultIndex,self.blinkIndex) == self.slowIndex then
					self.isClimb = true
				end
				if self.isClimb then
					self.speed = 15
					if self.blinkIndex == self.resultIndex then
						self.gameItemList[self.resultIndex]:setRetain()
						self:gameOver()
					end
				else
					self.speed = 5
				end
			else
				self.speed = 5
			end
		end
	end
end

function ShuiGuoLaBaUIPanel:runFree()
	if not self.isFree then return end
	self.nowTime = self.nowTime+1
	if self.nowTime == self.speed then
		self.nowTime = 0
		self.runTime = self.runTime + 1
		self:removeNotRetainShadow()
		self.freeBlinkIndex = self:goStep(self.freeBlinkIndex,1)
		self.gameItemList[self.freeBlinkIndex]:blink()
		if self.freeBlinkIndex == self.extraIndex then
			self.gameItemList[self.freeBlinkIndex]:setRetain()
			self.isFree = false
			self.nowTime = 0
			self.runTime = 0
			SoundsManager.playSound("sglb_pa")
		end
	end
end

function ShuiGuoLaBaUIPanel:playGame()
	local betdatas = self.dataController:getBetDatas()
	if not betdatas then
		display.showMsg("请先下注!")
		return
	end
	ConnectMgr.connect("src.games.shuiguolaba.content.ShuiGuoLaBaPlayConnect",betdatas,function(result)
		if result ~= false  then
			self.content_data = result
			self.nowTime = 0    
			self.overTime = 0
			self.resultIndex = self.content_data.result_indexs[1]
			self.speed = 10
			self.runTime = 0 
			self.isClimb = false
			self.slowIndex = math.random(3,8)
			self:runState()
			print("self.slowIndex------------"..self.slowIndex)
			print("self.resultIndex------------"..self.resultIndex)
			self.isStart = true
		end
	end)
end

function ShuiGuoLaBaUIPanel:gameOver()
	self.isStart = false
	local element_data = self.gameItemList[self.resultIndex]:getData()
	local sequence_array = {}
	table.insert(sequence_array,cc.DelayTime:create(0.2))
	table.insert(sequence_array,cc.CallFunc:create(function()
		if element_data.tureSid < 9 then
    		SoundsManager.playSound("sglb_element_"..element_data.tureSid)
    		self:playMultipleEffect(element_data.tureSid)
    	end
    	self.gameItemList[self.resultIndex]:playRectAni()
	end))
	table.insert(sequence_array,cc.DelayTime:create(1))
	if element_data.sid == 17 then
		table.insert(sequence_array,cc.CallFunc:create(function()
			self:showRandomAction()
		end))
		table.insert(sequence_array,cc.DelayTime:create(2))
		table.insert(sequence_array,cc.CallFunc:create(function()
			self:stopRandomAction()
		end))
		if #self.content_data.result_indexs > 1 then
			table.insert(sequence_array,cc.CallFunc:create(function()
				self:showAction(6)
			end))
			table.insert(sequence_array,cc.DelayTime:create(2))
			for i=2,#self.content_data.result_indexs do
				table.insert(sequence_array,cc.CallFunc:create(function()
					self:freeAction(self.content_data.result_indexs[i])
				end))
				table.insert(sequence_array,cc.DelayTime:create(2))
			end
			if self.content_data.specialId > 0 then
				table.insert(sequence_array,cc.CallFunc:create(function()
					for i=2,#self.content_data.result_indexs do
						self.gameItemList[self.content_data.result_indexs[i]]:breathAction()
					end
					self:showAction(self.content_data.specialId)
				end))
				table.insert(sequence_array,cc.DelayTime:create(2))
			end
		else
			table.insert(sequence_array,cc.CallFunc:create(function()
				self:beiChiLe()
			end))
		end
	end
	table.insert(sequence_array,cc.CallFunc:create(function()
		self:overState()
		self:setBeiBiState(self.content_data.winMoney > 0)
		self:updateDeFen(self.content_data.winMoney)
		self:updateGold()
		self.dataController:addDropData(element_data.tureSid)
		local soundName = self:getAreaSound()
		if soundName then
			SoundsManager.playSound(soundName)
		end
	end))
	self.main_layout:runAction(cc.Sequence:create(sequence_array))
end

function ShuiGuoLaBaUIPanel:freeAction(extraIndex)
	local sequence_array = {}
	table.insert(sequence_array,cc.CallFunc:create(function()
		self.gameItemList[self.resultIndex]:playFreeAni()
	end))
	table.insert(sequence_array,cc.DelayTime:create(1.2))
	table.insert(sequence_array,cc.CallFunc:create(function()
		self.extraIndex = extraIndex
		self.runTime = 0
		self.speed = 2
		self.nowTime = 0
		self.isFree = true
		self.freeBlinkIndex = self.resultIndex
	end))
	self.main_layout:runAction(cc.Sequence:create(sequence_array))
end

function ShuiGuoLaBaUIPanel:initmultiple()
	local function MultipleImage_Click(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
		if not self.m_currentBetBtn then return end
		if self.dataController:hasOldData() then
			self:cleanDesktop()
		end
		if self.dataController:getBetAllMoney() + self.m_currentBetBtn.betvalue > self.dataController.maxBetMoney then
			display.showMsg("最大下注额为1亿")
			return
		end
		sender:addTotalValue(self.m_currentBetBtn.betvalue)
		local current_Position = cc.p(self.m_currentBetBtn:getPositionX(),self.m_currentBetBtn:getPositionY())
    	self:addBet(self.m_currentBetBtn.betvalue,sender.index,current_Position)
	end

	local multiple_array = {3,5,2,1,8,7,6,4}
	local model = require("src.games.shuiguolaba.ui.MultipleImage")
	for i=1,4 do
		local item = model.new(multiple_array[i])
		item:setPosition(cc.p(406 + (i - 1)*180,337))
		self.main_layout:addChild(item)
		item:setTouchEnabled(true)
		item:addTouchEventListener(MultipleImage_Click)
		item.index = i
		table.insert(self.multipleList,item)
	end

	for i=5,8 do
		local item = model.new(multiple_array[i])
		item:setPosition(cc.p(406 + (i - 5)*180,477))
		self.main_layout:addChild(item)
		item:setTouchEnabled(true)
		item:addTouchEventListener(MultipleImage_Click)
		item.index = i
		table.insert(self.multipleList,item)
	end
end
function ShuiGuoLaBaUIPanel:initBetMenus()
	local config = {1000,10000,100000,1000000,5000000}
	local btnflow = display.newImage("sglb_ui_1021.png")
	btnflow:setVisible(false)
	btnflow:setScale(1.35)
	btnflow:runAction(cc.RepeatForever:create(cc.Sequence:create({
		cc.ScaleTo:create(0.8,1),
		cc.ScaleTo:create(0.8,1.35)
	})))
	Coord.ingap(self.main_layout,btnflow,"CC",0,"CC",0)
	self.main_layout:addChild(btnflow)
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
		btn = require("src.games.shuiguolaba.ui.BetButton").new(config[i])
		buttonMgr:addButton(btn)
		if not temp then
			self.main_layout:addChild(Coord.ingap(self.main_layout,btn,"LL",280,"BB",2))
		else
			self.main_layout:addChild(Coord.outgap(temp,btn,"RL",10,"CC",0))
		end
		temp = btn
		table.insert(self.betPoint_array,cc.p(btn:getPositionX(),btn:getPositionY()))
	end
end
function ShuiGuoLaBaUIPanel:initElement()
	-- ids  1:小苹果 2：大苹果 3 小橘子 4 大橘子 5 小铃铛 6 大铃铛 7 小西瓜  8 大西瓜
	-- 9 小芒果 10 大芒果 11 小星星 12 大猩猩 13 小7 14 大7 15 小王 16 大王 17 GOODLUCK
	local element_ids = {11,12,17,2,4,3,15,16,1,10,8,7,17,2,5,6,13,14,1,9}
	local model = require("src.games.shuiguolaba.ui.GameImage")
	for i=1,5 do
		local item = model.new(element_ids[i])
		item:setPosition(cc.p(154,(143 + (i - 1) * 113)))
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
	for i=6,10 do
		local item = model.new(element_ids[i])
		item:setPosition(cc.p(154 + 148*(i-5),595))
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
	for i=11,15 do
		local item = model.new(element_ids[i])
		item:setPosition(cc.p(1043,595 - (i - 11)*113))
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
	for i=16,20 do
		local item = model.new(element_ids[i])
		item:setPosition(cc.p(894 - 148*(i - 16),143))
		self.main_layout:addChild(item)
		table.insert(self.gameItemList,item)
	end
end
function ShuiGuoLaBaUIPanel:initDropItem()
	local beginPoint = self.backdrop_layout:getContentSize().height - 30
	for i=1,9 do
		local animal_item = display.newLayout(cc.size(70,68))
		local icon = display.newImage()
		icon:setPosition(cc.p(35,35))
		animal_item:addChild(icon)
		animal_item:setPosition(cc.p((self.backdrop_layout:getContentSize().width - 70 )/2,beginPoint -  (i-1)*68))
		animal_item.icon = icon
		self.backdrop_layout:addChild(animal_item)
		table.insert(self.dropItemList,animal_item)
		-- local rect = display.newImage("fqzs-fly-main-icon-new.png")
		-- rect:setPosition(cc.p(35,35))
		-- animal_item:addChild(rect)
	end
end
function ShuiGuoLaBaUIPanel:addBet(value,index,startPoint)
	SoundsManager.playSound("sglb_bet")
	startPoint = startPoint or self:getStartPoint()
	local betsp = display.newSprite(string.format("sglb_bet_%s.png",value))
	betsp:setPosition(startPoint)
	betsp:setScale(0.5)
	betsp:setAnchorPoint(cc.p(0,0))
	betsp:setOpacity(120)
	self.main_layout:addChild(betsp)
	local bet_size = betsp:getContentSize()
	local multiple_item = self.multipleList[index]
	local multiple_size = multiple_item:getContentSize()
	local multiple_positon = multiple_item:getParent():convertToWorldSpace(cc.p(multiple_item:getPositionX() - multiple_size.width/2,multiple_item:getPositionY() - multiple_size.height/2))
	self.dataController:addBetValue(multiple_item:getSid(),value)
	multiple_size = cc.size(multiple_size.width,multiple_size.height - 40)
	-- local temp_layout = display.newLayout(multiple_size)
	-- display.debugLayout(temp_layout)
	-- temp_layout:setPosition(multiple_positon)
	-- self.main_layout:addChild(temp_layout)
	local movex = Command.random(multiple_size.width - bet_size.width*0.5)
	local movey = Command.random(multiple_size.height - bet_size.height*0.5)
	betsp:runAction(cc.Sequence:create({
		cc.FadeIn:create(0.3),
		cc.EaseExponentialOut:create(cc.MoveTo:create(0.3,cc.p(multiple_positon.x + movex,multiple_positon.y + movey)))
	}))
	table.insert(self.betItemList,betsp)
end
--完成状态
function ShuiGuoLaBaUIPanel:overState()
	self.state = 2
	self.start_btn:setDisable(false)
	self.dataController:reset()
end

function ShuiGuoLaBaUIPanel:setBeiBiState(isShow)
	if isShow then
		self.big_btn:setDisable(false)
		self.samll_btn:setDisable(false)
	else
		self.big_btn:setDisable(true)
		self.samll_btn:setDisable(true)
	end
end

--运行状态
function ShuiGuoLaBaUIPanel:runState()
	self.state = 1
	self:celanAllRetain()
	self:updateDeFen(0)
	self:removeMultipleEffect()
	self.start_btn:setDisable(true)
	self.bank_btn:setDisable(true)
	self.m_buttonMgr:cleanCurrentButton()
	self.m_btnflow:setVisible(false)
	local btn_list = self.m_buttonMgr:getButtonList()
	for i=1,#btn_list do
		btn_list[i]:setDisable(true)
	end
	self.m_currentBetBtn = nil
end
--清除
function ShuiGuoLaBaUIPanel:cleanDesktop()
	self:removeAllBet()
	self:removeMultipleEffect()
	self:cleanMultipleTotal()
	self:updateYaFen()
	self:removeShadow()
	self.dataController:cleanOldDatas()
end
function ShuiGuoLaBaUIPanel:updateDropItem()
	for i=1,#self.dataController.dropDatas do
		local item = self.dropItemList[i]
		item.icon:loadTexture("sglb_element_2_"..self.dataController.dropDatas[i]..".png",1)
		if i == #self.dataController.dropDatas then
			if item.rect then
				item.rect:setVisible(true)
			else
				local rect =display.newImage("sglb_icon_9.png")
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
function ShuiGuoLaBaUIPanel:getDistanceIndex(index,distance)
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
function ShuiGuoLaBaUIPanel:goStep(beginIndex,value)
	local length = #self.gameItemList
	if value > length then
		value = value % length
	end
	local temp = beginIndex + value
	if temp > length then
		temp = temp - length
	end
	beginIndex = temp
	return beginIndex
end
function ShuiGuoLaBaUIPanel:getdistance(p1,p2)
	local max = #self.gameItemList
	local temp = p1 - p2
	if temp < 0 then
		temp = max - math.abs(temp)
	end
	return temp
end
function ShuiGuoLaBaUIPanel:removeShadow()
	for i=1,#self.gameItemList do
		self.gameItemList[i]:disappear() 
	end
end
function ShuiGuoLaBaUIPanel:removeNotRetainShadow()
	for i=1,#self.gameItemList do
		local gameimage = self.gameItemList[i]
		if not gameimage.isRetain then
			gameimage:disappear()
		end
	end
end
function ShuiGuoLaBaUIPanel:celanAllRetain()
	for i=1,#self.gameItemList do
		self.gameItemList[i]:removeRetain()
	end
end
--移除下注的筹码
function ShuiGuoLaBaUIPanel:removeAllBet()
	-- local moveToPs = nil
	-- if isWin then
	-- 	moveToPs = cc.p(10,10)
	-- else
	-- 	moveToPs = cc.p(D_SIZE.width/2,D_SIZE.height + 20)
	-- end
	-- for i=1,#self.betItemList do
	-- 	local sprite = self.betItemList[i]
	-- 	sprite:runAction(cc.Sequence:create({
	-- 	cc.MoveTo:create(0.4,moveToPs),
	-- 	cc.CallFunc:create(function(sender)
	-- 		sender:removeFromParent(true)
	-- 	end)}))
	-- end
	for i=1,#self.betItemList do
		self.betItemList[i]:removeFromParent(true)
	end
	self.betItemList = {}
end
--移除下注特效
function ShuiGuoLaBaUIPanel:removeMultipleEffect()
	for i=1,#self.multipleList do
		self.multipleList[i]:removeEffect()
	end	
end
function ShuiGuoLaBaUIPanel:cleanMultipleTotal()
	for i=1,#self.multipleList do
		self.multipleList[i]:setTotalValue(0)
	end
end
function ShuiGuoLaBaUIPanel:playMultipleEffect(sid)
	for i=1,#self.multipleList do
		if self.multipleList[i]:getSid() == sid then
			self.multipleList[i]:playEffect()
		end
	end	
end
function ShuiGuoLaBaUIPanel:showAction(id)
	local config = self.effect_config[id]
	if config.sound then
		SoundsManager.playSound(config.sound)
	end
	local action_layout = display.newLayout(cc.size(578,591))
	action_layout:setPosition(cc.p(391,117))
	self.main_layout:addChild(action_layout,1)
	local icon_image = display.newImage(config.imageurl)
	icon_image:setPosition(cc.p(578/2,591/2))
	action_layout:addChild(icon_image)

	local sprite = display.newSprite()
	sprite:setScaleX(config.setScaleX)
	sprite:setScaleY(config.setScaleY)
	sprite:setPosition(config.position)
	icon_image:addChild(sprite)
	icon_image:runAction(cc.RepeatForever:create(cc.Sequence:create({
    	cc.ScaleTo:create(1,1.5),
    	cc.ScaleTo:create(1,1)
    })))
	sprite:runAction(resource.getAnimateByKey(config.actionName,true))
	action_layout:runAction(cc.Sequence:create({
		cc.DelayTime:create(2),
		cc.CallFunc:create(function(sender)
			action_layout:removeFromParent(true)
		end)}))
end
function ShuiGuoLaBaUIPanel:showRandomAction()
	if self.random_acton_handler then return end
	SoundsManager.playSound("sglb_lucky",true)
	self.random_acton_handler = self.main_layout:runAction(cc.RepeatForever:create(cc.Sequence:create({
    	cc.CallFunc:create(function()
    		for i=1,#self.gameItemList do
    			if i%2 == 1 then
    				self.gameItemList[i]:blink()
    			else
    				self.gameItemList[i]:disappear()
    			end
    		end
    	end),
    	cc.DelayTime:create(0.2),
    	cc.CallFunc:create(function()
    	    for i=1,#self.gameItemList do
    			if i%2 == 0 then
    				self.gameItemList[i]:blink()
    			else
    				self.gameItemList[i]:disappear()
    			end
    		end	
    	end),
    	cc.DelayTime:create(0.2)
    })))
end
function ShuiGuoLaBaUIPanel:stopRandomAction()
	if self.random_acton_handler then
		SoundsManager.stopAudio("sglb_lucky")
		self.main_layout:stopAction(self.random_acton_handler)
		self.random_acton_handler = nil
	end
	self:removeNotRetainShadow()
end
function ShuiGuoLaBaUIPanel:beiChiLe()
	SoundsManager.playSound("sglb_dx_lose")
	local sprite = display.newSprite("sglb_icon_11.png")
	sprite:setScale(0.2)
	sprite:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2 + 100))
	self.main_layout:addChild(sprite,4)
	sprite:runAction(cc.Sequence:create({
		cc.ScaleTo:create(0.4,1.5),
		cc.ScaleTo:create(0.2,1.2),
		cc.DelayTime:create(1.5),
		cc.CallFunc:create(function(sender)
			sender:removeFromParent(true)
		end)}))
end
function ShuiGuoLaBaUIPanel:updateGold()
	print("Player.gold-------------------------",Player.gold)
	self.self_gold_label:setString(Player.gold)
end
function ShuiGuoLaBaUIPanel:getAreaSound()
	local soundName = nil
	local bet_datas = self.dataController:getBetDatas()
	if not bet_datas then
		return
	end
	for i=1,#bet_datas do
		local bet_id = bet_datas[i].sid
		for b=1,#self.content_data.result_indexs do
			local result_id = self.gameItemList[self.content_data.result_indexs[b]]:getData().tureSid
			if bet_id == result_id then
				soundName = "Game05_area_"..bet_id
				break
			end
		end
	end
	print("soundName-----------------------------------------",soundName)
	return soundName
end
function ShuiGuoLaBaUIPanel:effectDefen()
	self.defen_rect:stopAllActions()
	self.defen_rect:setVisible(true)
	self.defen_rect:runAction(cc.RepeatForever:create(cc.Sequence:create({
			cc.FadeIn:create(0.5),
            cc.FadeOut:create(0.5)})))
	self.defen_rect:runAction(cc.Sequence:create({
			cc.DelayTime:create(3),
	            cc.CallFunc:create(function(sender)
                self.defen_rect:setVisible(false)
            end)}))
end

function ShuiGuoLaBaUIPanel:updateYaFen()
	mlog("updateYaFen....")
	self.yafen_label:setString(self.dataController:getBetAllMoney())
end
function ShuiGuoLaBaUIPanel:updateDeFen(value)
	self.defen_label:setString(value)
end
function ShuiGuoLaBaUIPanel:onCleanup()
	self.dataController:init()
	self:removeAllEvent()
end

return ShuiGuoLaBaUIPanel
