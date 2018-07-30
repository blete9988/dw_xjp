--[[
 *	规则弹窗
 *	@author gwj
]]
local ShuiHuZhuanRulePanel = class("ShuiHuZhuanRulePanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil


function ShuiHuZhuanRulePanel:ctor()
	local rule_bg_img = display.newImage("#game/shuihuzhuan/shz_rule_bg.png")
	self:addChild(rule_bg_img)
	Coord.ingap(self,rule_bg_img,"CC",0,"CC",80)
	local bottom_bg = display.newImage("shz_panel_5.png")
	display.setS9(bottom_bg,cc.rect(5,5,5,5),cc.size(1065,400))
	rule_bg_img:addChild(bottom_bg)
	Coord.ingap(rule_bg_img,bottom_bg,"CC",0,"BB",20)
	local rule_font_img = display.newImage("shz_icon_25.png")
	rule_bg_img:addChild(rule_font_img)
	Coord.ingap(rule_bg_img,rule_font_img,"CC",0,"TT",-20)

	local close_btn = display.newButton("shz_btn_22_normal.png","shz_btn_22_click.png",nil)
	rule_bg_img:addChild(close_btn)
	close_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
		self:removeFromParent(true)
		instance = nil
	end)
	Coord.ingap(rule_bg_img,close_btn,"RR",-10,"TT",-10)

	local photo_scroll = display.newScrollView(1,true)
	photo_scroll:setContentSize(cc.size(958,380))
	Coord.ingap(bottom_bg,photo_scroll,"CC",0,"TT",-10)
	local content_img = display.newImage("#game/shuihuzhuan/shz_rule_content.png")
	content_img:setAnchorPoint(cc.p(0,0))
	photo_scroll:addChild(content_img)
    bottom_bg:addChild(photo_scroll)
    photo_scroll:setPosition(cc.p(10,10))
    photo_scroll:jumpToTop()
    local scroll_height = content_img:getContentSize().height
    photo_scroll:setInnerContainerSize(cc.size(958,scroll_height))
end

function ShuiHuZhuanRulePanel.show()
	if instance == nil then
		instance = ShuiHuZhuanRulePanel.new()
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return ShuiHuZhuanRulePanel
