--[[
*	红黑大战 下注层
*	@author：lqh
]]
local BetLayout = class("BetLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
end)

function BetLayout:ctor()
	self:super("ctor")
	
	--筹码层
	local betlayer = display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
	self:addChild(betlayer)
	self.m_betlayer = betlayer
	
	--415 205
	local config = {
		[ST.TYPE_GAMEHHDZ_BET_BLACK] = {size = cc.size(417,205),coord = {"CR",0,"CB",-35},bgpath = "ui_hhdz_1032.png"},
		[ST.TYPE_GAMEHHDZ_BET_RED] = {size = cc.size(417,205),coord = {"CL",3,"CB",-35},bgpath = "ui_hhdz_1033.png"},
		[ST.TYPE_GAMEHHDZ_BET_OTHERS] = {size = cc.size(838,160),coord = {"CC",2,"CT",-40},bgpath = "ui_hhdz_1034.png"},
	}
	--初始化4个下注区域
	local item,txtbg,betTxt,mineBetTxt
	local structs = {}
	for k,v in pairs(config) do
		item = display.newLayout(v.size)
		item:setTouchEnabled(true)
		item:addTouchEventListener(handler(self,self.m_betArearTouchCallback))
		self:addChild(Coord.ingap(self,item,unpack(v.coord)))
		item.betType = k
		--下注额显示
		txtbg = display.newImage(v.bgpath)
		item:addChild(Coord.ingap(item,txtbg,"LL",2,"TT",-1))
		betTxt = display.newText(0,18)
		betTxt:setAnchorPoint( cc.p(0,0.5) )
		betTxt.value = 0
		txtbg:addChild(Coord.ingap(txtbg,betTxt,"LL",30,"CC",0))
		
		--我的下注额显示
		txtbg =  display.newImage("ui_hhdz_1035.png")
		item:addChild(Coord.ingap(item,txtbg,"RR",-2,"TT",-1))
		txtbg:setVisible(false)
		mineBetTxt = display.newText("",18)
		mineBetTxt:setAnchorPoint( cc.p(1,0.5) )
		mineBetTxt.value = 0
		txtbg:addChild(Coord.ingap(txtbg,mineBetTxt,"RR",-5,"CC",0))
		
		local x,y = item:getPosition()
		local rect
		if k == ST.TYPE_GAMEHHDZ_BET_OTHERS then
			rect = cc.rect(x + 20,y + 60,x + v.size.width - 40,y + v.size.height - 50)
		else
			rect = cc.rect(x + 20,y + 20,x + v.size.width - 40,y + v.size.height - 40)
		end
		structs[k] = {
			toucharea = item,
			allbetTxt = betTxt,
			minebetTxt = mineBetTxt,
			minebetBg = txtbg,
			rect = rect
		}
	end
	self.m_structs = structs
	
	--倒计时
	local ctItem = require("src.games.hongheidazhan.ui.CountDownItem").new()
	self:addChild(Coord.ingap(self,ctItem,"CC",0,"BB",135))
	ctItem:stop()
	self.m_ctItem = ctItem
end
--开始倒计时
function BetLayout:beganCountDown()
	self.m_ctItem:setTargetTimeStamp(require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().openStamp)
end
function BetLayout:stopCountDown()
	self.m_ctItem:stop()
end
--下注区域点击回掉
function BetLayout:m_betArearTouchCallback(t,e)
	if e ~= ccui.TouchEventType.ended then return end
	local gameMgr = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance()
	
	if not display.checkGold(1000) then 
		--低于1000金币提示充值
		return
	elseif gameMgr.initstatus == ST.TYPE_GAMEHHDZ_ON_BET then
		--进入房间正在下注
		display.showMsg(display.trans("##20001"))
		return
	elseif gameMgr.gamestatus == ST.TYPE_GAMEHHDZ_WAIT then
		--现在是下注等待中，禁止下注
		display.showMsg(display.trans("##20002"))
		return
	end
	
	local betStruct = gameMgr.currentBet
	
	if betStruct.value then
		--下注请求
		ConnectMgr.connect("src.games.hongheidazhan.connect.Hhdz_BetConnect" , betStruct.value,t.betType,function(result) 
			if result ~= 0 then return end
			self:addBet(betStruct.value,t.betType,betStruct.pos,0,true)
			gameMgr:addBetRecord(t.betType,betStruct.value,betStruct.pos)
			SoundsManager.playSound("hhdz_add_bet")
		end)
	end
end
--显示胜利区域
function BetLayout:blinkWinArea()
	local result = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().resultMgr:getCuurentResult()
	
	local size,shape
	for k,v in pairs(self.m_structs) do
		if result:isWin(k) then
			size = v.toucharea:getContentSize()
			shape = display.newImage("ui_hhdz_1023.png")
			shape:setOpacity(0)
			display.setS9(shape,cc.rect(50,40,20,20),cc.size(size.width + 40,size.height + 40))
			self:addChild(Coord.outgap(v.toucharea,shape,"CC",0,"CC",0))
			shape:runAction(cc.Sequence:create({
				cc.FadeIn:create(0.6),
				cc.FadeTo:create(0.6,100),
				cc.FadeIn:create(0.6),
				cc.FadeOut:create(0.6),
				cc.CallFunc:create(function(t) 
					if not t then return end
					t:removeFromParent()
				end)
			}))
		end
	end
end
--[[
*	添加筹码
]]
function BetLayout:addBet(value,type,startPoint,delay,isself,realvalue)
	startPoint = startPoint or self:getStartPoint()
	delay = delay or 0
	
	local betsp = display.newSprite(string.format("bet_hhdz_%s.png",value))
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
	local once = false
	for type,value in pairs(data.areaAllGolds) do
		if data.betlist[type] then
			if not once then
				once = true
				SoundsManager.playSound("hhdz_add_bet_bath")
			end
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
end
--更新每个区域的总下注额
function BetLayout:updateAllBetTxt(type,value)
	local txt = self.m_structs[type].allbetTxt
	txt.value = txt.value + value
	txt:setString(string.thousandsformat(txt.value))
end
--更新我的下注额
function BetLayout:updateMineBetTxt(type,value)
	local txt = self.m_structs[type].minebetTxt
	if txt.value == 0 then
		self.m_structs[type].minebetBg:setVisible(true)
	end
	txt.value = txt.value + value
	txt:setString(display.trans("##6003",string.thousandsformat(txt.value)))
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
		bg:addChild(Coord.ingap(bg,display.newImage("ui_hhdz_1012.png"),"CC",0,"CC",0))
		self.m_waitingtips = layout
	else
		if not self.m_waitingtips then return end
		self.m_waitingtips:removeFromParent()
		self.m_waitingtips = nil
	end
end
function BetLayout:setMaskStatus(bool)
	if bool then
		local mask = display.newMask(nil,0)
		self:addChild(Coord.scgap(mask,"CC",0,"CC",0))
		self.m_mask = mask
	elseif self.m_mask then
		self.m_mask:removeFromParent()
		self.m_mask = nil
	end
end
--清理
function BetLayout:clear()
	--清楚所有筹码显示
	self.m_betlayer:removeAllChildren()
	self:setMaskStatus(false)
	self.m_ctItem:stop()
	
	for k,v in pairs(self.m_structs) do
		v.minebetBg:setVisible(false)
		v.minebetTxt:setString("")
		v.minebetTxt.value = 0
		v.allbetTxt:setString(0)
		v.allbetTxt.value = 0
	end
end
function BetLayout:onCleanup()
--	self:removeAllEvent()
end
return BetLayout