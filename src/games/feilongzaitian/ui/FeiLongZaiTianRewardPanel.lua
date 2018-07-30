--[[
 *	得奖弹窗
 *	@author gwj
]]
local FeiLongZaiTianRewardPanel = class("FeiLongZaiTianRewardPanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height),0))
	return layout
end)
local instance = nil
function FeiLongZaiTianRewardPanel:ctor(tipType,value,overfunction)
	self.overfunction = overfunction
	print("FeiLongZaiTianRewardPanel-------------------------------------------------")
	self:setTouchEnabled(true)
	if tipType == 1 then
		local effect_bg = display.newDynamicImage("game/feilongzaitian/flzt_Free_Desc_WonCredits_bg.png")
		effect_bg:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
		effect_bg:setScale(0.2)
		self:addChild(effect_bg)
		local effect_1 = display.newDynamicImage("game/feilongzaitian/flzt_Free_Desc_WonCredits_effect2.png")
		local size = effect_1:getContentSize()
		effect_1:setPosition(cc.p(size.width/2,size.height/2))
		effect_bg:addChild(effect_1)
		local effect_2 = display.newDynamicImage("game/feilongzaitian/flzt_Free_Desc_WonCredits_effect1.png")
		size = effect_2:getContentSize()
		effect_2:setPosition(cc.p(size.width/2,size.height/2))
		effect_bg:addChild(effect_2)
		local font_bg = display.newDynamicImage("game/feilongzaitian/flzt_Free_Desc_WonCredits_cn.png")
		size = font_bg:getContentSize()
		font_bg:setPosition(cc.p(size.width/2,size.height/2))
		effect_bg:addChild(font_bg)
		local effect_label = ccui.TextAtlas:create(0,"game/feilongzaitian/flzt_number_5.png",74,100,0)
		require("src.command.NumberEffect").extend(effect_label)
		effect_label:closeEffect()
		effect_label:setNumer(value,25,0.05)
		font_bg:addChild(effect_label)
		Coord.ingap(font_bg,effect_label,"CC",0,"BB",230)
		effect_bg:runAction(cc.Sequence:create({
				cc.EaseBackOut:create(cc.ScaleTo:create(0.8,1)),
				cc.CallFunc:create(function(sender)
					local sequence = cc.Sequence:create({
						cc.ScaleTo:create(1,0.6),
						cc.ScaleTo:create(1,1)
					})
					effect_1:runAction(cc.RepeatForever:create(sequence))
					sequence = cc.Sequence:create({
						cc.ScaleTo:create(0.8,0.8),
						cc.ScaleTo:create(0.8,1)
					})
					effect_2:runAction(cc.RepeatForever:create(sequence))
				end)}))
		self:setTimeOver(5)
	elseif tipType == 2 then
		local layout_bg =  display.newDynamicImage("game/feilongzaitian/flzt_free_TSBG.png")
		layout_bg:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
		layout_bg:setScale(0.2)
		self:addChild(layout_bg)
		local tit_label =  display.newDynamicImage("game/feilongzaitian/flzt_free_TS_1.png")
		Coord.ingap(layout_bg,tit_label,"CC",0,"CC",0)
		layout_bg:addChild(tit_label)
		local value_label =  ccui.TextAtlas:create(value,"game/feilongzaitian/flzt_number_5.png",74,100,0)
		Coord.ingap(layout_bg,value_label,"CC",0,"CC",0)
		layout_bg:addChild(value_label)
		layout_bg:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.8,1)))
		self:setTimeOver(2)
	elseif tipType == 3 then
		local layout_bg =  display.newDynamicImage("game/feilongzaitian/flzt_free_TSBG.png")
		layout_bg:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
		layout_bg:setScale(0.2)
		self:addChild(layout_bg)
		local tit_label =  display.newDynamicImage("game/feilongzaitian/flzt_free_TS_2.png")
		Coord.ingap(layout_bg,tit_label,"CC",0,"CC",0)
		layout_bg:addChild(tit_label)
		local value_label =  ccui.TextAtlas:create(value,"game/feilongzaitian/flzt_number_5.png",74,100,0)
		Coord.ingap(layout_bg,value_label,"CC",150,"CC",10)
		layout_bg:addChild(value_label)
		layout_bg:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.8,1)))
		self:setTimeOver(2)
	elseif tipType == 4 then
		local layout_bg =  display.newDynamicImage("game/feilongzaitian/flzt_Performe_cn.png")
		layout_bg:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
		layout_bg:setScale(0.2)
		self:addChild(layout_bg)
		local value_label =  ccui.TextAtlas:create(value,"game/feilongzaitian/flzt_number_5.png",74,100,0)
		value_label:setPosition(cc.p(474,187))
		layout_bg:addChild(value_label)
		layout_bg:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.8,1)))
		self:setTimeOver(2)
	end


	-- self:addTouchEventListener(function(sender,eventype)
	--     if eventype ~= ccui.TouchEventType.ended then
	-- 		if overfunction then
	-- 			overfunction()
	-- 		end
	--     	self:destroy()
	-- 	end
 --    end)
end

function FeiLongZaiTianRewardPanel:setTimeOver(delay)
	self:performWithDelay(function()
		if self.overfunction then
			self.overfunction()
		end
    	self:destroy()
	end,delay)
end

function FeiLongZaiTianRewardPanel:destroy()
	self:removeFromParent(true)
	instance = nil
end

function FeiLongZaiTianRewardPanel.show(tipType,value,overfunction)
	if instance == nil then
		instance = FeiLongZaiTianRewardPanel.new(tipType,value,overfunction)
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return FeiLongZaiTianRewardPanel
