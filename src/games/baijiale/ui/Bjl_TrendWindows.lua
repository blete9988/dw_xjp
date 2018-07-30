--[[
*	百家乐 路子window
*	@author：lqh
]]
local Bjl_TrendWindows = class("Bjl_TrendWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(1200,580))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",-20)
	return layer
end)
Bjl_TrendWindows.hide_forward = false

local ListItem = class("ListItem",function() 
	return display.newLayout()
end)

function Bjl_TrendWindows:ctor()
	self:super("ctor")
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),150),"CC",0,"CC",20))
	--底板
	self:addChild(Coord.ingap(self,display.setS9(display.newImage("bjl_panel_1001.png"),cc.rect(20,20,80,80),cc.size(1200,580)),"CC",0,"CC",0))
	--标题
	self:addChild(Coord.ingap(self,display.newImage("bjl_ui_1054.png"),"CC",0,"TB",48))
	--文本说明
	self:addChild(Coord.ingap(self,display.newRichText(display.trans("##3014")),"CC",0,"TB",5))
	
	local closebtn = display.newButton("bjl_ui_1049.png","bjl_ui_1068.png")
	self:addChild(Coord.ingap(self,closebtn,"RR",-8,"TT",-8))
	closebtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:executQuit()
	end)
	
	self:m_initTitle()
	self:m_initTrend()
end
function Bjl_TrendWindows:m_initTitle()
	local temp = display.newImage("bjl_ui_1003.png")
	temp:setScale(1.3)
	self:addChild(Coord.ingap(self,temp,"LL",70,"TT",-20,true))
	local contentLayout = display.newLayout()
	contentLayout:setBackGroundImage("bjl_panel_1002.png",1)
	display.setBgS9(contentLayout,cc.rect(20,20,60,60),cc.size(130,60))
	self:addChild(Coord.outgap(temp,contentLayout,"RL",5,"CC",3,true))
	contentLayout:addChild(Coord.ingap(contentLayout,display.newImage("bjl_ui_1061.png"),"LL",10,"CC",0))
	contentLayout:addChild(Coord.ingap(contentLayout,display.newImage("bjl_ui_1059.png"),"LL",70,"CC",0))
	contentLayout:addChild(Coord.ingap(contentLayout,display.newImage("bjl_ui_1056.png"),"LL",100,"CC",0))
	
	temp = display.newImage("bjl_ui_1002.png")
	temp:setScale(1.3)
	self:addChild(Coord.outgap(contentLayout,temp,"RL",20,"CC",-3,true))
	contentLayout = display.newLayout()
	contentLayout:setBackGroundImage("bjl_panel_1002.png",1)
	display.setBgS9(contentLayout,cc.rect(20,20,60,60),cc.size(130,60))
	self:addChild(Coord.outgap(temp,contentLayout,"RL",5,"CC",3,true))
	contentLayout:addChild(Coord.ingap(contentLayout,display.newImage("bjl_ui_1060.png"),"LL",10,"CC",0))
	contentLayout:addChild(Coord.ingap(contentLayout,display.newImage("bjl_ui_1058.png"),"LL",70,"CC",0))
	contentLayout:addChild(Coord.ingap(contentLayout,display.newImage("bjl_ui_1055.png"),"LL",100,"CC",0))
	
	--计算庄，闲，平，庄对，闲对各个的总次数
	local zhuangCt,xianCt,pingCt,zhuangDouble,xianDouble = 0,0,0,0,0
	local datas = require("src.games.baijiale.data.Bjl_GameMgr").getInstance().resultMgr:getResultDatas()
	for i = 1,#datas do
		if datas[i].zhuangWin then
			zhuangCt = zhuangCt + 1
		elseif datas[i].xianWin then
			xianCt = xianCt + 1
		else
			pingCt = pingCt + 1
		end
		
		if datas[i].zhuangDouble then
			zhuangDouble = zhuangDouble + 1
		elseif datas[i].xianDouble then
			xianDouble = xianDouble + 1
		end
	end
	
	temp = Coord.outgap(contentLayout,display.newRichText(display.trans("##3015",zhuangCt)),"RL",20,"CC",0)
	self:addChild(temp)
	temp = Coord.outgap(temp,display.newRichText(display.trans("##3016",xianCt)),"RL",33,"CC",0)
	self:addChild(temp)
	temp = Coord.outgap(temp,display.newRichText(display.trans("##3017",pingCt)),"RL",33,"CC",0)
	self:addChild(temp)
	temp = Coord.outgap(temp,display.newRichText(display.trans("##3018",zhuangDouble)),"RL",33,"CC",0)
	self:addChild(temp)
	temp = Coord.outgap(temp,display.newRichText(display.trans("##3019",xianDouble)),"RL",33,"CC",0)
	self:addChild(temp)
end
function Bjl_TrendWindows:m_initTrend()
	local resultdatas = require("src.games.baijiale.data.Bjl_GameMgr").getInstance().resultMgr:getResultDatas()
	
	--大路原始数据列表
	local daluSrcDatas = {}
	--珠路数据列表
	local zhuluDatas = {}
	--珠路单竖排数据结构，6个结果为一组
	local zhuluStruct
	--大陆单竖排数据结构
	local daluStruct
	local temp
	for i = 1,#resultdatas do
		temp = resultdatas[i]
		
		if i % 6 == 1 then
			zhuluStruct = {}
			table.insert(zhuluDatas,zhuluStruct)
		end
		table.insert(zhuluStruct,temp)
		
		if not daluStruct then
			if not temp.ping then
				--第一把非平才放入
				daluStruct = {temp}
				table.insert(daluSrcDatas,daluStruct)
			end
		else
			if temp.ping then
				--平，放入当前路
				temp.follow = daluStruct[1]
				table.insert(daluStruct,temp)
			elseif (daluStruct[1].xianWin and temp.xianWin) or (daluStruct[1].zhuangWin and temp.zhuangWin) then
				table.insert(daluStruct,temp)
			else
				daluStruct = {temp}
				table.insert(daluSrcDatas,daluStruct)
			end
		end
	end
	
	local background = self:m_createListBackground(cc.size(1150,210))
	self:addChild(Coord.ingap(self,background,"CC",0,"TT",-95))
	
	--大路
	local listview = display.newListView(ccui.ScrollViewDir.horizontal,nil,nil)
	listview:setContentSize(cc.size(1150,210))
	background:addChild(listview)
	local trendnameTxt = display.newRichText(display.trans("##3020"))
	trendnameTxt:setOpacity(50)
	background:addChild(Coord.ingap(background,trendnameTxt,"CC",0,"CC",0))
	
	local datas = self:m_trendTransf(daluSrcDatas,5)
	local len = #datas
	if len < 20 then 
		len = 20 
	end
	for i = 1,len do
		listview:pushBackCustomItem(ListItem.new(5,datas[i],0))
	end
	if #datas >= len then listview:jumpToRight() end
	
	--珠路
	background = self:m_createListBackground(cc.size(570,252))
	self:addChild(Coord.ingap(self,background,"CL",5,"BB",15))
	
	listview = display.newListView(ccui.ScrollViewDir.horizontal,nil,nil)
	listview:setContentSize(cc.size(570,252))
	background:addChild(listview)
	trendnameTxt = display.newRichText(display.trans("##3021"))
	trendnameTxt:setOpacity(50)
	background:addChild(Coord.ingap(background,trendnameTxt,"CC",0,"CC",0))
	
	len = #zhuluDatas
	if len < 10 then 
		len = 10 
	end
	for i = 1,len do
		listview:pushBackCustomItem(ListItem.new(6,zhuluDatas[i],1))
	end
	if #zhuluDatas >= len then listview:jumpToRight() end
	
	-- 一堆路
	local dayanzaiData,xialluData,yueyouData = self:splitExTrend(daluSrcDatas)
	
	background = self:m_createListBackground(cc.size(570,252))
	self:addChild(Coord.ingap(self,background,"CR",-5,"BB",15))
	--大眼仔路
	listview = display.newListView(ccui.ScrollViewDir.horizontal,nil,nil)
	listview:setContentSize(cc.size(570,81))
	background:addChild(Coord.ingap(background,listview,"CC",0,"TT",-2))
	trendnameTxt = display.newRichText(display.trans("##3022"))
	trendnameTxt:setOpacity(50)
	background:addChild(Coord.outgap(listview,trendnameTxt,"CC",0,"CC",0))
	
	dayanzaiData = self:m_trendTransf(dayanzaiData,3)
	len = #dayanzaiData
	if len < 16 then 
		len = 16 
	end
	for i = 1,len do
		listview:pushBackCustomItem(ListItem.new(3,dayanzaiData[i],2))
	end
	if #dayanzaiData >= len then listview:jumpToRight() end
	--小路
	listview = display.newListView(ccui.ScrollViewDir.horizontal,nil,nil)
	listview:setContentSize(cc.size(570,81))
	background:addChild(Coord.ingap(background,listview,"CC",0,"CC",0))
	trendnameTxt = display.newRichText(display.trans("##3023"))
	trendnameTxt:setOpacity(50)
	background:addChild(Coord.outgap(listview,trendnameTxt,"CC",0,"CC",0))
	
	xialluData = self:m_trendTransf(xialluData,3)
	len = #xialluData
	if len < 16 then 
		len = 16 
	end
	for i = 1,len do
		listview:pushBackCustomItem(ListItem.new(3,xialluData[i],3))
	end
	if #xialluData >= len then listview:jumpToRight() end
	--曱甴路
	listview = display.newListView(ccui.ScrollViewDir.horizontal,nil,nil)
	listview:setContentSize(cc.size(570,81))
	background:addChild(Coord.ingap(background,listview,"CC",0,"BB",2))
	trendnameTxt = display.newRichText(display.trans("##3024"))
	trendnameTxt:setOpacity(50)
	background:addChild(Coord.outgap(listview,trendnameTxt,"CC",0,"CC",0))
	
	yueyouData = self:m_trendTransf(yueyouData,3)
	len = #yueyouData
	if len < 16 then 
		len = 16 
	end
	for i = 1,len do
		listview:pushBackCustomItem(ListItem.new(3,yueyouData[i],4))
	end
	if #yueyouData >= len then listview:jumpToRight() end
end
function Bjl_TrendWindows:m_createListBackground(size,txt)
	local background = display.newLayout()
	background:setBackGroundImage("bjl_panel_1004.png",1)
	display.setBgS9(background,cc.rect(20,20,60,60),size)
	--圆角蒙版
	local edgeMask = display.setS9(display.newImage("bjl_ui_1065.png"),cc.rect(2,20,8,60),cc.size(12,size.height))
	edgeMask:setLocalZOrder(2)
	background:addChild(Coord.ingap(background,edgeMask,"LC",2,"CC",0))
	edgeMask = display.setS9(display.newImage("bjl_ui_1065.png"),cc.rect(2,20,8,60),cc.size(12,size.height))
	edgeMask:setLocalZOrder(2)
	edgeMask:setRotation(180)
	background:addChild(Coord.ingap(background,edgeMask,"RC",-2,"CC",0))
	
	return background
end
--对各种路子数据变换，就是他妈的拐弯
function Bjl_TrendWindows:m_trendTransf(srcdatas,maxlen)
	local newdatas = {}
	local struct,temp
	local index = 0
	--拐弯插入
	local function turnInsert(v,h,beganIndex,list)
		for i = beganIndex,#list do
			if not newdatas[v] then
				newdatas[v] = {}
				newdatas[v][h] = list[i]
				v = v + 1
			else
				newdatas[v][h] = list[i]
				v = v + 1
			end
			if h == 1 then
				index = index + 1
			end
		end
	end
	
	for i = 1,#srcdatas do
		index = index + 1
		
		temp = srcdatas[i]
		if newdatas[index] then
			struct = newdatas[index]
		else
			struct = {}
			table.insert(newdatas,struct)
		end
		
		for m = 1,#temp do
			if m > maxlen or struct[m] then
				if m == 1 then
					turnInsert(index + 1,m,m,temp)
				else
					turnInsert(index + 1,m - 1,m,temp)
				end
				break
			else
				struct[m] = temp[m]
			end
		end
	end
	
	return newdatas
end
--解析各种其他路
function Bjl_TrendWindows:splitExTrend(srcdatas)
	local dayanzaiData = {}
	local xialluData = {}
	local yueyouData = {}
	local beganIndex = 2
	for i = 2,#srcdatas do
		for j = beganIndex,#srcdatas[i] do
			if j == 1 then
				if #srcdatas[i - 1] == #srcdatas[i - 2] then
					table.insert(dayanzaiData,0)
				else
					table.insert(dayanzaiData,1)
				end
				if i > 3 then
					if #srcdatas[i - 1] == #srcdatas[i - 3] then
						table.insert(xialluData,0)
					else
						table.insert(xialluData,1)
					end
				end
				if i > 4 then
					if #srcdatas[i - 1] == #srcdatas[i - 4] then
						table.insert(yueyouData,0)
					else
						table.insert(yueyouData,1)
					end
				end
			else
				if not srcdatas[i - 1][j] then
					if not srcdatas[i - 1][j - 1] then
						table.insert(dayanzaiData,0)
					else
						table.insert(dayanzaiData,1)
					end
				else
					table.insert(dayanzaiData,0)
				end
				if i >= 3 then
					if not srcdatas[i - 2][j] then
						if not srcdatas[i - 2][j - 1] then
							table.insert(xialluData,0)
						else
							table.insert(xialluData,1)
						end
					else
						table.insert(xialluData,0)
					end
				end
				if i >=4 then
					if not srcdatas[i - 3][j] then
						if not srcdatas[i - 3][j - 1] then
							table.insert(yueyouData,0)
						else
							table.insert(yueyouData,1)
						end
					else
						table.insert(yueyouData,0)
					end
				end
			end
		end
		beganIndex = 1
	end
	
	local function formatdata(list)
		local struct = {list[1]}
		local datas = {struct}
		for i = 2,#list do
			if list[i] == struct[1] then
				table.insert(struct,list[i])
			else
				struct = {list[i]}
				table.insert(datas,struct)
			end
		end
		return datas
	end
	dayanzaiData = formatdata(dayanzaiData)
	xialluData = formatdata(xialluData)
	yueyouData = formatdata(yueyouData)
	
	return dayanzaiData,xialluData,yueyouData
end

-- ---------------------------------ListItem---------------------------------------
--不同status采用不同的显示
function ListItem:ctor(len,datas,status)
	datas = datas or {}
	status = status or -1
	local pos = cc.p(30,0)
	local bg
	if status == 0 then
		self:setContentSize(cc.size(60,210))
		bg = display.newImage("bjl_panel_1005.png")
		bg:setAnchorPoint(cc.p(0,1))
	elseif status == 1 then
		self:setContentSize(cc.size(60,252))
		bg = display.newImage("bjl_panel_1006.png")
		bg:setAnchorPoint(cc.p(0,1))
	else
		self:setContentSize(cc.size(36,81))
		bg = display.newImage("bjl_panel_1007.png")
		pos.x = 18
	end
	bg:setAnchorPoint(cc.p(0,0))
	self:addChild(bg)
	
	local pic,icon,temp
	for i = len,1,-1 do
		temp = datas[len - i + 1]
		if temp then
			if status == 0 then
				--大路
				pos.y = 42*(i - 1) + 21
				self:createDaluPic(temp,pos)
			elseif status == 1 then
				--珠路
				pos.y = 42*(i - 1) + 21
				self:createZhuluPic(temp,pos)
			elseif status == 2 then
				--大眼仔路
				pos.y = 27*(i - 1) + 14.5
				self:createDayanzaiPic(temp,pos)
			elseif status == 3 then
				--小路
				pos.y = 27*(i - 1) + 13
				self:createXiaoluPic(temp,pos)
			elseif status == 4 then
				--曱甴路
				pos.y = 27*(i - 1) + 14.5
				self:createYueyouPic(temp,pos)
			end
		end
	end
end
--创建大路显示
function ListItem:createDaluPic(data,pos)
	local pic 
	local headdata = data
	if data.follow then headdata = data.follow end
	
	if headdata.zhuangWin then
		--庄
		pic = display.newImage("bjl_ui_1061.png")
		if data.ping then
			pic:addChild(Coord.ingap(pic,display.newImage("bjl_ui_1059.png"),"CC",4,"CC",0))
		end
	else
		--闲
		pic = display.newImage("bjl_ui_1060.png")
		if data.ping then
			pic:addChild(Coord.ingap(pic,display.newImage("bjl_ui_1058.png"),"CC",4,"CC",0))
		end
	end
	
	if data.zhuangDouble then
		--庄对
		pic:addChild(Coord.ingap(pic,display.newImage("bjl_ui_1056.png"),"LL",0,"TT",0))
	end
	
	if data.xianDouble then
		--闲对
		pic:addChild(Coord.ingap(pic,display.newImage("bjl_ui_1055.png"),"RR",0,"BB",0))
	end
	
	pic:setPosition(pos)
	self:addChild(pic)
end
--创建珠路的显示
function ListItem:createZhuluPic(data,pos)
	local pic
	if data.zhuangWin then
		--庄赢
		pic = display.newImage("bjl_ui_1063.png")
	elseif data.xianWin then
		--闲赢
		pic = display.newImage("bjl_ui_1062.png")
	else
		--平
		pic = display.newImage("bjl_ui_1064.png")
	end
	
	if data.zhuangDouble then
		--庄对
		pic:addChild(Coord.ingap(pic,display.newImage("bjl_ui_1056.png"),"LL",0,"TT",0))
	end
	
	if data.xianDouble then
		--闲对
		pic:addChild(Coord.ingap(pic,display.newImage("bjl_ui_1055.png"),"RR",0,"BB",0))
	end
	pic:setPosition(pos)
	self:addChild(pic)
end
--创建珠路的显示
function ListItem:createDayanzaiPic(data,pos)
	local pic
	if data == 0 then
		pic = display.newImage("bjl_ui_1061.png")
	else
		pic = display.newImage("bjl_ui_1060.png")
	end
	pic:setPosition(pos)
	pic:setScale(0.4)
	self:addChild(pic)
end
--创建珠路的显示
function ListItem:createXiaoluPic(data,pos)
	local pic
	if data == 0 then
		pic = display.newImage("bjl_ui_1056.png")
	else
		pic = display.newImage("bjl_ui_1055.png")
	end
	pic:setPosition(pos)
	self:addChild(pic)
end
function ListItem:createYueyouPic(data,pos)
	local pic
	if data == 0 then
		pic = display.newImage("bjl_ui_1059.png")
	else
		pic = display.newImage("bjl_ui_1058.png")
	end
	pic:setPosition(pos)
	pic:setScale(0.6)
	self:addChild(pic)
end
-- --------------------------------------------------------------------------------
return Bjl_TrendWindows