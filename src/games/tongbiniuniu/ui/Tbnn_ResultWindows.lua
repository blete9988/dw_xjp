--[[
*	通比牛牛 结算window
*	@author：lqh
]]
local Tbnn_ResultWindows = class("Tbnn_ResultWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(832,566))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",0)
	return layer
end)
Tbnn_ResultWindows.hide_forward = false

function Tbnn_ResultWindows:ctor()
	self:super("ctor")
	
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),200),"CC",0,"CC",0))
	--底板
	local background = display.newImage("#game/tongbiniuniu/tbnn_windowbg_1.png")
	background:setOpacity(0)
	background:setScale(0.3)
	self:addChild(Coord.ingap(self,background,"CC",0,"CC",0))
	
	background:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.1),
			cc.ScaleTo:create(0.1,1.3)
		}),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:init()
		end),
		cc.ScaleTo:create(0.1,0.9),
		cc.ScaleTo:create(0.1,1),
	}))
	
	local listview = display.newListView()
	listview:setContentSize(cc.size(820,430))
	self:addChild(Coord.ingap(self,listview,"CC",0,"BB",40))
	
	local delay = 0.35
	local item 
	local players = require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance():getPlayersByResult()
	for i = 1,#players do
		delay = 0.35 + 0.1*(i - 1)
		item = self:m_createListItem(players[i])
		listview:pushBackCustomItem(item)
		item:setOpacity(0)
		item:runAction(cc.Sequence:create({
			cc.DelayTime:create(delay),
			cc.FadeIn:create(0.13)
		}))
	end
	
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(delay + 1.5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:executQuit()
		end)
	}))
	
	local myInfo = require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance():getMineInfo()
	if myInfo:isWinner() then
		SoundsManager.playSound("tbnn_win")
	else
		SoundsManager.playSound("tbnn_fail")
	end
	if myInfo.pokerGroup:isLargeNiuNiu() then
		SoundsManager.playSound("tbnn_niujiao")
	end
end
function Tbnn_ResultWindows:m_createListItem(playerInfo)
	local layout = display.newLayout(cc.size(750,86))
	local background
	if playerInfo:isWinner() then
		background = display.newImage("tbnn_panel_1006.png")
	else
		background = display.newImage("tbnn_panel_1005.png")
	end
	display.setS9(background,cc.rect(15,25,10,20),cc.size(740,80))
	layout:addChild(Coord.ingap(layout,background,"CC",0,"CC",0))
	
	--胜负图标，输赢文本
	local icon,goldTxt
	if playerInfo:isWinner() then
		icon = display.newImage("tbnn_ui_1019.png")
		goldTxt = display.newRichText(display.trans("##5010",math.abs(playerInfo.resultGold)))
	else
		icon = display.newImage("tbnn_ui_1018.png")
		goldTxt = display.newRichText(display.trans("##5011",math.abs(playerInfo.resultGold)))
	end
	layout:addChild(Coord.ingap(layout,icon,"LR",135,"CC",0))
	goldTxt:setScale(0.7)
	layout:addChild(Coord.ingap(layout,goldTxt,"CL",180,"CC",0,true))
	
	--名字文本
	layout:addChild(Coord.ingap(layout,display.newText(playerInfo.name,22,Color.GREY),"LL",140,"CC",0))
	
	--牌组
	local pokeritem = require("src.games.tongbiniuniu.ui.PokerGroupItem").new()
	pokeritem:setScale(0.42)
	pokeritem:initPoker(playerInfo.pokerGroup,true)
	layout:addChild(Coord.ingap(layout,pokeritem,"CC",10,"CC",0,true))
	--牌型
	local typepic = display.newImage(playerInfo.pokerGroup:getTypePic())
	typepic:setScale(0.6)
	layout:addChild(Coord.ingap(layout,typepic,"CL",90,"CC",0,true))
	
	return layout
end

function Tbnn_ResultWindows:onCleanup()
	self:super("onCleanup")
	
	CommandCenter:sendEvent(ST.COMMAND_GAMETBNN_RESULT_OVER)
end
return Tbnn_ResultWindows