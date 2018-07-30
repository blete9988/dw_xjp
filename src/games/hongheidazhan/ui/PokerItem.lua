--[[
*	扑克
*	@author：lqh
]]
local PokerItem = class("PokerItem",require("src.base.extend.CCLayerExtend"),function() 
	local layout = display.newLayout(cc.size(127,181))
	layout:setAnchorPoint( cc.p(0.5,0.5) )
	return layout
end)

function PokerItem:ctor()
	self:super("ctor")
	
	local pokerbg = display.newSprite("poker_bg_front.png")
	self:addChild(Coord.ingap(self,pokerbg,"CC",0,"CC",0))
	--类型图片
	local rolepic = display.newSprite()
	pokerbg:addChild(rolepic)
	--数字图片
	local mbnpic = display.newSprite("poker_black_1.png")
	pokerbg:addChild(Coord.ingap(pokerbg,mbnpic,"LL",5,"TT",-5))
	--类型图片 小
	local rolepic_s = display.newSprite("poker_shape_spade.png")
	rolepic_s:setScale(0.5)
	pokerbg:addChild(Coord.outgap(mbnpic,rolepic_s,"CC",0,"BT",-2,true))
	pokerbg:setTexture("")
	mbnpic:setTexture("")
	rolepic_s:setTexture("")
	
	self.m_pokerbg = pokerbg
	self.m_rolepic = rolepic
	self.m_mbnpic = mbnpic
	self.m_rolepic_s = rolepic_s
end
--清除
function PokerItem:clear()
	self.m_pokerbg:setVisible(false)
	self.m_pokerbg:stopAllActions()
	self.m_rolepic:setVisible(false)
	self.m_mbnpic:setVisible(false)
	self.m_rolepic_s:setVisible(false)
	
	self.m_callback = nil
	self.m_data = nil
end
--显示牌
function PokerItem:show()
	self.m_pokerbg:setSpriteFrame("poker_bg_back.png")
	self.m_pokerbg:setVisible(true)
end
function PokerItem:turnPoker(islast)
	if islast then
		self:m_turnPoker_2()
	else
		self:m_turnPoker_1()
	end
end
--设置牌数据
function PokerItem:setPoker(pokerdata)
	self.m_data = pokerdata 
end

function PokerItem:m_initPoker()
	self.m_pokerbg:setSpriteFrame("poker_bg_front.png")
	if self.m_data.role == "" then
		self.m_rolepic:setSpriteFrame(self.m_data.pic)
		Coord.ingap(self.m_pokerbg,self.m_rolepic,"RR",-5,"BB",10)
	else
		self.m_rolepic:setSpriteFrame(self.m_data.role)
		Coord.ingap(self.m_pokerbg,self.m_rolepic,"CC",0,"CC",0)
	end
	self.m_mbnpic:setSpriteFrame(self.m_data.pointpic)
	
	self.m_rolepic_s:setSpriteFrame(self.m_data.pic)
	
	self.m_rolepic:setVisible(true)
	self.m_mbnpic:setVisible(true)
	self.m_rolepic_s:setVisible(true)
end

function PokerItem:m_turnPoker_1()
	self.m_pokerbg:runAction(cc.Sequence:create({
		cc.OrbitCamera:create(0.25,1,0,0,90,0,0),
		cc.CallFunc:create(function(target) 
			if not target then return end
			--设置牌正面
			self:m_initPoker()
			SoundsManager.playSound("hhdz_turnPoker")
		end),
		cc.OrbitCamera:create(0.25,1,0,270,90,0,0),
	}))
end
function PokerItem:m_turnPoker_2()
	self.m_pokerbg:runAction(cc.Sequence:create({
		cc.ScaleTo:create(0.3,1.2),
		cc.DelayTime:create(0.1),
		cc.OrbitCamera:create(0.25,1,0,0,90,0,0),
		cc.CallFunc:create(function(target) 
			if not target then return end
			--设置牌正面
			self:m_initPoker()
			SoundsManager.playSound("hhdz_turnPoker")
		end),
		cc.OrbitCamera:create(0.25,1,0,270,90,0,0),
		cc.DelayTime:create(0.1),
		cc.ScaleTo:create(0.3,1),
	}))
end

return PokerItem