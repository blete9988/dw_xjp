--[[
 *	美女弹窗
 *	@author gwj
]]
local FeiQingZouShouBeautyPanel = class("FeiQingZouShouBeautyPanel",function() 
	local layout = display.extend("CCLayerExtend",display.newLayout(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil


function FeiQingZouShouBeautyPanel:ctor(showType)
	local beauty_img = display.newImage("fqzs-fly-main-role.png")
	self:addChild(beauty_img)
	Coord.ingap(self,beauty_img,"LL",-10,"BB",0)
	local message_img = nil
	if showType == 1 then
		SoundsManager.playSound("fqzs_start_wager")
		message_img = display.newImage("fqzs-fly-main-ts.png")
	else
		SoundsManager.playSound("fqzs_end_wager")
		message_img = display.newImage("fqzs-fly-main-ts2.png")
	end
	Coord.outgap(beauty_img,message_img,"RL",-50,"TT",-50)
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

function FeiQingZouShouBeautyPanel.show(showType)
	if instance == nil then
		instance = FeiQingZouShouBeautyPanel.new(showType)
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return FeiQingZouShouBeautyPanel
