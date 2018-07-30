--[[
*	赢分榜 层
*	@author：lqh
]]
local WinnerLeaderBoardLayout = class("WinnerLeaderBoardLayout",require("src.base.extend.CCLayerExtend"),function() 
	local container = display.setS9(display.newImage("p_panel_1001.png"),cc.rect(20,20,30,30),cc.size(790,440))
	container:setTouchEnabled(true)
	return container
end)
--排行item 
local BoardItem = class("SignItem",function() 
	local container = display.newLayout(cc.size(780,70))
	return container
end)
BoardItem.index = 1

function WinnerLeaderBoardLayout:ctor()
	self:super("ctor")
	BoardItem.index = 1
	
	local txtimage = display.newImage("p_ui_1040.png")
	self:addChild(Coord.ingap(self,txtimage,"LL",30,"TB",-80))
	local txtimage1 = display.newImage("p_ui_1041.png")
	self:addChild(Coord.outgap(txtimage,txtimage1,"RL",20,"CC",0))
	local txtimage2 = display.newImage("p_ui_1043.png")
	self:addChild(Coord.outgap(txtimage1,txtimage2,"RL",150,"CC",0))
	
	local looplist = require("src.base.control.LoopListView").new(nil,10)
	looplist:setContentSize(cc.size(780,360))
	self:addChild(Coord.ingap(self,looplist,"CC",0,"BB",5))
	
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			params.target:setData(params.data)
		elseif params.event == looplist.EVT_NEW then
			--新创建
			return BoardItem.new(params.data)
		end
	end)
	--测试数据
	local testdatas = {}
	for i = 1,100 do
		testdatas[i] = {
			rank = i,
			name = "我是大哥 " .. i,
			gold = math.random(1000,100000000)
		}
	end
	looplist:setDatas(testdatas)
	looplist:excute()
	
	--线
	self:addChild(Coord.outgap(
		looplist,
		display.setS9(display.newImage("p_ui_1049.png"),cc.rect(110,1,1,2),cc.size(780,5)),
		"CC",0,"TB",1
	))
end

function WinnerLeaderBoardLayout:onCleanup()
end

-- --------------------------------class item---------------------------------
function BoardItem:ctor(data)
	if BoardItem.index%2 == 0 then
		self:addChild(Coord.ingap(self,display.setS9(display.newImage("p_panel_1003.png"),cc.rect(2,2,28,28),cc.size(780,70)),"CC",0,"CC",0))
	end
	BoardItem.index = BoardItem.index + 1 
	
	local rankbg = display.newImage("p_ui_1029.png")
	self:addChild(Coord.ingap(self,rankbg,"LC",75,"CC",0))
	local ranktxt = display.newText("",24,cc.c3b(0x2e,0x07,0))
	rankbg:addChild(Coord.ingap(rankbg,ranktxt,"CC",0,"CC",0))
	
	local nametxt = display.newText("",34)
	nametxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(rankbg,nametxt,"CL",80,"CC",0))
	
	local goldicon = display.newImage("p_ui_1028.png")
	self:addChild(Coord.ingap(self,goldicon,"RL",-350,"CC",0))
	local goldtxt = display.newText("",34)
	goldtxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(goldicon,goldtxt,"RL",5,"CC",0))
	
	self.m_rankbg = rankbg
	self.m_ranktxt = ranktxt
	self.m_nametxt = nametxt
	self.m_goldtxt = goldtxt
	self:setData(data)
end
function BoardItem:setData(data)
	self.m_data = data
	if data.rank <= 3 then
		self.m_rankbg:loadTexture("p_ui_" .. 1030 + (data.rank - 1) .. ".png",1)
		self.m_ranktxt:setString("")
	else
		self.m_rankbg:loadTexture("p_ui_1029.png",1)
		self.m_ranktxt:setString(data.rank)
	end
	self.m_nametxt:setString(data.name)
	self.m_goldtxt:setString(string.thousandsformat(data.gold))
	
end
-- ---------------------------------------------------------------------------

return WinnerLeaderBoardLayout