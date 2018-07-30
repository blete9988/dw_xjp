--[[
 *	规则弹窗
 *	@author gwj
]]
local ShuiGuoLaBaRulePanel = class("ShuiGuoLaBaRulePanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil


function ShuiGuoLaBaRulePanel:ctor()
	local rule_bg_img = display.newImage("#game/shuiguolaba/sglb_rule_bg.png")
	self:addChild(rule_bg_img)
	Coord.ingap(self,rule_bg_img,"CC",0,"CC",0)

	local close_btn = display.newButton("sglb_btn_7.png",nil,nil)
	rule_bg_img:addChild(close_btn)
	close_btn:addTouchEventListener(function(sender,eventype)
		self:removeFromParent(true)
		instance = nil
	end)
	close_btn:setPosition(cc.p(916,577))

	local photo_scroll = display.newScrollView(1,true)
	photo_scroll:setContentSize(cc.size(790,490))
	photo_scroll:setPosition(cc.p(86,62))
	local content_img = display.newImage("#game/shuiguolaba/sglb_rule_content.png")
	content_img:setAnchorPoint(cc.p(0,0))
	photo_scroll:addChild(content_img)
    rule_bg_img:addChild(photo_scroll)
    photo_scroll:jumpToTop()
    local scroll_height = content_img:getContentSize().height
    photo_scroll:setInnerContainerSize(cc.size(790,scroll_height))

end

function ShuiGuoLaBaRulePanel.show()
	if instance == nil then
		instance = ShuiGuoLaBaRulePanel.new()
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return ShuiGuoLaBaRulePanel
