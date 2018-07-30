--[[
*	游戏进行界面
*	@author：gwj
]]
local FightScene = class("FightScene",require("src.base.extend.CCSceneExtend"),IEventListener)
local testList = {cc.p(300,600),cc.p(800,600),cc.p(1300,600)}
local head_Points_900 = {cc.p(835,100),cc.p(465,120),cc.p(165,450),cc.p(470,780),cc.p(835,790),cc.p(1160,785),cc.p(1505,465),cc.p(1165,115)}
local head_Points_1200 = {cc.p(843,175),cc.p(524,205),cc.p(68,605),cc.p(516,999),cc.p(825,1005),cc.p(1137,1005),cc.p(1533,621),cc.p(1241,205)}
local head_Points = nil
-- 观察模式下扑克的坐标
local poker_Points_900 = {
{cc.p(690,100),cc.p(665,100),cc.p(830,270),cc.p(850,270)},
{cc.p(340,110),cc.p(315,110),cc.p(470,270),cc.p(490,270)},
{cc.p(175,590),cc.p(150,590),cc.p(320,450),cc.p(340,450)},
{cc.p(595,800),cc.p(620,800),cc.p(470,630),cc.p(490,630)},
{cc.p(965,800),cc.p(990,800),cc.p(830,630),cc.p(850,630)},
{cc.p(1295,785),cc.p(1320,785),cc.p(1150,630),cc.p(1170,630)},
{cc.p(1480,610),cc.p(1505,610),cc.p(1320,450),cc.p(1340,450)},
{cc.p(1290,110),cc.p(1315,110),cc.p(1150,270),cc.p(1170,270)}
}
local poker_Points_1200 = {
	{cc.p(690,195),cc.p(665,195),cc.p(845,365),cc.p(865,365)},
	{cc.p(375,195),cc.p(350,195),cc.p(505,270),cc.p(525,270)},
	{cc.p(80,750),cc.p(55,750),cc.p(240,605),cc.p(260,605)},
	{cc.p(655,997),cc.p(680,997),cc.p(505,860),cc.p(525,825)},
	{cc.p(965,997),cc.p(990,997),cc.p(845,860),cc.p(865,825)},
	{cc.p(1295,997),cc.p(1320,997),cc.p(1130,860),cc.p(1150,825)},
	{cc.p(1540,770),cc.p(1565,770),cc.p(1355,605),cc.p(1375,605)},
	{cc.p(1390,230),cc.p(1415,230),cc.p(1130,370),cc.p(1150,370)}
}
local poker_Points = nil 
-- 玩家模式下自己扑克的坐标
local PlayerPoker_Points_900 = {cc.p(700,260),cc.p(790,260),cc.p(880,260),cc.p(970,260)}
local PlayerPoker_Points_1200 = {cc.p(710,365),cc.p(800,365),cc.p(890,365),cc.p(980,365)}
local PlayerPoker_Points = nil
local deal_duration = 0.4 --发牌速度
local chip_duration = 0.4 --筹码速度

function FightScene:ctor(dpvalue,users)
	self:super("ctor")
	self:addEvent(ST.COMMAND_FIGHT_PREPARE)
	self:addEvent(ST.COMMAND_FIGHT_FIRSTCARD)
	self:addEvent(ST.COMMAND_FIGHT_ENTERROOM)
	self:addEvent(ST.COMMAND_FIGHT_SENDCARD)
	self:addEvent(ST.COMMAND_FIGHT_ACTION)
	self:addEvent(ST.COMMAND_FIGHT_GROUP)
	self:addEvent(ST.COMMAND_FIGHT_RESULT)
	self:addEvent(ST.COMMAND_FIGHT_REFRESH)
	self:addEvent(ST.COMMAND_FIGHT_QIAO)
	self:addEvent(ST.COMMAND_GOLD_UPDATE)
	self.dpvalue = dpvalue
	self.users = users
	if D_SIZE.height == 900 then
		head_Points = head_Points_900
		poker_Points = poker_Points_900
		PlayerPoker_Points = PlayerPoker_Points_900
	else
		head_Points = head_Points_1200
		poker_Points = poker_Points_1200
		PlayerPoker_Points = PlayerPoker_Points_1200
	end

	-- RecordTeamManager:getInstance():recordInit()
	-- local function scheduleUpdate(dt)
	-- 	RecordTeamManager:getInstance():recordRoom(3)
	-- end
	-- self:scheduleUpdateWithPriorityLua(scheduleUpdate,1)

	self.cardids = {}		--自己拥有牌的ID
	self.chip_items = {}	--桌面上的筹码控件集合
	self.poker_items = {}	--桌面上的扑克控件集合
	self.head_items = {}	--用户控件几何
	local back_img = display.newImage("res/images/fight/"..D_SIZE.height.."/g_background.png",0)
	back_img:setAnchorPoint(cc.p(0,0))
	self:addChild(back_img)
	self.layout = back_img

	local layout_size = self.layout:getContentSize()
	--桌面
	local desktop_bg = display.newImage("res/images/fight/g_bg_11.png",0)
	desktop_bg:setPosition(cc.p(layout_size.width/2 + 40,layout_size.height/2))
	self.layout:addChild(desktop_bg)
	local desktop_size = desktop_bg:getContentSize()
	local begin_px = -20
	local begin_py = desktop_size.height/2
	local quanmang_icon = display.newImage("res/images/fight/g_bg_8.png",0)
	quanmang_icon:setPosition(cc.p(begin_px,begin_py + 80))
	desktop_bg:addChild(quanmang_icon)
	local quanmang_label = display.newText("0",24,Color.WHITE)
	quanmang_label:setAnchorPoint(cc.p(0,0.5))
	quanmang_label:setPosition(cc.p(begin_px + 60,quanmang_icon:getPositionY()))
	desktop_bg:addChild(quanmang_label)

	local xiumang_icon = display.newImage("res/images/fight/g_bg_9.png",0)
	xiumang_icon:setPosition(cc.p(begin_px,begin_py))
	desktop_bg:addChild(xiumang_icon)
	local xiumang_label = display.newText("0",24,Color.WHITE)
	xiumang_label:setAnchorPoint(cc.p(0,0.5))
	xiumang_label:setPosition(cc.p(begin_px + 60,xiumang_icon:getPositionY()))
	desktop_bg:addChild(xiumang_label)

	local zoumang_icon = display.newImage("res/images/fight/g_bg_10.png",0)
	zoumang_icon:setPosition(cc.p(begin_px,begin_py - 80))
	desktop_bg:addChild(zoumang_icon)
	local zoumang_label = display.newText("0",24,Color.WHITE)
	zoumang_label:setAnchorPoint(cc.p(0,0.5))
	zoumang_label:setPosition(cc.p(begin_px + 60,zoumang_icon:getPositionY()))
	desktop_bg:addChild(zoumang_label)

	--UI层
	local ui_Layout = require("src.ui.scene.fight.FightUILayout").new(dpvalue)
	self.layout:addChild(ui_Layout,2)
	self.ui_Layout = ui_Layout
	self.ui_Layout:addEventListener(self.ui_Layout.FIGHTUI_EVENT,function(event,eventtype,parms)
		print("eventtype----------------"..eventtype)
		if eventtype == self.ui_Layout.EVENT_START then
			self:gameStart()
		elseif eventtype == self.ui_Layout.EVENT_RECORD then
			if parms then
				self.head_items[1]:showVoice()
			else
				self.head_items[1]:removeVoice()
			end
		elseif eventtype == self.ui_Layout.EVENT_QUIT then
			self:quit()
		end
	end)
	self:initHead()
	-- self.ui_Layout:showMenu(31,2)
	-- local poker_layout = display.newLayout()
	-- poker_layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	-- self.layout:addChild(poker_layout,3)
	-- self.poker_layout = poker_layout

	-- self:dealStart()
	-- self:rub()
	-- self:branch({30,1,2,3})
end

function FightScene:getTrueUserIndexs()
	local indexs = {}
	local length = #self.head_items
	for i=1,length do
		local user = self.head_items[i]:getUser()
		if user and user.id > 0 then
			table.insert(indexs,i)
		end
	end
	return indexs
end

function FightScene:initHead()
	local length = #head_Points
	for i = 1,length do
		local point = head_Points[i]
		local head_item = require("src.ui.scene.fight.FightHeadItem").new()
		head_item:setPosition(point)
		head_item.index = i
		head_item:addEventListener(head_item.EVENT_TIME_OVER,function(event,sender)
			if sender.user then
				ConnectMgr.connect("fight.FightActionConnect",self.ui_Layout.MENU_TYPE_DIU,0,function(result)
					if result then
						self.ui_Layout:hideMenu()
					end
				end)
			end
		end)
		self.layout:addChild(head_item,1)
		table.insert(self.head_items,head_item)
	end
	local selfIndex = nil --自己的位置
	for i = 2,length do
		local id = self.users[i].id
		if id > 0 then
			if id ~= Player.id then
				self.head_items[i]:setPlayer(self.users[i])
			else
				selfIndex = i
			end
		end
	end
	if selfIndex ~= nil then
		self.head_items[1]:setPlayer(self.users[selfIndex])
		self.head_items[selfIndex]:setPlayer(self.users[1])
	else
		self.head_items[1]:setPlayer(self.users[1])
	end
	if not self.head_items[1]:getUser().isPrepared then
		self.ui_Layout:showPrepare()
	end
end

function FightScene:dealStart(cardids,endfunction)
	self.gameIndex = self.gameIndex + 1
	local user_indexs = self:getTrueUserIndexs()	--获取在坐的用户
	local length = #user_indexs
	local poker_index = 0
	local scheduler=cc.Director:getInstance():getScheduler()
	local function start()
		poker_index = poker_index+1
		if poker_index > length then
			endfunction()
			return 
		end
		--事件计时器回调
		local function simulationComplete()
			timestop(self.PauseResume_pauseEntry)
			self.PauseResume_pauseEntry=nil
			start()
		end
		self:dealActon(user_indexs[poker_index],cardids[poker_index])
		--解析action
		self.PauseResume_pauseEntry = timeup(simulationComplete,deal_duration)
	end
	start()
end

function FightScene:dealActon(index,cardid)
	local sceneSize = self.layout:getContentSize()
	local startingPoint = cc.p(sceneSize.width/2,sceneSize.height/2)
	local poker = require("src.ui.scene.fight.FightPokerItem").new(false)
	poker:setPosition(startingPoint)
	poker:setScale(0.1)
	poker.desktopIndex = index
	self.layout:addChild(poker,1)
	table.insert(self.poker_items,poker)
	local temp_point = nil
	if index == 1 then
		temp_point = PlayerPoker_Points
	else
		temp_point = poker_Points[index]
	end
	if cardid > 0 then
		poker:runAction(cc.ScaleTo:create(deal_duration,1))
	else
		poker:runAction(cc.ScaleTo:create(deal_duration,0.6))
	end
	local array={}
	table.insert(array,cc.MoveTo:create(deal_duration,temp_point[self.gameIndex]))
	table.insert(array,cc.CallFunc:create(
		function(sender)
			if cardid > 0 then
				sender:turn(cardid)
			end
		end))
	poker:runAction(cc.Sequence:create(array))
	AudioEngine.playEffect(resource.sounds["sendCard"].url)
	--local actiontype = cc.EaseBackOut:create(cc.MoveTo:create(deal_duration,testList[index]))
	--poker:runAction(actiontype)
end

function FightScene:getItembyIndex(index)
	local id = self.users[index].id
	local length = #self.head_items
	for i=1,length do
		local user = self.head_items[i]:getUser()
		if user and user.id == id then
			return self.head_items[i]
		end
	end
	return nil
end

function FightScene:getItemById(userid)
	local length = #self.head_items
	for i=1,length do
		local user = self.head_items[i]:getUser()
		if user then
			print("user ids  -----------"..user.id)
		end
		if user and user.id == userid then
			return self.head_items[i]
		end
	end
	return nil
end

function FightScene:getIndexById(id)
	for i=1,#self.users do
		if self.users[i].id == id then
			return i
		end
	end
	return -1
end

function FightScene:getIdByIndex(index)
	return self.users[index].id
end

function FightScene:getSelfUser()
	return self.head_items[1]:getUser()
end

function FightScene:userAction(index,actionType)
	if actionType == self.ui_Layout.MENU_TYPE_DA or actionType == self.ui_Layout.MENU_TYPE_GEN or actionType == self.ui_Layout.MENU_TYPE_QIAO then
		self:chipsBets(index,true)
	elseif  actionType == self.ui_Layout.MENU_TYPE_DIU then
		self:discard(index)
	end
end

function FightScene:quit()
    ConnectMgr.connect("fight.FightQuitConnect",function(result)
		if result then
			-- RecordTeamManager:getInstance():recordRoom(4)
			display.enterScene("src.ui.scene.MainScene")
		end
	end)
end

function FightScene:removeUser()
	local length = #self.head_items
	for i=1,length do
		self.head_items[i]:stopTimer()
		local user = self.head_items[i]:getUser()
		if user and user.id > 0 then
			local ishave = false
			local haveuser = nil
			for n=1,#self.users do
				if self.users[n].id == user.id then
					ishave = true
					haveuser = self.users[n]
					break
				end
			end
			if not ishave then
				if user.id == Player.id then
					self:quit()
				else
					self.head_items[i]:removePlayer()
				end
			else
				self.head_items[i]:isPreparedness(haveuser.isPrepared)
				if user.id == Player.id and not haveuser.isPrepared then
					self.ui_Layout:showPrepare()
				end
			end
		end
	end
end

function FightScene:handlerEvent(event,arg)
	if event == ST.COMMAND_FIGHT_PREPARE then
		print("PREPARE-----------------")
		local item = self:getItemById(arg)
		if item then
			item:isPreparedness(true)
		end
	elseif event == ST.COMMAND_FIGHT_ENTERROOM then
		print("Enter-----------")
		local new_userid = arg[1]
		local index = arg[2]
		print("enter index ---------------"..index)
		self.users[index]:setId(new_userid)
		local item = self.head_items[index]
		local item_user = item:getUser()
		if item_user and item_user.id > 0 then
			local item_index = self:getIndexById(item_user.id)
			self.head_items[item_index]:setPlayer(self.users[index])
		else
			item:setPlayer(self.users[index])
		end
	elseif event == ST.COMMAND_FIGHT_FIRSTCARD then
		local pokerIds = arg[1]
		local banker = arg[2]
		local operationType = arg[3]
		print("banker------------"..banker)
		print("operationType------------"..operationType)
		self:gameStart(pokerIds,banker,operationType)
		print("COMMAND_FIGHT_FIRSTCARD")
	elseif event == ST.COMMAND_FIGHT_SENDCARD then
		self.myPokerIds = arg[1]
		local otherPokerIds = arg[2]
		local banker = arg[3]
		local operationType = arg[4]
		local pokerids = {}
		local item_indexs = self:getTrueUserIndexs()
		for i=1,#item_indexs do
			local poker_index = self:getIndexById(self.head_items[i]:getUser().id)
			table.insert(pokerids,otherPokerIds[poker_index])
		end
		self:dealStart(pokerids,function()
			if operationType ~= 0 then --自己是庄家
				local my_item = self.head_items[1]
				my_item:showTimer()
				self.ui_Layout:showMenu(operationType,self.dpvalue)
			else
				local head_item = self:getItembyIndex(banker)
				head_item:showTimer()
			end
		end)
	elseif event == ST.COMMAND_FIGHT_ACTION then
		local user_index = arg[1]
		local actionType = arg[2]
		local next_index = arg[3]
		local next_actionType = arg[4]
		local value = arg[5]
		print ("value--------------"..value)
		print("user_index-----------"..user_index)
		print("next_index ----------"..next_index)
		local user_id = self:getIdByIndex(user_index)
		print("user_id--------------"..user_id)
		local user_item = self:getItemById(user_id)
		user_item:stopTimer()
		self:userAction(user_item.index,actionType)
		self.dpvalue = value
		if next_index > 0 then
			local next_id = self:getIdByIndex(next_index)
			print("next_id-----------"..next_id)
			local next_item = self:getItemById(next_id)
			next_item:showTimer()
			if self:getSelfUser().id == next_id then
				self.ui_Layout:showMenu(next_actionType,self.dpvalue)
			end
		end
	elseif event == ST.COMMAND_FIGHT_GROUP then
		self:branch(self.myPokerIds)
	elseif event == ST.COMMAND_FIGHT_RESULT then
		local win_index = arg[1]
		local win_score = arg[2]
		local messageStr = ""
		if win_index > 0 then
			win_index = self:getItembyIndex(win_index).index
			if win_index == 1 then
				messageStr = "恭喜您,赢得"..win_score.."积分"
			else
				messageStr = "很遗憾,您输了,请再接再厉"
			end
		else
			messageStr = "这把平局,再来"
		end
		display.showMsg(messageStr)
		self:cleanDesktop(win_index)
	elseif event == ST.COMMAND_FIGHT_REFRESH then
		self.dp = arg[1]
		self.users = arg[2]
		self:removeUser()
	elseif event == ST.COMMAND_FIGHT_QIAO then
		local thirdCardIds = arg[1]
		local fourthCardIds = arg[2]
		self.myPokerIds = arg[3]
		local third_pokerids = {}
		local fourth_pokerids = {}
		local item_indexs = self:getTrueUserIndexs()
		for i=1,#item_indexs do
			local poker_index = self:getIndexById(self.head_items[i]:getUser().id)
			table.insert(third_pokerids,thirdCardIds[poker_index])
			table.insert(fourth_pokerids,fourthCardIds[poker_index])
		end
		if self.gameIndex == 2 then
			self:dealStart(third_pokerids,function()
				self:dealStart(fourth_pokerids,function()
					self:branch(self.myPokerIds)
				end)
			end)
		elseif self.gameIndex == 3 then
			self:dealStart(fourth_pokerids,function()
				self:branch(self.myPokerIds)
			end)
		else
			self:branch(self.myPokerIds)
		end
	elseif event == ST.COMMAND_GOLD_UPDATE then
		self.ui_Layout:updateMoney()
	end
end

function FightScene:gameStart(pokerIds,banker,operationType)
	self.ui_Layout:showStartBtn(false)
	local length = #self.head_items
	for i=1,length do
		self.head_items[i]:isPreparedness(false)
	end
	self.gameIndex = 0
	local sendPokerIds = self:getTrueUserIndexs()
	sendPokerIds[1] = pokerIds[1]	--第一张牌
	local length = #sendPokerIds
	for i = 2,length do
		sendPokerIds[i] = 0 --前面两张都不能看见
	end
	self:qibobo(sendPokerIds)
	local function bankerAction()
		if operationType ~= 0 then --自己是庄家
			local my_item = self.head_items[1]
			my_item:showTimer()
			self.ui_Layout:showMenu(operationType,self.dpvalue)
		else
			local head_item = self:getItembyIndex(banker)
			head_item:showTimer()
		end
	end

	-- 先发两张牌
	timeout(function()
		self:dealStart(sendPokerIds,function()
			sendPokerIds[1] = pokerIds[2]
			self:dealStart(sendPokerIds,bankerAction)
		end)
	end,2)
end



function FightScene:rub()
	local mask = display.newMask()
	mask:setTouchEnabled(true)
	mask:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.ended then
			mask:removeFromParent()
		end
	end)
	self:addChild(mask)

	local poker_img = display.newImage("res/images/fight/g_pk_A_1.png",0)
	poker_img:setScale(2)
	poker_img:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
	mask:addChild(poker_img)

	local poker_back = cc.Sprite:create("res/images/fight/g_poker_back.png")
	poker_back:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
	poker_back:setScale(2)
	local poker_back_size = poker_back:getContentSize()
	local back_begin_px = poker_back:getPositionX()
	local back_begin_py = poker_back:getPositionY()
	local begin_positon = nil

	local function onTouchesBegan(touch,event)
		begin_positon = touch:getLocation()
		return true
	end

	local function onTouchesMoved(touch,event)
		local back_end_px = poker_back:getPositionX()
		local back_end_py = poker_back:getPositionY()
		local rect_ok = poker_back_size.width/2
		if math.abs(back_end_px - back_begin_px) > rect_ok then return end
		if math.abs(back_begin_py - back_end_py) > rect_ok then return end

		local move_positon = touch:getLocation()
		if begin_positon then
			local tempx = math.abs(move_positon.x - begin_positon.x)
			local tempy = begin_positon.y - move_positon.y
			if tempx > tempy then
				if move_positon.x > begin_positon.x then
					poker_back:setPosition(cc.p(back_end_px + tempx/16,poker_back:getPositionY()))
				else
					poker_back:setPosition(cc.p(back_end_px - tempx/16,poker_back:getPositionY()))
				end	
			else
				poker_back:setPosition(cc.p(poker_back:getPositionX(),poker_back:getPositionY() - tempy/4))
			end
		end
	end

	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCH_MOVED)
    local eventDispatcher = poker_back:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener,poker_back)
    mask:addChild(poker_back)
end

function FightScene:branch(pokerids)
	local branch_layout = require("src.ui.scene.fight.FightBranchLayout").new(pokerids)
	self.layout:addChild(branch_layout,3)
end

--起波波
function FightScene:qibobo(indexs)
	AudioEngine.playEffect(resource.sounds["moveChips"].url)
	for i=1,#indexs do
		self:chipsBets(i,true)
	end
end

-- headIndex 头像 isFrist 是否起波波
function FightScene:chipsBets(headIndex,isFrist)
	local head_Point = head_Points[headIndex]
	local chip = display.newImage("res/images/fight/g_bg_13.png",0)
	local c_px = self:getContentSize().width/2 - 50 + math.random()*100
	local c_py = self:getContentSize().height/2 - 50 + math.random()*100
	chip:setPosition(cc.p(head_Point.x,head_Point.y))
	self.layout:addChild(chip)
	local array={}
	table.insert(array,cc.MoveTo:create(chip_duration,cc.p(c_px,c_py)))
	table.insert(array,cc.CallFunc:create(
		function(sender)
			if isFrist then
				table.insert(self.chip_items,sender)
			else
				sender:removeFromParent()
			end
		end))
	chip:runAction(cc.Sequence:create(array))
end

--下一盘时清理桌面上的牌局
function FightScene:cleanDesktop(winHeadIndex)
	local sceneSize = self.layout:getContentSize()
	local startingPoint = cc.p(sceneSize.width/2,sceneSize.height/2)
	local length = #self.poker_items
	for i=1,length do
		local array={}
		table.insert(array,cc.DelayTime:create((i - 1) * 0.1))
		table.insert(array,cc.MoveTo:create(0.2,startingPoint))
		table.insert(array,cc.CallFunc:create(
			function(sender)
				sender:removeFromParent()
			end))
		self.poker_items[i]:runAction(cc.Sequence:create(array))
	end
	self.poker_items = {}
	local head_Point = nil
	if winHeadIndex > 0 then
		head_Point = head_Points[winHeadIndex]
	else
		head_Point = cc.p(D_SIZE.width/2,D_SIZE.height/2)
	end
	length = #self.chip_items
	for i=1,length do
		local array={}
		table.insert(array,cc.DelayTime:create((i - 1) * 0.1))
		table.insert(array,cc.MoveTo:create(0.2,head_Point))
		table.insert(array,cc.CallFunc:create(
			function(sender)
				sender:removeFromParent()
			end))
		self.chip_items[i]:runAction(cc.Sequence:create(array))
	end
	self.chip_items = {}
end

--丢牌
function FightScene:discard(headIndex)
	local sceneSize = self.layout:getContentSize()
	local startingPoint = cc.p(sceneSize.width/2,sceneSize.height/2)
	local isContinue = true
	while(isContinue)
	do
		isContinue = false
		local length = #self.poker_items
   		for i=1,length do
			local pokser = self.poker_items[i]
			if pokser.desktopIndex == headIndex then
				local array={}
				table.insert(array,cc.MoveTo:create(chip_duration,startingPoint))
				table.insert(array,cc.CallFunc:create(
					function(sender)
						sender:removeFromParent()
					end))
				pokser:runAction(cc.Sequence:create(array))
				table.remove(self.poker_items,i)
				isContinue = true
				break
			end
		end
	end
end

function FightScene:onCleanup()
	self:removeAllEvent()
end

return FightScene
