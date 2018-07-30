--[[
*	百人牛牛 走势window
*	@author：lqh
]]
local Brnn_TrendWindows = class("Brnn_TrendWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(1086,580))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",-20)
	return layer
end)
Brnn_TrendWindows.hide_forward = false

--列表控件
local ListItem = class("ListItem",function() 
	return display.newLayout(cc.size(380,90))
end)
--结果统计空间
local ResultItem = class("ResultItem",function() 
	return display.newLayout(cc.size(160,80))
end)

function Brnn_TrendWindows:ctor()
	self:super("ctor")
	self:addEvent(ST.COMMAND_GAMEBRNN_POKER_OVER)
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),150),"CC",0,"CC",20))
	--底板
	self:addChild(Coord.ingap(self,display.setS9(display.newImage("brnn_panel_1001.png"),cc.rect(20,20,80,80),cc.size(1086,580)),"CC",0,"CC",0))
	--标题
	self:addChild(Coord.ingap(self,display.newImage("ui_brnn_1010.png"),"CC",0,"TT",-25))
	
	local closebtn = display.newButton("ui_brnn_1057.png","ui_brnn_1063.png")
	self:addChild(Coord.ingap(self,closebtn,"RR",-8,"TT",-8))
	closebtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:executQuit()
	end)
	
	--循环列表
	local looplist = require("src.base.control.LoopListView").new("",14)
	looplist:setContentSize(cc.size(800,380))
	looplist:setAnchorPoint( cc.p(0.5,0.5) )
	self:addChild(Coord.ingap(self,looplist,"CC",0,"BB",100))
	self.m_looplist = looplist
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			params.target:setData(params.data)
		elseif params.event == looplist.EVT_NEW then
			return ListItem.new(params.data)
		end
	end)
	
	local tempicon = display.newImage("ui_brnn_1016.png")
	self:addChild(Coord.outgap(looplist,tempicon,"LR",-20,"TC",-47.5))
	tempicon = Coord.outgap(tempicon,display.newImage("ui_brnn_1022.png"),"CC",0,"CC",-95)
	self:addChild(tempicon)
	tempicon = Coord.outgap(tempicon,display.newImage("ui_brnn_1020.png"),"CC",0,"CC",-95)
	self:addChild(tempicon)
	tempicon = Coord.outgap(tempicon,display.newImage("ui_brnn_1018.png"),"CC",0,"CC",-95)
	self:addChild(tempicon)
	
	--虚线框
	tempicon = display.newImage("ui_brnn_1026.png")
	tempicon:setScaleY(1.08)
	self:addChild(Coord.outgap(looplist,tempicon,"RL",15,"CC",0))
	
	--最新一条结果
	local newResultItem = ListItem.new(require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().resultMgr:getCuurentResult())
	newResultItem:setAnchorPoint( cc.p(0.5,0.5) )
	self:addChild(Coord.outgap(tempicon,newResultItem,"CC",0,"CC",0))
	newResultItem:setRotation(-90)
	self:addChild(Coord.outgap(tempicon,display.newImage("ui_brnn_1025.png"),"LL",0,"TT",0,true))
	self.m_newResultItem = newResultItem
	
	looplist:setContentSize(cc.size(380,800))
	looplist:setRotation(-90)
	local datas = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().resultMgr:getResults()
	local len = #datas
	table.remove(datas,len)
	len = len - 1
	
	if len < 14 then
		for i = len + 1,14 do
			datas[i] = {}
		end
	end
	looplist:setDatas(datas)
	looplist:excute(true,len >= 8)
	
	local dayResult = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().resultMgr.dayResult
	--当日局数文本
	local allRoundTxt = display.newRichText(display.trans("##4006",display.trans("##4005",dayResult.allRound)))
	self:addChild(Coord.ingap(self,allRoundTxt,"LL",40,"BB",40))
	self.m_allRoundTxt = allRoundTxt
	local heiItem = ResultItem.new("ui_brnn_1016.png",dayResult.heiWinCount,dayResult.heiLostCount)
	self:addChild(Coord.outgap(allRoundTxt,heiItem,"LL",200,"CC",0))
	local hongItem = ResultItem.new("ui_brnn_1022.png",dayResult.hongWinCount,dayResult.hongLostCount)
	self:addChild(Coord.outgap(heiItem,hongItem,"RL",45,"CC",0))
	local yingItem = ResultItem.new("ui_brnn_1020.png",dayResult.yingWinCount,dayResult.yingLostCount)
	self:addChild(Coord.outgap(hongItem,yingItem,"RL",45,"CC",0))
	local fangItem = ResultItem.new("ui_brnn_1018.png",dayResult.fangWinCount,dayResult.fangLostCount)
	self:addChild(Coord.outgap(yingItem,fangItem,"RL",45,"CC",0))
	
	self.m_heiItem = heiItem
	self.m_hongItem = hongItem
	self.m_yingItem = yingItem
	self.m_fangItem = fangItem
end

--@override
function Brnn_TrendWindows:handlerEvent(event,arg)
	if event == ST.COMMAND_GAMEBRNN_POKER_OVER then
		local resultMgr = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().resultMgr
		self.m_newResultItem:setData(resultMgr:getCuurentResult())
		
		local datas = resultMgr:getResults()
		local len = #datas
		len = len - 1
		if len <= 14 then
			self.m_looplist:updataData(len,datas[len])
		else
			self.m_looplist:appendDatas({datas[len]},true)
		end
		
		local dayResult = resultMgr.dayResult
		
		self.m_allRoundTxt:setString(display.trans("##4006",display.trans("##4005",dayResult.allRound)))
		self.m_heiItem:updata(dayResult.heiWinCount,dayResult.heiLostCount)
		self.m_hongItem:updata(dayResult.hongWinCount,dayResult.hongLostCount)
		self.m_yingItem:updata(dayResult.yingWinCount,dayResult.yingLostCount)
		self.m_fangItem:updata(dayResult.fangWinCount,dayResult.fangLostCount)
	end
end

function Brnn_TrendWindows:onCleanup()
	self:super("onCleanup")
end

-- --------------------------------ListItem Class------------------------------
function ListItem:ctor(data)
	local pos = cc.p(47.5,45)
	self.iconlist = {}
	local tempbg,icon 
	for i = 1,4 do
		tempbg = display.newSprite("ui_brnn_1062.png")
		tempbg:setPosition(pos)
		self:addChild(tempbg)
		icon = display.newSprite()
		icon:setRotation(90)
		icon:setPosition(pos)
		self:addChild(icon)
		self.iconlist[i] = icon
		pos.x = pos.x + 95
	end
	self:setData(data)
end
function ListItem:setData(data)
	if not next(data) then
		for i = 1,#self.iconlist do
			self.iconlist[i]:setTexture("")
		end
	else
		local temp = self.iconlist[4]
		if data.heiWin then
			temp:setSpriteFrame("ui_brnn_1023.png")
		else
			temp:setSpriteFrame("ui_brnn_1024.png")
		end
		temp = self.iconlist[3]
		if data.hongWin then
			temp:setSpriteFrame("ui_brnn_1023.png")
		else
			temp:setSpriteFrame("ui_brnn_1024.png")
		end
		temp = self.iconlist[2]
		if data.yingWin then
			temp:setSpriteFrame("ui_brnn_1023.png")
		else
			temp:setSpriteFrame("ui_brnn_1024.png")
		end
		temp = self.iconlist[1]
		if data.fangWin then
			temp:setSpriteFrame("ui_brnn_1023.png")
		else
			temp:setSpriteFrame("ui_brnn_1024.png")
		end
	end
end
-- ----------------------------------------------------------------------------
-- ----------------------------------ResultItem class--------------------------
function ResultItem:ctor(path,v1,v2)
--	display.debugLayout(self)
	local headicon = display.newImage(path)
	headicon:setScale(0.9)
	self:addChild(Coord.ingap(self,headicon,"LL",0,"CC",0,true))
	
	local flagpic = display.newImage("ui_brnn_1023.png")
	flagpic:setScale(0.6)
	self:addChild(Coord.ingap(self,flagpic,"RR",0,"CC",20,true))
	
	flagpic = display.newImage("ui_brnn_1024.png")
	flagpic:setScale(0.6)
	self:addChild(Coord.ingap(self,flagpic,"RR",-5,"CC",-20,true))
	
	local winTxt = display.newRichText(display.trans("##4006",0))
	self:addChild(Coord.outgap(headicon,winTxt,"RC",37,"CC",20,true))
	self.m_winTxt = winTxt
	
	local lostTxt = display.newRichText(display.trans("##4006",0))
	self:addChild(Coord.outgap(headicon,lostTxt,"RC",37,"CC",-20,true))
	self.m_lostTxt = lostTxt
	
	self:updata(v1,v2)
end
function ResultItem:updata(v1,v2)
	self.m_winTxt:setString(display.trans("##4006",v1))
	self.m_lostTxt:setString(display.trans("##4006",v2))
end
-- ----------------------------------------------------------------------------
return Brnn_TrendWindows