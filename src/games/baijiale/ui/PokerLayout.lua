--[[
*	比牌 层
*	@author：lqh
]]
local PokerLayout = class("PokerLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(1112,693))
end)

function PokerLayout:ctor()
	self:super("ctor")
	self:setBackGroundImage("game/baijiale/bjl_desktop_background_1.png",0)
	self:setTouchEnabled(true)
	self:setPosition(cc.p(74,D_SIZE.h))
	
	--牌盒子
	local pokerBox = display.newImage("bjl_ui_1009.png")
	self:addChild(Coord.ingap(self,pokerBox,"RR",-11,"TT",-90))
	local temp = display.newImage("bjl_ui_1010.png")
	temp:setLocalZOrder(1)
	pokerBox:addChild(Coord.ingap(pokerBox,temp,"CC",-37,"CC",-5))
	self.m_pokerBox = pokerBox
	
	self:m_initUI()
	self:m_initPoker()
	
	--结果管理器
	self.m_data = require("src.games.baijiale.data.Bjl_GameMgr").getInstance().resultMgr
end
--初始化UI显示
function PokerLayout:m_initUI()
	--闲家点数显示文本
	local playerPointTxt_1 = display.newRichText("")
	self:addChild(Coord.ingap(self,playerPointTxt_1,"CC",-220,"CC",30))
	--庄家点数显示文本
	local playerPointTxt_2 = display.newRichText("")
	self:addChild(Coord.ingap(self,playerPointTxt_2,"CC",220,"CC",30))
	
	--闲对子特效
	local playerDoubleEffect_1 = require("src.games.baijiale.ui.CardTypeEffect").new(0)
	self:addChild(Coord.outgap(playerPointTxt_1,playerDoubleEffect_1,"LR",-10,"TB",5))
	--闲天王特效
	local playerKingEffect_1 =  require("src.games.baijiale.ui.CardTypeEffect").new(1)
	self:addChild(Coord.outgap(playerPointTxt_1,playerKingEffect_1,"RL",10,"TB",5))
	
	--庄对子特效
	local playerDoubleEffect_2 = require("src.games.baijiale.ui.CardTypeEffect").new(0)
	self:addChild(Coord.outgap(playerPointTxt_2,playerDoubleEffect_2,"LR",-10,"TB",5))
	--庄天王特效
	local playerKingEffect_2 =  require("src.games.baijiale.ui.CardTypeEffect").new(1)
	self:addChild(Coord.outgap(playerPointTxt_2,playerKingEffect_2,"RL",10,"TB",5))
	
	self.m_playerPointTxt_1 = playerPointTxt_1
	self.m_playerPointTxt_2 = playerPointTxt_2
	self.m_playerDoubleEffect_1 = playerDoubleEffect_1
	self.m_playerKingEffect_1 = playerKingEffect_1
	self.m_playerDoubleEffect_2 = playerDoubleEffect_2
	self.m_playerKingEffect_2 = playerKingEffect_2
end
--初始化扑克牌
function PokerLayout:m_initPoker()
	self.m_cardlist = {}
	local pos = cc.p(280,270)
	local item
	--初始化闲家牌
	for i = 1,3 do
		item = require("src.games.baijiale.ui.PokerItem").new()
		item:setPosition(pos)
		self:addChild(item)
		self.m_cardlist[i*2 - 1] = item
		pos.x = pos.x + 70
	end
	--初始化庄家牌
	pos.x = 715
	for i = 1,3 do
		item = require("src.games.baijiale.ui.PokerItem").new()
		item:setPosition(pos)
		self:addChild(item)
		self.m_cardlist[i*2] = item
		pos.x = pos.x + 70
	end
end

--自动执行展示
function PokerLayout:autoLoop()
	local pokerdata = self.m_data:getHandCard()
	if not pokerdata then
		--没手牌，发下一家的牌，进入下一循环
		self:m_sendOver()
		return 
	end
	local carditem = self.m_cardlist[self.m_data.index]
	carditem:setPoker(pokerdata)
	self:m_sendCard(carditem)
end
--每一次发牌完成回掉
function PokerLayout:m_sendOver()
	if self.m_data.index == 4 then
		--第一轮发牌完成
		self:m_showMiddleResult()
		return 
	end
	if self.m_data.index == 5 then
		self.m_playerPointTxt_1:setString(display.trans("##3004",self.m_data:getCardPoint(ST.TYPE_GAMEBJL_PLAYER_0)))
		--显示闲是否天王
		self.m_playerKingEffect_1:setShow(self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_4))
	end
	
	if self.m_data.index == 6 then
		self.m_playerPointTxt_2:setString(display.trans("##3004",self.m_data:getCardPoint(ST.TYPE_GAMEBJL_PLAYER_1)))
		--显示庄是否天王
		self.m_playerKingEffect_2:setShow(self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_5))
		
		self:m_showLastResult()
		
		SoundsManager.playSound("bjl_send_card_over")
		self:hide()
		return
	end
	
	self.m_data:goNext()
	self:autoLoop()
end
--发牌
function PokerLayout:m_sendCard(target)
	local flycard = display.newSprite("bjl_ui_1031.png")
	self.m_pokerBox:addChild(Coord.ingap(self.m_pokerBox,flycard,"CC",-37,"CC",-11))
	SoundsManager.playSound("bjl_send_card")
	flycard:runAction(cc.Sequence:create({
		cc.MoveTo:create(0.1,cc.p(-15,-30)),
		cc.CallFunc:create(function(t) 
			if not t then return end
			t:removeFromParent(true)
			self:m_playFlyEffect(target)
		end)
	}))
end
--播放飞牌动画
function PokerLayout:m_playFlyEffect(target)
	local targetpos = cc.p(target:getPosition())
	
	local distance = math.sqrt(math.pow(targetpos.x - 956,2) + math.pow(targetpos.y - 471,2))
	
	local tm = distance/2500
	local tempcard = display.newSprite("card_back.png")
	tempcard:setScale(0.3)
	tempcard:setOpacity(100)
	tempcard:setPosition( cc.p(956,471) )
	tempcard:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.MoveTo:create(tm,targetpos),
			cc.FadeTo:create(tm,230),
			cc.ScaleTo:create(tm,0.8),
			cc.Repeat:create(cc.Sequence:create({
				cc.RotateTo:create(tm/8,180),
				cc.RotateTo:create(tm/8,360)
			}),4)
		}),
		cc.CallFunc:create(function(t) 
			if not t then return end
			t:removeFromParent(true)
			
			target:show(handler(self,self.m_sendOver))
		end)
	}))
	self:addChild(tempcard)
end
--显示第一轮发牌结果
function PokerLayout:m_showMiddleResult()
	--显示点数
	self.m_playerPointTxt_1:setString(display.trans("##3004",self.m_data:getCardPoint(ST.TYPE_GAMEBJL_PLAYER_0)))
	self.m_playerPointTxt_2:setString(display.trans("##3004",self.m_data:getCardPoint(ST.TYPE_GAMEBJL_PLAYER_1)))
	
	--显示闲是否对子和天王
	self.m_playerDoubleEffect_1:setShow(self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_2))
	if self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_4) and #self.m_data.player1_handler == 2 then
		self.m_playerKingEffect_1:setShow(true)
	end
	--显示庄是否对子和天王
	self.m_playerDoubleEffect_2:setShow(self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_3))
	if self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_5) and #self.m_data.player2_handler == 2 then
		self.m_playerKingEffect_2:setShow(true)
	end
	
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self.m_data:nextRound()
			self:autoLoop()
		end)
	}))
end
--显示最终
function PokerLayout:m_showLastResult()
	--结果图片
	local resultPic = display.newSprite()
	resultPic:setOpacity(0)
	if self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_6) then
		--闲赢
		resultPic:setSpriteFrame("bjl_ui_1016.png")
		Coord.ingap(self,resultPic,"CC",-120,"BB",90)
	elseif self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_7) then
		--庄赢
		resultPic:setSpriteFrame("bjl_ui_1016.png")
		Coord.ingap(self,resultPic,"CC",315,"BB",90)
	elseif self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_0) then
		--平
		resultPic:setSpriteFrame("bjl_ui_1035.png")
		Coord.ingap(self,resultPic,"CC",0,"CC",-20)
	elseif self.m_data:judgeResult(ST.TYPE_GAMEBJL_RESULT_1) then
		--同点平
		resultPic:setSpriteFrame("bjl_ui_1036.png")
		Coord.ingap(self,resultPic,"CC",0,"CC",-20)
	end
	self:addChild(resultPic)
	resultPic:setScale(0.5)
	resultPic:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.2),
			cc.ScaleTo:create(0.2,1.6)
		}),
		cc.ScaleTo:create(0.1,1),
	}))
	self.m_resultPic = resultPic
end
function PokerLayout:clear()
	for i = 1,#self.m_cardlist do
		self.m_cardlist[i]:clear()
	end
	self.m_playerPointTxt_1:setString("")
	self.m_playerPointTxt_2:setString("")
	self.m_playerDoubleEffect_1:hide()
	self.m_playerKingEffect_1:hide()
	self.m_playerDoubleEffect_2:hide()
	self.m_playerKingEffect_2:hide()
	if self.m_resultPic then
		self.m_resultPic:removeFromParent(true)
		self.m_resultPic = nil
	end
end

function PokerLayout:show()
	
	self:runAction(cc.Sequence:create({
		cc.EaseBounceOut:create(cc.MoveTo:create(0.3,cc.p(74,D_SIZE.top(693)))),
		--延迟一秒发牌
		cc.DelayTime:create(1),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:autoLoop()
		end)
	}))
end
function PokerLayout:hide()
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(3),
		cc.MoveTo:create(0.3,cc.p(74,D_SIZE.h)),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:clear()
			
			CommandCenter:sendEvent(ST.COMMAND_GAMEBJL_POKER_OVER)
		end)
	}))
end

function PokerLayout:onCleanup()
	self:stopAllActions()
end
return PokerLayout