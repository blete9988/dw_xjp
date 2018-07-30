--[[
*	财富榜 层
*	@author：lqh
]]
local WealthLeaderBoardLayout = class("WealthLeaderBoardLayout",require("src.base.extend.CCLayerExtend"),function() 
	local container = display.setS9(display.newImage("p_panel_1001.png"),cc.rect(20,20,30,30),cc.size(1040,540))
	container:setTouchEnabled(true)
	return container
end)
--排行item 
local BoardItem = class("SignItem",function() 
	local container = display.newLayout(cc.size(1020,70))
	return container
end)
BoardItem.index = 1

function WealthLeaderBoardLayout:ctor()
	self:super("ctor")
	BoardItem.index = 1
	
	local txtimage = display.newImage("p_ui_1040.png")
	self:addChild(Coord.ingap(self,txtimage,"LL",30,"TB",-80))
	local txtimage1 = display.newImage("p_ui_1041.png")
	self:addChild(Coord.outgap(txtimage,txtimage1,"RL",100,"CC",0))
	local txtimage2 = display.newImage("p_ui_1042.png")
	self:addChild(Coord.outgap(txtimage1,txtimage2,"RL",300,"CC",0))
	
	local looplist = require("src.base.control.LoopListView").new(nil,10)
	looplist:setLocalZOrder(2)
	looplist:setContentSize(cc.size(1020,460))
	self:addChild(Coord.ingap(self,looplist,"CC",0,"BB",5))
	
	--线
	self:addChild(Coord.outgap(
		looplist,
		display.setS9(display.newImage("p_ui_1049.png"),cc.rect(110,1,1,2),cc.size(1000,5)),
		"CC",0,"TB",1
	))
	
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			params.target:setData(params.data)
		elseif params.event == looplist.EVT_NEW then
			--新创建
			return BoardItem.new(params.data)
		end
	end)
	
	local currentIndex = 1
	local maxy = 0
	local readyconnect = false
	local tipsTxt
	local function scroolEventCallback(t,e)
		if e == ccui.ScrollviewEventType.containerMoved then
			local y = t:getInnerContainer():getPositionY()
			if y > 0 then
				if y > maxy then 
					maxy = y
					readyconnect = true
				elseif readyconnect and currentIndex < 100 then
					readyconnect = false
					--松开开始请求后台
					ConnectMgr.connect("normal.LeaderBoardConnect" , currentIndex,function(params) 
						if params.result ~= 0 then return end
						local playerslist = params.playerslist
						currentIndex = currentIndex + #playerslist
						looplist:appendDatas(playerslist)
					end)
				end
				if not tipsTxt and currentIndex < 100 then
					tipsTxt = display.newText(display.trans("##2054"),28)
					tipsTxt:setLocalZOrder(1)
					self:addChild(Coord.outgap(looplist,tipsTxt,"CC",0,"BB",5))
				end
			else
				if tipsTxt then
					maxy = 0
					tipsTxt:removeFromParent()
					tipsTxt = nil
				end
			end
		end
	end
	
	looplist:addEventListener(scroolEventCallback)
	looplist:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.moved then
			scroolEventCallback(t,ccui.ScrollviewEventType.containerMoved)
		end
	end)
	
	ConnectMgr.connect("normal.LeaderBoardConnect" , currentIndex,function(params) 
		if params.result ~= 0 then return end
		local playerslist = params.playerslist
		currentIndex = currentIndex + #playerslist
		looplist:setDatas(playerslist)
		looplist:excute()
	end)
end

function WealthLeaderBoardLayout:onCleanup()
	
end

-- --------------------------------class item---------------------------------
function BoardItem:ctor(data)
	if BoardItem.index%2 == 0 then
		self:addChild(Coord.ingap(self,display.setS9(display.newImage("p_panel_1003.png"),cc.rect(2,2,28,28),cc.size(1010,70)),"CC",0,"CC",0))
	end
	BoardItem.index = BoardItem.index + 1 
	
	local rankbg = display.newImage("p_ui_1029.png")
	self:addChild(Coord.ingap(self,rankbg,"LC",70,"CC",0))
	local ranktxt = display.newText("",24,cc.c3b(0x2e,0x07,0))
	rankbg:addChild(Coord.ingap(rankbg,ranktxt,"CC",0,"CC",0))
	
	local nametxt = display.newText("",34)
	nametxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(rankbg,nametxt,"CL",150,"CC",0))
	
	local goldicon = display.newImage("p_ui_1009.png")
	goldicon:setScale(0.8)
	self:addChild(Coord.ingap(self,goldicon,"RL",-420,"CC",0,true))
	local goldtxt = display.newText("",34)
	goldtxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(goldicon,goldtxt,"RL",5,"CC",0,true))
	
	self.m_rankbg = rankbg
	self.m_ranktxt = ranktxt
	self.m_nametxt = nametxt
	self.m_goldtxt = goldtxt
	self:setData(data)
end
function BoardItem:setData(data)
	self.m_data = data
	if data.rankIndex <= 3 then
		self.m_rankbg:loadTexture("p_ui_" .. 1030 + (data.rankIndex - 1) .. ".png",1)
		self.m_ranktxt:setString("")
	else
		self.m_rankbg:loadTexture("p_ui_1029.png",1)
		self.m_ranktxt:setString(data.rankIndex)
	end
	self.m_nametxt:setString(data.name)
	self.m_goldtxt:setString(string.thousandsformat(data.gold))
	
end
-- ---------------------------------------------------------------------------

return WealthLeaderBoardLayout