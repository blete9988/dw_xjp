--[[
*	百人牛牛 下注层
*	@author：lqh
]]
local BetLayout = class("BetLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
end)

function BetLayout:ctor()
	self:super("ctor")
	
	--初始化4个下注区域
	local config = {ST.TYPE_GAMEBRNN_PLAYER_HEI,ST.TYPE_GAMEBRNN_PLAYER_HONG,ST.TYPE_GAMEBRNN_PLAYER_YING,ST.TYPE_GAMEBRNN_PLAYER_FANG}
	local item,temp,betTxt,mineBetTxt,pos
	local structs = {}
	for i = 1,#config do
		item = display.newLayout(cc.size(195,160))
		item:setTouchEnabled(true)
		item:addTouchEventListener(handler(self,self.m_betArearTouchCallback))
		if not temp then
			self:addChild(Coord.ingap(self,item,"CR",-265,"CC",26))
		else
			self:addChild(Coord.outgap(temp,item,"RL",46,"CC",0))
		end
		item.type = config[i]
		temp = item
		--下注额显示
		betTxt = display.newRichText(0,28,Color.GREEN)
		betTxt:enableShadow(cc.c4b(0,0,0,255),cc.size(2,-3))
		betTxt.value = 0
		item:addChild(Coord.ingap(item,betTxt,"CC",0,"TB",24))
		
		mineBetTxt = display.newText("",22,Color.YELLOW)
		mineBetTxt.value = 0
		item:addChild(Coord.outgap(betTxt,mineBetTxt,"CC",0,"BC",-12))
		pos = cc.p(item:getPosition())
		pos.x = pos.x + 25
		pos.y = pos.y + 20
		
		structs[config[i]] = {
			toucharea = item,
			allbetTxt = betTxt,
			minebetTxt = mineBetTxt,
			rect = cc.rect(pos.x,pos.y,pos.x + 145,pos.y + 120)
		}
	end
	self.m_structs = structs
	
	local goldicon = display.newImage("ui_brnn_1031.png")
	self:addChild(Coord.ingap(self,goldicon,"CR",-125,"TT",-135))
	--总下注额
	local allbetTxt = display.newRichText(display.trans("##4009",0),28,Color.GREEN)
	allbetTxt:setAnchorPoint( cc.p(0,0.5) )
	allbetTxt:enableShadow(cc.c4b(0,0,0,255),cc.size(2,-3))
	self:addChild(Coord.outgap(goldicon,allbetTxt,"RL",5,"CC",3))
	self.m_allbetTxt = allbetTxt
	--剩余下注额
	local surplusTxt = display.newText(display.trans("##4010",0),24,Color.GREEN)
	surplusTxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(allbetTxt,surplusTxt,"LL",0,"BT",-3))
	self.m_surplusTxt = surplusTxt
	
	local masterLimitTxt = display.newText(display.trans("##4015",0),24,cc.c3b(0x16,0x62,0x07))
	self:addChild(Coord.outgap(goldicon,masterLimitTxt,"CC",420,"CC",-40)) 
	self.m_masterLimitTxt = masterLimitTxt
	--筹码层
	local betlayer = display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
	self:addChild(betlayer)
	self.m_betlayer = betlayer
end
function BetLayout:updateMasterGoldLimitTxt()
	local mastergold = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().masterGoldLimit
	self.m_masterLimitTxt:setString(display.trans("##4015",string.cnspNmbformat(mastergold)))
end
--下注区域点击回掉
function BetLayout:m_betArearTouchCallback(t,e)
	if e ~= ccui.TouchEventType.ended then return end
	local gameMgr = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance()
	
	if not display.checkGold(10000) then 
		--低于10000金币提示充值
		return
	elseif gameMgr:isMaster() then
		--庄家不能下注
		display.showMsg(display.trans("##20004"))
		return
	elseif gameMgr.initstatus == ST.TYPE_GAMEBRNN_ON_BET then
		--进入房间正在下注
		display.showMsg(display.trans("##20001"))
		return
	elseif gameMgr.gamestatus == ST.TYPE_GAMEBRNN_WAIT then
		--现在是下注等待中，禁止下注
		display.showMsg(display.trans("##20002"))
		return
	end
	
	local betStruct = gameMgr.currentBet
	
	if betStruct.value then
		--下注请求
		ConnectMgr.connect("src.games.bairenniuniu.connect.Brnn_BetConnect" , betStruct.value,t.type,function(result) 
			if result ~= 0 then return end
			SoundsManager.playSound("brnn_add_bet")
			self:addBet(betStruct.value,t.type,betStruct.pos,0,true)
			gameMgr:addBetRecord(t.type,betStruct.value,betStruct.pos)
		end)
	end
end

--[[
*	添加筹码
]]
function BetLayout:addBet(value,type,startPoint,delay,isself,realvalue)
	startPoint = startPoint or self:getStartPoint()
	delay = delay or 0
	
	local betsp = display.newSprite(string.format("bet_%s.png",value))
	betsp:setScale(0.5)
	betsp:setPosition(startPoint)
--	betsp:setOpacity(200)
	self.m_betlayer:addChild(betsp)
	
	local rect = self.m_structs[type].rect
	local pos = cc.p(math.random(rect.x,rect.width),math.random(rect.y,rect.height))
	
	betsp:runAction(cc.Sequence:create({
		cc.DelayTime:create(delay),
--		cc.Spawn:create({
--			cc.FadeIn:create(0.3),
--			cc.EaseExponentialOut:create(cc.MoveTo:create(0.6,pos)),
			cc.MoveTo:create(0.3,pos),
--		}),
		cc.CallFunc:create(function(t) 
			if not t then return end
			if isself then
				self:updateMineBetTxt(type,value)
			else
				if realvalue then
					self:setAllBetTxt(type,realvalue)
				else
					self:updateAllBetTxt(type,value)
				end
			end
		end),
	}))
end
--批量添加筹码
function BetLayout:bathAddBet(data)
	for type,value in pairs(data.areaAllGolds) do
		if data.betlist[type] then
			local delay = math.random(0,20) * 0.01
			local list = data.betlist[type]
			local len = #list
			--将每个区域的所有下注分成5份
			local perlen = 5
			if len <= 5 then perlen = 1 end
			
			for i = 1,5 do
				local pos = self:getStartPoint()
				local temp
				for m = 1,perlen do
					temp = list[(i - 1)*perlen + m]
					if temp then
						if m == perlen or not list[(i - 1)*perlen + m + 1] then
							self:addBet(temp,type,pos,delay,false,data.areaAllGolds[type])
						else
							self:addBet(temp,type,pos,delay)
						end
						pos = self:getRandomRoundPos(pos)
					else
						break
					end
				end
				delay = delay + 0.1
			end
		else
			self:setAllBetTxt(type,value)
		end
	end
end
--批量添加我的投资数据
function BetLayout:bathAddMineBet(data)
	local len = #data
	local delay = 0.5/len
	for i = 1,len do
		self:addBet(data[i].value,data[i].type,data[i].pos,delay*(i - 1),true)
	end
end
--设置每个区域的总下注额
function BetLayout:setAllBetTxt(type,value)
	local txt = self.m_structs[type].allbetTxt
	txt.value = value
	txt:setString(string.thousandsformat(value))
	self:updateBetLimitInfo()
end
--更新每个区域的总下注额
function BetLayout:updateAllBetTxt(type,value)
	local txt = self.m_structs[type].allbetTxt
	txt.value = txt.value + value
	txt:setString(string.thousandsformat(txt.value))
	self:updateBetLimitInfo()
end
--更新我的下注额
function BetLayout:updateMineBetTxt(type,value)
	local txt = self.m_structs[type].minebetTxt
	txt.value = txt.value + value
	txt:setString(string.thousandsformat(txt.value))
end
--更新下注限制的信息
function BetLayout:updateBetLimitInfo()
	local limit = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().betLimit
	local value = 0
	for k,v in pairs(self.m_structs) do
		value = value + v.allbetTxt.value
	end
	self.m_allbetTxt:setString(display.trans("##4009",string.thousandsformat(value)))
	self.m_surplusTxt:setString(display.trans("##4010",string.thousandsformat(limit - value)))
end
--随机获取指定点周围的点
function BetLayout:getRandomRoundPos(pos)
	local p = cc.p(pos.x,pos.y)
	if p.x < 0 then
		p.x = p.x - math.random(0,50)
	else
		p.x = p.x + math.random(0,50)
	end
	if p.y < 0 then
		p.y = p.y - math.random(0,50)
	else
		p.y = p.y + math.random(0,50)
	end
	return p
end
local dsize = cc.size(D_SIZE.w,D_SIZE.h)
--获取屏幕外的一个随机点
function BetLayout:getStartPoint()
	local startPoint = cc.p(0,0)
	if math.random(1,100)%2 == 0 then
		--上下出筹码
		startPoint.x = math.random(0,dsize.width)
		if math.random(1,100)%2 == 0 then	
			--上
			startPoint.y = dsize.height + 50 + math.random(0,100)
		else
			--下
			startPoint.y = -50 - math.random(0,100)
		end	
	else
		--左右出筹码
		startPoint.y = math.random(-50,dsize.width + 50)
		if math.random(1,100)%2 == 0 then	
			--左
			startPoint.x = -50 - math.random(0,100)
		else
			--右
			startPoint.x = dsize.width + 50 + math.random(0,100)
		end	
	end
	return startPoint
end
--设置等待提示
function BetLayout:setWaitingTips(bool)
	if bool then
		if self.m_waitingtips then return end
		local layout = display.newMask(nil,150)
		self:addChild(Coord.scgap(layout,"CC",0,"CC",0))
		
		local bg = display.setS9(display.newImage("popui_001.png"),cc.rect(160,10,20,40),cc.size(620,97))
		layout:addChild(Coord.ingap(layout,bg,"CC",0,"CC",100))
		bg:addChild(Coord.ingap(bg,display.newImage("ui_brnn_1003.png"),"CC",0,"CC",0))
		self.m_waitingtips = layout
	else
		if not self.m_waitingtips then return end
		self.m_waitingtips:removeFromParent()
		self.m_waitingtips = nil
	end
end
--清理
function BetLayout:clear()
	--清楚所有筹码显示
	self.m_betlayer:removeAllChildren()
	for k,v in pairs(self.m_structs) do
		v.minebetTxt:setString(0)
		v.minebetTxt.value = 0
		v.allbetTxt:setString(0)
		v.allbetTxt.value = 0
	end
	self.m_allbetTxt:setString(display.trans("##4009",0))
	self.m_surplusTxt:setString(display.trans("##4010",0))
end
function BetLayout:onCleanup()
--	self:removeAllEvent()
end
return BetLayout