--[[
*	百人牛牛 结果显示window
*	@author：lqh
]]
local Brnn_ResultWindows = class("Brnn_ResultWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(1086,580))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",-20)
	return layer
end)
Brnn_ResultWindows.hide_forward = false

function Brnn_ResultWindows:ctor()
	self:super("ctor")
	self:addEvent(ST.COMMAND_GAMEBRNN_POKER_OVER)
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),150),"CC",0,"CC",20))
	--底板
	self:addChild(Coord.ingap(self,display.setS9(display.newImage("brnn_panel_1001.png"),cc.rect(20,20,80,80),cc.size(1086,580)),"CC",0,"CC",0))
	
	local closebtn = display.newButton("ui_brnn_1057.png","ui_brnn_1063.png")
	self:addChild(Coord.ingap(self,closebtn,"RR",-8,"TT",-8))
	closebtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:executQuit()
	end)
	
	local gameMrg = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance()
	local tempicon = display.newImage("ui_brnn_1006.png")
	tempicon:setScale(1.4)
	self:addChild(Coord.ingap(self,tempicon,"CC",-100,"TT",-30,true))
	--庄家输赢金钱文本
	local zhuangGoldTxt
	if gameMrg.resultMgr.zhuangGold < 0 then
		zhuangGoldTxt = display.newText(string.cnspNmbformat(gameMrg.resultMgr.zhuangGold),46,cc.c3b(0xff,0,0))
	else
		zhuangGoldTxt = display.newText(display.trans("##2045",string.cnspNmbformat(gameMrg.resultMgr.zhuangGold)),46,Color.GREEN)
	end
	self:addChild(Coord.outgap(tempicon,zhuangGoldTxt,"RL",15,"CC",0,true))
	--庄家名字
	local zhuangNameTxt = display.newText(display.trans("##2047",gameMrg.master.name),36,Color.danrubaise)
	self:addChild(Coord.outgap(zhuangGoldTxt,zhuangNameTxt,"CC",-20,"BT",-5))
	
	local contentbg = display.newLayout()
	contentbg:setBackGroundImage("brnn_panel_1002.png",1)
	display.setBgS9(contentbg,cc.rect(20,20,60,60),cc.size(960,400))
	self:addChild(Coord.ingap(self,contentbg,"CC",0,"BB",40))
	self.m_contentbg = contentbg
	
	tempicon = display.newImage("ui_brnn_1016.png")
	contentbg:addChild(Coord.ingap(contentbg,tempicon,"LL",40,"TC",-65))
	tempicon = Coord.outgap(tempicon,display.newImage("ui_brnn_1022.png"),"CC",190,"CC",0)
	contentbg:addChild(tempicon)
	tempicon = Coord.outgap(tempicon,display.newImage("ui_brnn_1020.png"),"CC",190,"CC",0)
	contentbg:addChild(tempicon)
	tempicon = Coord.outgap(tempicon,display.newImage("ui_brnn_1018.png"),"CC",190,"CC",0)
	contentbg:addChild(tempicon)
	
	local tablebg = display.newLayout(cc.size(900,240))
	tablebg:setLocalZOrder(2)
	tablebg:setBackGroundImage("ui_brnn_1008.png",1)
	display.setBgS9(tablebg,cc.rect(80,120,10,10))
	contentbg:addChild(Coord.ingap(contentbg,tablebg,"CC",0,"BB",30))
	tempicon = display.newLayout(cc.size(2,228))
	display.debugLayout(tempicon,cc.c3b(0x0a,0xa6,0xb3),80)
	tablebg:addChild(Coord.ingap(tablebg,tempicon,"CC",20,"CC",0))
	
	local playerTop10s = gameMrg.resultMgr.top10
	local pos = cc.p(45,189)
	for i = 1,#playerTop10s do
		if i == 6 then
			pos.x = 480
			pos.y = 189
		end
		if not playerTop10s[i] then break end
		tempicon = self:createListItem(playerTop10s[i],i)
		tempicon:setPosition( pos )
		tablebg:addChild(tempicon)
		pos.y = pos.y - 46
	end
	
	self:m_showEffect()
end
--显示动画
function Brnn_ResultWindows:m_showEffect()
	local resultMgr = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().resultMgr
	
	local groupdatas = resultMgr:getGroups()
	local delay = 0.2
	--庄家牌型
	local tempicon = display.newImage(groupdatas[#groupdatas]:getTypePic())
	self:addChild(Coord.ingap(self,tempicon,"CC",250,"TC",-70))
	self:m_createEffect1(tempicon,delay)
	
	delay = delay + 0.25
	tempicon = display.newImage(groupdatas[1]:getTypePic())
	self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,tempicon,"LL",100,"TC",-45,true))
	self:m_createEffect1(tempicon,delay)
	delay = delay + 0.25
	tempicon = display.newImage(groupdatas[2]:getTypePic())
	self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,tempicon,"LL",295,"TC",-45,true))
	self:m_createEffect1(tempicon,delay)
	delay = delay + 0.25
	tempicon = display.newImage(groupdatas[3]:getTypePic())
	self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,tempicon,"LL",485,"TC",-45,true))
	self:m_createEffect1(tempicon,delay)
	delay = delay + 0.25
	tempicon = display.newImage(groupdatas[4]:getTypePic())
	self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,tempicon,"LL",670,"TC",-45,true))
	self:m_createEffect1(tempicon,delay)
	
	delay = delay + 0.25
	local txt = self:createTxt(resultMgr.mineGoldlist[1])
	self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,txt,"LC",170,"TC",-95))
	self:m_createEffect2(txt,delay)
	delay = delay + 0.25
	txt = self:createTxt(resultMgr.mineGoldlist[2])
	self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,txt,"LC",360,"TC",-95))
	self:m_createEffect2(txt,delay)
	delay = delay + 0.25
	txt = self:createTxt(resultMgr.mineGoldlist[3])
	self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,txt,"LC",550,"TC",-95))
	self:m_createEffect2(txt,delay)
	delay = delay + 0.25
	txt = self:createTxt(resultMgr.mineGoldlist[4])
	self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,txt,"LC",740,"TC",-95))
	self:m_createEffect2(txt,delay)
	
	delay = delay + 0.25
	
	if not require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance():isMaster() then
		--自己不是庄家
		if not resultMgr.hadin then
			txt = display.newText(display.trans("##4007"),32,Color.GREEN)
			self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,txt,"RL",-150,"TC",-65))
			--未下注
			SoundsManager.playSound("brnn_result_nobet")
		else
			txt = self:createTxt(resultMgr.mineAllGold)
			self.m_contentbg:addChild(Coord.ingap(self.m_contentbg,txt,"RL",-150,"TC",-65))
			if resultMgr.mineAllGold >= 0 then
				--赢
				SoundsManager.playSound("brnn_result_win")
			else
				--输
				SoundsManager.playSound("brnn_result_lose")
			end
		end
		self:m_createEffect2(txt,delay)
		for i = 1,#groupdatas - 1 do
			if groupdatas[i]:isLargeNiuNiu() and resultMgr.mineGoldlist[i] > 0 then
				--是牛牛且买中
				SoundsManager.playSound("brnn_result_niuniu")
				break
			end
		end
	else
		--自己是庄家
		if resultMgr.mineAllGold >= 0  then
			--赢
			SoundsManager.playSound("brnn_result_win")
		else
			--输
			SoundsManager.playSound("brnn_result_lose")
		end
		if groupdatas[#groupdatas]:isLargeNiuNiu() then
			SoundsManager.playSound("brnn_result_niuniu")
		end
	end
	
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(delay + 1),
		cc.CallFunc:create(function(target) 
			if not target then return end
			--设置牌正面
			self:executQuit()
		end),
	}))
end
--创建动画1
function Brnn_ResultWindows:m_createEffect1(taget,delay)
	taget:setScale(1.3)
	taget:setOpacity(0)
	taget:runAction(cc.Sequence:create({
		cc.DelayTime:create(delay),
		cc.Spawn:create({
			cc.FadeIn:create(0.05),
			cc.ScaleTo:create(0.05,1.7)
		}),
		cc.ScaleTo:create(0.1,0.6),
		cc.ScaleTo:create(0.1,0.8),
	}))
end
--创建动画2
function Brnn_ResultWindows:m_createEffect2(taget,delay)
	taget:setOpacity(0)
	taget:runAction(cc.Sequence:create({
		cc.DelayTime:create(delay),
		cc.FadeIn:create(0.2),
	}))
end
function Brnn_ResultWindows:createTxt(value)
	local txt
	if value >= 0 then
		txt = display.newText(display.trans("##2045",string.cnspNmbformat(value)),26,Color.GREEN)
	else
		txt = display.newText(string.cnspNmbformat(value),26,cc.c3b(0xff,0,0))
	end
	return txt
end
function Brnn_ResultWindows:createListItem(playerInfos,index)
	local layout = display.newLayout(cc.size(415,45))
	--排名文本
	local labeltxt = display.newText(index,26,Color.danrubaise)
	layout:addChild(Coord.ingap(layout,labeltxt,"LL",20,"CC",0))
	--名字文本
	labeltxt = display.newText(playerInfos.name,26,Color.danrubaise)
	layout:addChild(Coord.ingap(layout,labeltxt,"LL",60,"CC",0))
	--金币文本
	labeltxt = display.newText("+" .. string.cnspNmbformat(playerInfos.gold),26,Color.danrubaise)
	layout:addChild(Coord.ingap(layout,labeltxt,"RR",-5,"CC",0))
	return layout
end

function Brnn_ResultWindows:onCleanup()
	self:super("onCleanup")
	local gold = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance().resultMgr.mineRealGold
	if gold > Player.gold then
		SoundsManager.playSound("brnn_get_gold")
	end
	CommandCenter:sendEvent(ST.COMMAND_GAMEBRNN_RESULT_OVER)
end
return Brnn_ResultWindows