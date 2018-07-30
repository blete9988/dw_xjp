--[[
*	大奖榜  层
*	@author：lqh
]]
local GrandRewardBoardLayout = class("GrandRewardBoardLayout",require("src.base.extend.CCLayerExtend"),function() 
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

function GrandRewardBoardLayout:ctor()
	self:super("ctor")
	BoardItem.index = 1
	
	self:addChild(Coord.ingap(self,display.newText(display.trans("##2014"),22,cc.c3b(0xfb,0xb6,0x57)),"LL",0,"TB",6))
	local txtimage = display.newImage("p_ui_1044.png")
	self:addChild(Coord.ingap(self,txtimage,"LL",30,"TB",-80))
	local txtimage1 = display.newImage("p_ui_1045.png")
	self:addChild(Coord.outgap(txtimage,txtimage1,"RL",20,"CC",0))
	local txtimage2 = display.newImage("p_ui_1046.png")
	self:addChild(Coord.outgap(txtimage1,txtimage2,"RL",45,"CC",0))
	local txtimage3 = display.newImage("p_ui_1047.png")
	self:addChild(Coord.outgap(txtimage2,txtimage3,"RL",40,"CC",0))
	
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
	for i = 1,50 do
		testdatas[i] = {
			game = "捕鱼达人",
			name = "我是大哥 " .. i,
			gold = math.random(1000,100000000),
			date = os.time()
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

function GrandRewardBoardLayout:onCleanup()
end

-- --------------------------------class item---------------------------------
function BoardItem:ctor(data)
	if BoardItem.index%2 == 0 then
		self:addChild(Coord.ingap(self,display.setS9(display.newImage("p_panel_1003.png"),cc.rect(2,2,28,28),cc.size(780,70)),"CC",0,"CC",0))
	end
	BoardItem.index = BoardItem.index + 1 
	
	local gamenametxt = display.newText("",24)
	self:addChild(Coord.ingap(self,gamenametxt,"LC",85,"CC",0))
	
	local nametxt = display.newText("",24)
	nametxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(gamenametxt,nametxt,"LC",85,"CC",0))
	
	local goldtxt = display.newText("",24)
	goldtxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(nametxt,goldtxt,"LC",190,"CC",0))
	
	local datetxt = display.newText("",24)
	datetxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(goldtxt,datetxt,"LC",170,"CC",0))
	self.m_gamenametxt = gamenametxt
	self.m_nametxt = nametxt
	self.m_goldtxt = goldtxt
	self.m_datetxt = datetxt
	self:setData(data)
end
function BoardItem:setData(data)
	self.m_data = data
	self.m_gamenametxt:setString(data.game)
	self.m_nametxt:setString(data.name)
	self.m_goldtxt:setString(string.thousandsformat(data.gold))
	self.m_datetxt:setString(os.date("%m月%d日 %H:%M:%S",data.date))
end
-- ---------------------------------------------------------------------------

return GrandRewardBoardLayout