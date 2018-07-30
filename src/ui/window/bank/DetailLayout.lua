--[[
*	交易明细 层
*	@author：lqh
]]
local DetailLayout = class("DetailLayout",require("src.base.extend.CCLayerExtend"),function() 
	local container = display.newLayout(cc.size(970,385))
	container.m_setVisible = container.setVisible
	container:setTouchEnabled(true)
	return container
end)
--排行item 
local BroadItem = class("SignItem",function() 
	local container = display.newLayout(cc.size(960,70))
	return container
end)
BroadItem.index = 1

function DetailLayout:ctor()
	self:super("ctor")
	BroadItem.index = 1
	
	local txtlabel = display.newText(display.trans("##2018"),24)
	self:addChild(Coord.ingap(self,txtlabel,"LC",130,"TB",-40))
	local txtlabel1 = display.newText(display.trans("##2019"),24)
	self:addChild(Coord.outgap(txtlabel,txtlabel1,"RL",170,"CC",0))
	local txtlabel2 = display.newText(display.trans("##2020"),24)
	self:addChild(Coord.outgap(txtlabel1,txtlabel2,"RL",100,"CC",0))
	local txtlabel3 = display.newText(display.trans("##2021"),24)
	self:addChild(Coord.outgap(txtlabel2,txtlabel3,"RL",90,"CC",0))
	local txtlabel4 = display.newText(display.trans("##2022"),24)
	self:addChild(Coord.outgap(txtlabel3,txtlabel4,"RL",80,"CC",0))
	
	local looplist = require("src.base.control.LoopListView").new(nil,10)
	looplist:setContentSize(cc.size(970,320))
	looplist:setLocalZOrder(2)
	self:addChild(Coord.ingap(self,looplist,"CC",0,"BB",5))
	self.m_looplist = looplist
	
		--线
	self:addChild(Coord.outgap(
		looplist,
		display.setS9(display.newImage("p_ui_1049.png"),cc.rect(110,1,1,2),cc.size(780,5)),
		"CC",0,"TB",3
	))
	
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			params.target:setData(params.data)
		elseif params.event == looplist.EVT_NEW then
			--新创建
			return BroadItem.new(params.data)
		end
	end)
	
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
				elseif readyconnect and self.pageIndex < self.maxPage then
					readyconnect = false
					--松开开始请求后台
					ConnectMgr.connect("normal.TransferRecordConnect" , self.pageIndex,function(params) 
						if params.result ~= 0 then return end
						local recordlist = params.records
						if #recordlist < 20 then
							self.maxPage = self.pageIndex
						else
							self.pageIndex = self.pageIndex + 1
						end
						looplist:appendDatas(recordlist)
					end)
				end
				if not tipsTxt and self.pageIndex < self.maxPage then
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
	
	self:setVisible(true)
end

function DetailLayout:setVisible(bool)
	self:m_setVisible(bool)
	if bool then
		self.maxPage = 10
		self.pageIndex = 1
		ConnectMgr.connect("normal.TransferRecordConnect" , self.pageIndex,function(params) 
		if params.result ~= 0 then return end
		
		local recordlist = params.records
		if #recordlist < 20 then
			self.maxPage = self.pageIndex
		else
			self.pageIndex = self.pageIndex + 1
		end
		self.m_looplist:setDatas(recordlist)
		self.m_looplist:excute()
	end)
	end
end

function DetailLayout:onCleanup()
end

-- --------------------------------class item---------------------------------
BroadItem.config = {
	[0] = "##2023",
	[1] = "##2024",
	[2] = "##2025",
	[3] = "##2063",
	[4] = "##2064",
}
function BroadItem:ctor(data)
	if BroadItem.index%2 == 0 then
		self:addChild(Coord.ingap(self,display.setS9(display.newImage("p_panel_1003.png"),cc.rect(2,2,28,28),cc.size(960,70)),"CC",0,"CC",0))
	end
	BroadItem.index = BroadItem.index + 1 
	
	local datetxt = display.newText("",24)
	datetxt:setAnchorPoint( cc.p(0.5,0.5) )
	self:addChild(Coord.ingap(self,datetxt,"LC",130,"CC",0))
	--收款人
	local targettxt = display.newText("",24)
--	sourcetxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(datetxt,targettxt,"CC",223,"CC",0))
	--汇款人
	local sourcetxt = display.newText("",24)
--	targettxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(targettxt,sourcetxt,"CC",172,"CC",0))
	
	local typetxt = display.newText("",24)
--	typetxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(sourcetxt,typetxt,"CC",152,"CC",0))
	
	local goldtxt = display.newText("",24)
	goldtxt:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(typetxt,goldtxt,"CL",110,"CC",0))
	
	self.m_datetxt = datetxt
	self.m_sourcetxt = sourcetxt
	self.m_targettxt = targettxt
	self.m_typetxt = typetxt
	self.m_goldtxt = goldtxt
	self:setData(data)
end
function BroadItem:setData(data)
	self.m_data = data
	self.m_datetxt:setString(ServerTimer.getDate(data.date,"%m月%d日 %H:%M:%S"))
	self.m_sourcetxt:setString(data.fromID)
	self.m_targettxt:setString(data.toID)
	self.m_typetxt:setString(display.trans(self.config[data.type]))
	self.m_goldtxt:setString(string.thousandsformat(data.gold))
end
-- ---------------------------------------------------------------------------

return DetailLayout