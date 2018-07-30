--[[
 *	美女弹窗
 *	@author gwj
]]
local HaoChePiaoYiBeautyPanel = class("HaoChePiaoYiBeautyPanel",function() 
	local layout = display.extend("CCLayerExtend",display.newLayout(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil


function HaoChePiaoYiBeautyPanel:ctor(showType)
	local beauty_img = display.newImage("fcpy_icon_31.png")
	self:addChild(beauty_img)
	Coord.ingap(self,beauty_img,"LL",0,"BB",0)
	local message_img = nil
	if showType == 1 then
		SoundsManager.playSound("fcpy_start_wager")
		message_img = display.newImage("fcpy_icon_29.png")
	else
		SoundsManager.playSound("fcpy_end_wager")
		message_img = display.newImage("fcpy_icon_30.png")
	end
	Coord.outgap(beauty_img,message_img,"RL",-100,"TT",-50)
	self:addChild(message_img)
	self:runAction(cc.Sequence:create({
			cc.DelayTime:create(2),
			cc.FadeTo:create(1,0),
			cc.CallFunc:create(function(sender)
				sender:removeFromParent(true)
				instance = nil
			end)
	}))
end

function HaoChePiaoYiBeautyPanel.show(showType)
	if instance == nil then
		instance = HaoChePiaoYiBeautyPanel.new(showType)
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return HaoChePiaoYiBeautyPanel
