--[[
*	百家乐 结算window
*	@author：lqh
]]
local Bjl_ResultWindows = class("Bjl_ResultWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(792,547))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",-35,"CC",20)
	return layer
end)
Bjl_ResultWindows.hide_forward = false

function Bjl_ResultWindows:ctor()
	self:super("ctor")
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),100),"CC",35,"CC",-20))
	--特效
	local effect = display.newSprite("bjl_ui_1015.png")
	effect:setScale(6)
	self:addChild(Coord.ingap(self,effect,"CC",0,"CC",0))
	effect:runAction(cc.RepeatForever:create(
		cc.Sequence:create({
			cc.RotateTo:create(2,180),
			cc.RotateTo:create(2,360),
		})
	))
	
	local background = display.newImage("bjl_ui_1041.png")
	background:setScale(0.2)
	background:setOpacity(0)
	self:addChild(Coord.ingap(self,background,"CC",0,"CC",0))
	
	background:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.1),
			cc.ScaleTo:create(0.1,1.8)
		}),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:init()
		end),
		cc.ScaleTo:create(0.1,2.0),
		cc.ScaleTo:create(0.1,1.8),
	}))
end
function Bjl_ResultWindows:init()
	local resultMgr = require("src.games.baijiale.data.Bjl_GameMgr").getInstance().resultMgr
	local result = resultMgr:getLastResultData()
	--标题
	local titleimage = display.newImage("bjl_ui_1042.png")
	self:addChild(Coord.ingap(self,titleimage,"CC",0,"TT",20))
	self:m_setAction(titleimage,0)
	
	--结果点数 文本层
	local pointLayout = display.newLayout(cc.size(670,50))
	pointLayout:setAnchorPoint( cc.p(0.5,0.5) )
	self:addChild(Coord.ingap(self,pointLayout,"CC",0,"CC",90))
	local p1point,p2point = resultMgr:getCardPoint(ST.TYPE_GAMEBJL_PLAYER_0),resultMgr:getCardPoint(ST.TYPE_GAMEBJL_PLAYER_1)
	local temp
	if result.xianWin then
		--闲赢
		temp = display.newRichText(display.trans("##3006","bjl_ui_1002.png","bjl_ui_1038.png","bjl_number_3.png",p1point,"bjl_ui_1032.png","bjl_number_3.png"))
		pointLayout:addChild(Coord.ingap(pointLayout,temp,"CR",-40,"CC",0))
		temp = display.newRichText(display.trans("##3006","bjl_ui_1003.png","bjl_ui_1039.png","bjl_number_4.png",p2point,"bjl_ui_1037.png","bjl_number_4.png"))
		pointLayout:addChild(Coord.ingap(pointLayout,temp,"CL",40,"CC",0))
	elseif result.zhuangWin then
		--庄赢
		temp = display.newRichText(display.trans("##3006","bjl_ui_1002.png","bjl_ui_1039.png","bjl_number_4.png",p1point,"bjl_ui_1037.png","bjl_number_4.png"))
		pointLayout:addChild(Coord.ingap(pointLayout,temp,"CR",-40,"CC",0))
		temp = display.newRichText(display.trans("##3006","bjl_ui_1003.png","bjl_ui_1038.png","bjl_number_3.png",p2point,"bjl_ui_1032.png","bjl_number_3.png"))
		pointLayout:addChild(Coord.ingap(pointLayout,temp,"CL",40,"CC",0))
	else
		--和
		temp = display.newRichText(display.trans("##3006","bjl_ui_1002.png","bjl_ui_1043.png","bjl_number_3.png",p1point,"bjl_ui_1032.png","bjl_number_3.png"))
		pointLayout:addChild(Coord.ingap(pointLayout,temp,"CR",-40,"CC",0))
		temp = display.newRichText(display.trans("##3006","bjl_ui_1003.png","bjl_ui_1043.png","bjl_number_3.png",p2point,"bjl_ui_1032.png","bjl_number_3.png"))
		pointLayout:addChild(Coord.ingap(pointLayout,temp,"CL",40,"CC",0))
	end
	self:m_setAction(pointLayout,0.07)
	
	--输赢数量文本
	local resultTxt
	if resultMgr.winGold > 0  then
		--赢
		resultTxt = display.newRichText(display.trans("##3008","bjl_number_3.png",resultMgr.winGold))
		SoundsManager.playSound("bjl_win")
		SoundsManager.playSound("bjl_cheer_" .. (math.random(1,10000)%3))
	elseif resultMgr.winGold < 0 then
		--输
		resultTxt = display.newRichText(display.trans("##3008","bjl_number_4.png","<" .. resultMgr.winGold))
	else
		--未下注
		resultTxt = display.newRichText(display.trans("##3007"))
	end
	self:addChild(Coord.ingap(self,resultTxt,"CC",0,"CC",10))
	self:m_setAction(resultTxt,0.14)
	
	--赢分榜层
	local boardlayout = display.newLayout( cc.size(670,170))
	boardlayout:setAnchorPoint( cc.p(0.5,0.5) )
	self:addChild(Coord.ingap(self,boardlayout,"CC",0,"BB",26))
	local playerlist = resultMgr.winLeaderBroad
	for i = 1,#playerlist do
		local item = self:createLeaderboardItem(playerlist[i])
		if i == 1 then
			boardlayout:addChild(Coord.ingap(boardlayout,item,"CC",0,"TT",-1))
		else
			boardlayout:addChild(Coord.outgap(temp,item,"CC",0,"BT",-3))
		end
		temp = item
	end
	self:m_setAction(boardlayout,0.21)
	
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(3),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:executQuit()
			
			CommandCenter:sendEvent(ST.COMMAND_GAMEBJL_RESULT_OVER)
		end),
	}))
end

function Bjl_ResultWindows:createLeaderboardItem(playerInfo)
	local item = display.newLayout(cc.size(670,30))
	item:addChild(Coord.ingap(item,display.newText(playerInfo.name,26,Color.GREY),"CL",-150,"CC",0))
	
	item:addChild(Coord.ingap(item,display.newText(string.cnspNmbformat(playerInfo.gold),26,Color.GREY),"CR",280,"CC",0))
	
	return item
end

function Bjl_ResultWindows:m_setAction(item,delay)
	item:setOpacity(0)
	item:setScale(1.8)
	item:runAction(cc.Sequence:create({
		cc.DelayTime:create(delay),
		cc.Spawn:create({
			cc.FadeIn:create(0.05),
			cc.ScaleTo:create(0.05,1)
		}),
		cc.ScaleTo:create(0.1,1.2),
		cc.ScaleTo:create(0.1,1),
	}))
end

return Bjl_ResultWindows