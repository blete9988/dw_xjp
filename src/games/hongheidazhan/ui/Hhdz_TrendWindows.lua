--[[
*	红黑大战 走势window
*	@author：lqh
]]
local Hhdz_TrendWindows = class("Hhdz_TrendWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(869,603))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",0)
	return layer
end)
Hhdz_TrendWindows.hide_forward = false

--走势列表控件
local TrendListItem = class("ListItem",function() 
	return display.newLayout(cc.size(200,33.5))
end)
--牌型列表控件
local TypeListItem = class("ListItem",function() 
	return display.newLayout(cc.size(76,80))
end)

function Hhdz_TrendWindows:ctor()
	self:super("ctor")
	
	display.debugLayout(self)
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),150),"CC",0,"CC",0))
	--底板
	self:addChild(Coord.ingap(self,display.newImage("#game/hongheidazhan/hhdz_trendbg.png"),"CC",0,"CC",0))
	local closebtn = display.newButton("ui_hhdz_1037.png","ui_hhdz_1037.png")
	closebtn:setPressedActionEnabled(true)
	self:addChild(Coord.ingap(self,closebtn,"RC",-10,"TC",-30))
	closebtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:executQuit()
	end)
	
	self:m_initProbability()
	self:m_initTrendList()
	
	local looplist_1 = require("src.base.control.LoopListView").new(nil,20)
	looplist_1:setAnchorPoint( cc.p(0.5,0.5) )
	looplist_1:setContentSize(cc.size(60,840))
	looplist_1:setTouchEnabled(false)
	looplist_1:setGap(2)
	looplist_1:setRotation(-90)
	self:addChild(Coord.ingap(self,looplist_1,"CC",0,"TC",-155))
	
	looplist_1:addExtendListener(function(params)
		if params.event == looplist_1.EVT_UPDATE then
			if params.data.blackWin then
				params.target:loadTexture("ui_hhdz_1018.png",1)
			else
				params.target:loadTexture("ui_hhdz_1015.png",1)
			end
		elseif params.event == looplist_1.EVT_NEW then
			if params.data.blackWin then
				return display.newImage("ui_hhdz_1018.png")
			else
				return display.newImage("ui_hhdz_1015.png")
			end
		end
	end)
	looplist_1:setDatas(require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().resultMgr:getResults())
	looplist_1:excute(true,true)
	
	local looplist_2 = require("src.base.control.LoopListView").new(nil,12)
	looplist_2:setAnchorPoint( cc.p(0.5,0.5) )
	looplist_2:setContentSize(cc.size(76,830))
	looplist_2:setTouchEnabled(false)
	looplist_2:setGap(3)
	looplist_2:setRotation(-90)
	self:addChild(Coord.ingap(self,looplist_2,"CC",0,"BC",58))
	
	looplist_2:addExtendListener(function(params)
		if params.event == looplist_2.EVT_UPDATE then
			params.target:setData(params.data)
		elseif params.event == looplist_2.EVT_NEW then
			return TypeListItem.new(params.data)
		end
	end)
	
	local results = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().resultMgr:getResults()
	local datas,temp = {}
	local len = #results
	for i = 1,len,2 do
		temp = {results[i],results[i + 1]}
		table.insert(datas,temp)
		if i + 1 >= len then
			temp.islast = true
		end
	end
	looplist_2:setDatas(datas)
	looplist_2:excute(true,true)
end
--初始化最近20场胜率
function Hhdz_TrendWindows:m_initProbability()
	local layout = display.newLayout(cc.size(840,43))
	self:addChild(Coord.ingap(self,layout,"CC",0,"TT",-80))
	
	local results = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().resultMgr:getResults()
	local index = 1
	local blackWinCount = 0
	for i = #results,1,-1 do
		if results[i].blackWin then
			blackWinCount = blackWinCount + 1
		end
		index = index + 1
		if index > 20 then break end
	end
	local per = blackWinCount/index
	
	local blackWinProgress = display.setS9(display.newImage("ui_hhdz_1021.png"),cc.rect(10,10,110,20),cc.size((840 - 228)*per,41))
	blackWinProgress:setLocalZOrder(1)
	local role = display.newImage("ui_hhdz_1026.png")
	role:setScale(0.6)
	blackWinProgress:addChild(Coord.ingap(blackWinProgress,role,"CC",0,"BB",0,true))
	blackWinProgress:addChild(Coord.ingap(blackWinProgress,display.newText(display.trans("##6002",math.floor(per*100)),24),"RR",-5,"CC",0))
	layout:addChild(Coord.ingap(layout,blackWinProgress,"LL",0,"CC",0))
	
	layout:addChild(Coord.outgap(blackWinProgress,display.newImage("ui_hhdz_1019.png"),"RL",-2,"CC",0))
	
	local redWinProgress = display.setS9(display.newImage("ui_hhdz_1020.png"),cc.rect(10,10,110,20),cc.size((840 - 228)*(1 - per),41))
	redWinProgress:setLocalZOrder(1)
	role = display.newImage("ui_hhdz_1028.png")
	role:setScale(0.6)
	redWinProgress:addChild(Coord.ingap(redWinProgress,role,"CC",0,"BB",0,true))
	redWinProgress:addChild(Coord.ingap(redWinProgress,display.newText(display.trans("##6002",100 - math.floor(per*100)),24),"LL",5,"CC",0))
	layout:addChild(Coord.ingap(layout,redWinProgress,"RR",0,"CC",0))
end

function Hhdz_TrendWindows:m_initTrendList()
	--循环列表  670,200
	local looplist = require("src.base.control.LoopListView").new("",22)
	looplist:setTouchEnabled(false)
	looplist:setContentSize(cc.size(200,670))
	looplist:setAnchorPoint( cc.p(0.5,0.5) )
	looplist:setGap(0)
	looplist:setRotation(-90)
	self:addChild(Coord.ingap(self,looplist,"CC",-1,"CC",-43))
	
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			params.target:setData(params.data)
		elseif params.event == looplist.EVT_NEW then
			return TrendListItem.new(params.data)
		end
	end)
	
	local results = require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance().resultMgr:getResults()
	local newlist,tempstruct = {}
	for i = 1,#results do
		if not tempstruct then
			tempstruct = {results[i]}
			table.insert(newlist,tempstruct)
		else
			if tempstruct[1].blackWin then
				if results[i].blackWin then
					table.insert(tempstruct,results[i])
				else
					tempstruct = {results[i]}
					table.insert(newlist,tempstruct)
				end
			else
				if results[i].redWin then
					table.insert(tempstruct,results[i])
				else
					tempstruct = {results[i]}
					table.insert(newlist,tempstruct)
				end
			end
		end
	end
	local datas = self:m_trendTransf(newlist,6)
	
	looplist:setDatas(datas)
	looplist:excute(true,true)
end
--对路子数据变换，就是他妈的拐弯
function Hhdz_TrendWindows:m_trendTransf(srcdatas,maxlen)
	local newdatas = {}
	local struct,temp,len,tempIndex
	local index = 0
	
	local function getStruct(index)
		local t = newdatas[index]
		if not t then
			t = {}
			newdatas[index] = t
		end
		return t
	end
	
	for i = 1,#srcdatas do
		temp = srcdatas[i]
		index = index + 1
		
		while true do
			struct = getStruct(index)
			if struct[1] then
				index = index + 1
			else
				break
			end
		end
		
		len = #temp
		for m = 1,#temp do
			if m > maxlen then
				struct = getStruct(index + m - maxlen)
				struct[maxlen] = temp[m]
			elseif struct[m] then
				tempIndex = index + 1
				for n = m,len do
					struct = getStruct(tempIndex)
					struct[m - 1] = temp[n]
					tempIndex = tempIndex + 1
				end
				break
			else
				struct[m] = temp[m]
			end
		end
	end
	
	return newdatas
end
function Hhdz_TrendWindows:onCleanup()
	self:super("onCleanup")
end

-- --------------------------------ListItem Class------------------------------
function TrendListItem:ctor(data)
	self:setData(data)
end
function TrendListItem:setData(data)
	self:removeAllChildren()
	local pos = cc.p(200 - 16.7,33.5*0.5)
	local icon 
	for i = 1,6 do
		if data[i] then
			if data[i]:isWin(ST.TYPE_GAMEHHDZ_BET_BLACK) then
				icon = display.newSprite("ui_hhdz_1017.png")
			else
				icon = display.newSprite("ui_hhdz_1014.png")
			end
			icon:setPosition(pos)
			self:addChild(icon)
		end
		pos.x = pos.x - 33.3
	end
end
-- ----------------------------------------------------------------------------
-- --------------------------------TypeListItem Class------------------------------
function TypeListItem:ctor(data)
	self:setData(data)
end
function TypeListItem:setData(data)
	self:removeAllChildren()
	local pos = cc.p(57,40)
	local icon 
	for i = 1,2 do
		if data[i] then
			icon = display.newSprite(string.format("poker_type_trend_rotate_%s.png",data[i].groupType))
			icon:setPosition(pos)
			self:addChild(icon)
		end
		pos.x = pos.x - 38
	end
	if data.islast then
		local newimg = display.newSprite("ui_hhdz_1022.png")
		newimg:setRotation(90)
		icon:addChild(Coord.ingap(icon,newimg,"RC",0,"BC",3))
	end
end
-- --------------------------------------------------------------------------------

return Hhdz_TrendWindows