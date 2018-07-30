--[[
*	扑克
*	@author：lqh
]]
local PokerItem = class("PokerItem",require("src.base.extend.CCLayerExtend"),function() 
	local layout = display.newLayout(cc.size(144,176))
	layout:setScale(0.8)
	layout:setAnchorPoint( cc.p(0.5,0.5) )
	return layout
end)

function PokerItem:ctor()
	self:super("ctor")
	local cardPic = display.newSprite()
	self:addChild(Coord.ingap(self,cardPic,"CC",0,"CC",0))
	self.m_cardPic = cardPic
end
--清除
function PokerItem:clear()
	self.m_cardPic:setTexture("")
	self.m_cardPic:stopAllActions()
	self.m_cardPic:setRotation(0)
	
	if self.m_backHor then
		self.m_backHor:stopAllActions()
		self.m_backHor:removeFromParent()
		self.m_backHor = nil
	end
	
	if self.m_seeEffectsp then
		self.m_seeEffectsp:stopAllActions()
		self.m_seeEffectsp:removeFromParent()
		self.m_seeEffectsp = nil
	end
	self.m_callback = nil
	self.m_data = nil
end
--显示牌
function PokerItem:show(callbcak)
	self.m_callback = callbcak
	
	if self.m_data:isLast() then
		self:seePoker()
	else
		self.m_cardPic:setSpriteFrame("card_back.png")
		self:m_turnPoker()
	end
end
--设置牌数据
function PokerItem:setPoker(pokerdata)
	self.m_data = pokerdata 
end
--翻牌
function PokerItem:m_turnPoker()
	self.m_cardPic:runAction(cc.Sequence:create({
		cc.OrbitCamera:create(0.2,1,0,0,90,0,0),
		cc.CallFunc:create(function(target) 
			if not target then return end
			--设置牌正面
			target:setSpriteFrame(self.m_data.pic)
		end),
		cc.OrbitCamera:create(0.2,1,0,270,90,0,0),
		cc.CallFunc:create(function(target) 
			self:m_Shake()
		end),
	}))
end
--看牌
function PokerItem:seePoker()
	--横向背面背景
	local backHor = display.newSprite("card_back_01.png")
	self:addChild(Coord.ingap(self,backHor,"CC",0,"BB",0))
	
	self.m_backHor = backHor
	
	backHor:runAction(cc.Sequence:create({
		cc.RotateTo:create(0.1,15),
		cc.RotateTo:create(0.1,0),
		cc.CallFunc:create(function(target) 
			if not target then return end
			target:removeFromParent(true)
			self.m_backHor = nil
			
			self:m_playSeeEffect()
		end)
	}))
	
	SoundsManager.playSound("bjl_dong")
end
--播放看牌动画
function PokerItem:m_playSeeEffect()
	--看牌动画显示sprite
	local seeEffectsp = display.newSprite()
	seeEffectsp:setScale(1.28)
	seeEffectsp:setPosition(cc.p(78,88))
	self:addChild(seeEffectsp)
	
	seeEffectsp:runAction(cc.Sequence:create({
		resource.getAnimateByKey("bjl_fanpai"),
		cc.CallFunc:create(function(target) 
			if not target then return end
			--设置花色
			local cardpoint = display.newSprite(self.m_data.pointpic)
			cardpoint:setRotation(90)
			cardpoint:setAnchorPoint( cc.p(0.5,1) )
			cardpoint:setPosition(cc.p(245,110))
			target:addChild(cardpoint)
		end),
		cc.DelayTime:create(1),
		cc.CallFunc:create(function(target) 
			if not target then return end
			target:removeAllChildren()
		end),
		resource.getAnimateByKey("bjl_fanpai_over"),
		cc.CallFunc:create(function(target) 
			if not target then return end
			--移除动画
			target:removeFromParent()
			self.m_seeEffectsp = nil
			--设置牌正面
			self.m_cardPic:setSpriteFrame(self.m_data.pic)
			
			self:m_Shake()
		end)
	}))
	self.m_seeEffectsp = seeEffectsp
	SoundsManager.playSound("bjl_fanpai")
end
function PokerItem:m_Shake()
	self.m_cardPic:runAction(cc.Sequence:create({
		cc.RotateTo:create(0.1,15),
		cc.RotateTo:create(0.1,0),
		cc.CallFunc:create(function(target) 
			if self.m_callback then
				local callback = self.m_callback
				self.m_callback = nil
				callback()
			end
		end),
	}))
end

function PokerItem:onCleanup()
	self:clear()
end
return PokerItem