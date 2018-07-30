--[[
*	走势图 层
*	@author：lqh
]]
local TrendLayout = class("TrendLayout",require("src.base.extend.CCLayerExtend"),function() 
	local layout = display.newLayout(cc.size(161,517))
	layout:setBackGroundImage("bjl_ui_1052.png",1)
	display.setBgS9(layout,cc.rect(10,10,140,300))
	return layout
end)

local TrendItem = class("TrendItem",function() 
	return display.newLayout(cc.size(151,36))
end)

function TrendLayout:ctor(father)
	self:super("ctor")
	
	local looplist = require("src.base.control.LoopListView").new(nil,16)
	looplist:setContentSize(cc.size(161,417))
	looplist:setBufferDistance(100)
	looplist:setGap(2)
	self:addChild(Coord.ingap(self,looplist,"CC",-2,"TT",-2))
	looplist:addExtendListener(function(params)
		if params.event == looplist.EVT_UPDATE then
			params.target:setData(params.data)
		elseif params.event == looplist.EVT_NEW then
			return TrendItem.new(params.data)
		end
	end)
	self.m_looplist = looplist
	
	local zhuangWinTxt = display.newRichText(display.trans("##3011",0))
	zhuangWinTxt:setWidth(50)
	zhuangWinTxt:setEdgeSmoothing(false)
	zhuangWinTxt:setHorType("center")
	self:addChild(Coord.ingap(self,zhuangWinTxt,"LL",5,"BB",10))
	
	local xianWinTxt = display.newRichText(display.trans("##3012",0))
	xianWinTxt:setWidth(50)
	xianWinTxt:setEdgeSmoothing(false)
	xianWinTxt:setHorType("center")
	self:addChild(Coord.ingap(self,xianWinTxt,"CC",0,"BB",10))
	
	local pingTxt = display.newRichText(display.trans("##3013",0))
	pingTxt:setWidth(50)
	pingTxt:setEdgeSmoothing(false)
	pingTxt:setHorType("center")
	self:addChild(Coord.ingap(self,pingTxt,"RR",-5,"BB",10))
	
	self.m_zhuangWinTxt = zhuangWinTxt
	self.m_xianWinTxt = xianWinTxt
	self.m_pingTxt = pingTxt
	
	self:initData()
end
function TrendLayout:initData()
	local resultMgr = require("src.games.baijiale.data.Bjl_GameMgr").getInstance().resultMgr
	
	local datas = resultMgr:getResultDatas()
	local len = #datas
	--计算庄，闲，平各个的总次数
	local zhuangCt,xianCt,pingCt = 0,0,0
	for i = 1,len do
		if datas[i].zhuangWin then
			zhuangCt = zhuangCt + 1
		elseif datas[i].xianWin then
			xianCt = xianCt + 1
		else
			pingCt = pingCt + 1
		end
	end
	self.m_zhuangWinTxt:setString(display.trans("##3011",zhuangCt))
	self.m_zhuangWinTxt.m_count = zhuangCt
	self.m_xianWinTxt:setString(display.trans("##3012",xianCt))
	self.m_xianWinTxt.m_count = xianCt
	self.m_pingTxt:setString(display.trans("##3013",pingCt))
	self.m_pingTxt.m_count = pingCt
	
	--不够用空数据补齐
	if len < 16 then
		for i = len + 1,16 do
			datas[i] = {}
		end
	end
	self.m_looplist:setDatas(datas)
	if len >= 10 then
		self.m_looplist:excute(true,true)
	else
		self.m_looplist:excute(true,false)
	end
end
function TrendLayout:updata()
	local resultMgr = require("src.games.baijiale.data.Bjl_GameMgr").getInstance().resultMgr
	local len = resultMgr:geInnings() - 1
	local data = resultMgr:getLastResultData()
	
	local txtitem
	if data.zhuangWin then
		--庄赢
		txtitem = self.m_zhuangWinTxt
		txtitem.m_count = txtitem.m_count + 1
		txtitem:setString(display.trans("##3011",txtitem.m_count))
	elseif data.xianWin then
		--闲赢
		txtitem = self.m_xianWinTxt
		txtitem.m_count = txtitem.m_count + 1
		txtitem:setString(display.trans("##3012",txtitem.m_count))
	else
		--平
		txtitem = self.m_pingTxt
		txtitem.m_count = txtitem.m_count + 1
		txtitem:setString(display.trans("##3013",txtitem.m_count))
	end
	
	if len <= 16 then
		self.m_looplist:updataData(len,data)
	else
		self.m_looplist:appendDatas({data},true)
	end
end

-- ----------------------------------class TrendItem-----------------------------------------
function TrendItem:ctor(data)
	local bg = display.newImage("bjl_panel_1003.png")
	bg:setAnchorPoint(cc.p(0,0))
	bg:setPositionX(2)
	self:addChild( bg)
	
	self:setData(data)
end
function TrendItem:setData(data)
	if self.result then
		self.result:setDisplay(nil)
		self.result = nil
	end
	
	if not next(data) then return end
	
	self.result = data
	data:setDisplay(self)
	
	if self.pic then
		self.pic:removeFromParent()
	end
	
	local pic
	if data.zhuangWin then
		--庄赢
		pic = display.newImage("bjl_ui_1063.png")
		pic:setPosition(cc.p(24,16))
	elseif data.xianWin then
		--闲赢
		pic = display.newImage("bjl_ui_1062.png")
		pic:setPosition(cc.p(78,16))
	else
		--平
		pic = display.newImage("bjl_ui_1064.png")
		pic:setPosition(cc.p(130,16))
	end
	self:addChild(pic)
	
	if data.zhuangDouble then
		--庄对
		pic:addChild(Coord.ingap(pic,display.newImage("bjl_ui_1056.png"),"LL",0,"TT",0))
	end
	
	if data.xianDouble then
		--闲对
		pic:addChild(Coord.ingap(pic,display.newImage("bjl_ui_1055.png"),"RR",0,"BB",0))
	end
	self.pic = pic
	
	self:setShining(data.islast)
end
function TrendItem:setShining(bool)
	if bool then
		if self.shiningPic then return end
		local shiningPic = display.newImage("bjl_ui_1057.png")
		shiningPic:addChild(Coord.ingap(shiningPic,display.newImage("bjl_ui_1012.png"),"LL",5,"TT",-5))
		shiningPic:runAction(cc.RepeatForever:create(
			cc.Sequence:create({
				cc.FadeTo:create(0.8,40),
				cc.FadeTo:create(0.8,200),
			})
		))
		self:addChild(Coord.ingap(self,shiningPic,"CC",0,"CC",0))
		self.shiningPic = shiningPic
	else
		if not self.shiningPic then return end
		self.shiningPic:removeFromParent()
		self.shiningPic = nil
	end
end
-- ------------------------------------------------------------------------------------------

function TrendLayout:onCleanup()
--	self:removeAllEvent()
end
return TrendLayout