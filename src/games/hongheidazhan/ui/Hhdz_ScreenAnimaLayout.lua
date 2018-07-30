--[[
*	全屏遮挡 动画层 
*	@author：lqh
]]
local Hhdz_ScreenAnimaLayout = class("Hhdz_ScreenAnimaLayout",function() 
	return display.newMask(nil,190)
end)

function Hhdz_ScreenAnimaLayout:ctor()
	self:setTouchEnabled(false)
	self:setLocalZOrder(10)
end
function Hhdz_ScreenAnimaLayout:playPKBoomAnim(callback)
	local kingImg = display.newSprite("ui_hhdz_1027.png")
	kingImg:setAnchorPoint( cc.p(1,0.5) )
	kingImg:addChild(Coord.ingap(kingImg,display.newSprite("ui_hhdz_1026.png"),"LC",60,"BB",20))
	kingImg:setPosition( cc.p(0,D_SIZE.hh) )
	self:addChild(kingImg)
	kingImg:runAction(cc.Sequence:create({
		cc.MoveTo:create(0.1,cc.p(D_SIZE.hw,D_SIZE.hh)),
		cc.MoveTo:create(0.03,cc.p(D_SIZE.hw - 100,D_SIZE.hh)),
		cc.MoveTo:create(0.03,cc.p(D_SIZE.hw,D_SIZE.hh)),
		cc.DelayTime:create(0.55),
		cc.Spawn:create({
			cc.MoveTo:create(0.1,cc.p(D_SIZE.hw - 150,D_SIZE.hh)),
			cc.FadeOut:create(0.1)
		})
	}))
	
	local queenImg = display.newSprite("ui_hhdz_1029.png")
	queenImg:setAnchorPoint( cc.p(0,0.5) )
	queenImg:addChild(Coord.ingap(kingImg,display.newSprite("ui_hhdz_1028.png"),"RC",-60,"BB",20))
	queenImg:setPosition( cc.p(D_SIZE.w,D_SIZE.hh) )
	self:addChild(queenImg)
	queenImg:runAction(cc.Sequence:create({
		cc.MoveTo:create(0.1,cc.p(D_SIZE.hw,D_SIZE.hh)),
		cc.MoveTo:create(0.05,cc.p(D_SIZE.hw + 100,D_SIZE.hh)),
		cc.MoveTo:create(0.05,cc.p(D_SIZE.hw,D_SIZE.hh)),
		cc.DelayTime:create(0.55),
		cc.Spawn:create({
			cc.MoveTo:create(0.0,cc.p(D_SIZE.hw + 150,D_SIZE.hh)),
			cc.FadeOut:create(0.0)
		})
	}))
	
	local vsImg = display.newSprite("ui_hhdz_1030.png")
	vsImg:setPosition( cc.p(D_SIZE.hw,D_SIZE.hh) )
	vsImg:setScale(1.6)
	vsImg:setOpacity(50)
	self:addChild(vsImg)
	vsImg:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.05),
			cc.ScaleTo:create(0.05,1),
		}),
		CCShake:create(0.1,40),
		cc.DelayTime:create(0.55),
		cc.Spawn:create({
			cc.FadeOut:create(0.1),
			cc.ScaleTo:create(0.1,0.3),
		}),
	}))
	--爆炸动画
	local anim = display.newSprite()
	anim:setScale(2)
	anim:setPosition( cc.p(D_SIZE.hw,D_SIZE.hh) )
	anim:runAction(cc.Sequence:create({
		resource.getAnimateByKey("pk_boom",false,false),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:removeAllChildren()
			self:playStartAnim()
			if callback then callback() end
		end),
	}))
	self:addChild(anim)
	SoundsManager.playSound("hhdz_start_alert")
	return self
end
--播放开始动画
function Hhdz_ScreenAnimaLayout:playStartAnim()
	self:setBackGroundColorOpacity(0)
--	local bg = display.newSprite("ui_hhdz_1036.png")
--	bg:setPosition( cc.p(D_SIZE.hw,D_SIZE.hh) )
--	bg:setScale(2.72)
--	self:addChild(bg)
	
	local startLayout = display.newSprite()
	startLayout:setPosition(cc.p(-200,D_SIZE.hh))
	startLayout:setOpacity(0)
	self:addChild(startLayout)
	local anim = display.newSprite()
	startLayout:addChild(Coord.ingap(startLayout,anim,"CC",0,"CC",-40))
	anim:setScale(2.1)
	anim:runAction(resource.getAnimateByKey("start_shine",true))
	local startImg = display.newSprite("ui_hhdz_1024.png")
	startImg:setPosition(cc.p(-200,D_SIZE.hh))
	startLayout:addChild(Coord.ingap(startLayout,startImg,"CC",0,"CC",0))
	
	startLayout:runAction(cc.Sequence:create({
		cc.DelayTime:create(0.3),
		cc.CallFunc:create(function(t) 
			if not t then return end
			SoundsManager.playSound("hhdz_show")
		end),
		cc.Spawn:create({
			cc.FadeIn:create(0.2),
			cc.MoveTo:create(0.2,cc.p(D_SIZE.hw,D_SIZE.hh))
		}),
		cc.DelayTime:create(0.8),
		cc.MoveTo:create(0.2,cc.p(D_SIZE.w + 200,D_SIZE.hh)),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:removeFromParent()
			--派发开始下注全屏动画播放完成
			CommandCenter:sendEvent(ST.COOMAND_GAMEHHDZ_BEGAN_ANIM_OVER)
		end),
	}))
	SoundsManager.playSound("hhdz_start")
	return self
end
--播放结束动画
function Hhdz_ScreenAnimaLayout:playOverAnim(callback)
	self:setBackGroundColorOpacity(0)
	local bg = display.newSprite("ui_hhdz_1036.png")
	bg:setPosition( cc.p(D_SIZE.hw,D_SIZE.hh) )
	bg:setScale(2.72)
	bg:setOpacity(0)
	self:addChild(bg)
	bg:runAction(cc.FadeIn:create(0.05))
	
	local overImg = display.newSprite("ui_hhdz_1025.png")
	overImg:setPosition(cc.p(-200,D_SIZE.hh + 40))
	overImg:setOpacity(0)
	self:addChild(overImg)
	
	overImg:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.2),
			cc.MoveTo:create(0.2,cc.p(D_SIZE.hw,D_SIZE.hh + 40))
		}),
		cc.DelayTime:create(0.8),
		cc.MoveTo:create(0.2,cc.p(D_SIZE.w + 200,D_SIZE.hh + 40)),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self:removeFromParent()
			if callback then callback() end
		end),
	}))
	SoundsManager.playSound("hhdz_show")
	SoundsManager.playSound("hhdz_over")
	return self
end
return Hhdz_ScreenAnimaLayout