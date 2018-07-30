--[[
 *	规则弹窗
 *	@author gwj
]]
local FireCrackerRulePanel = class("FireCrackerRulePanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)

function FireCrackerRulePanel:ctor()
    local main_layout = display.newDynamicImage("game/firecracker/firecracker_rule_bg.png")
	local main_size = main_layout:getContentSize()
	self:addChild(main_layout)
	main_layout:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height + main_size.height/2))
	self.main_layout = main_layout
	-- Coord.ingap(self,main_layout,"CC",0,"CC",0)
	--关闭按钮
    local close_btn = display.newButton("firecracker_btn_12.png",nil,nil)
	self.main_layout:addChild(close_btn)
	close_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
			self.main_layout:runAction(cc.Sequence:create({
				cc.MoveTo:create(0.2,cc.p(D_SIZE.width/2,D_SIZE.height + main_size.height/2)),
				cc.CallFunc:create(function()
					self:removeFromParent()
				end)
			}))
	    	
        end
    end)
    Coord.ingap(self.main_layout,close_btn,"RR",25,"TT",25)

    local photo_scroll = display.newScrollView(1,true)
    local content_img = display.newDynamicImage("game/firecracker/firecracker_rule_content.png")
    content_img:setAnchorPoint(cc.p(0,0))
    photo_scroll:addChild(content_img)
    photo_scroll:setContentSize(cc.size(1158,577))
    self.main_layout:addChild(photo_scroll)
    photo_scroll:setPosition(cc.p(5,12))
    photo_scroll:jumpToTop()
    photo_scroll:setInnerContainerSize(content_img:getContentSize())
    self.main_layout:runAction(cc.MoveTo:create(0.2,cc.p(D_SIZE.width/2,D_SIZE.height/2)))
end

function FireCrackerRulePanel.show()
	local ranle = FireCrackerRulePanel.new()
	display.getRunningScene():addChild(ranle)
end

return FireCrackerRulePanel
