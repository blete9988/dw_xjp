--[[
 *	规则弹窗
 *	@author gwj
]]
local BaoDaRenRulePanel = class("BaoDaRenRulePanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)

function BaoDaRenRulePanel:ctor()
	local main_layout = display.newImage("#game/baodaren/bdr_rule_bg.png")
	local main_size = main_layout:getContentSize()
	self:addChild(main_layout)
	main_layout:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height + main_size.height/2))
	self.main_layout = main_layout
	-- Coord.ingap(self,main_layout,"CC",0,"CC",0)
	--关闭按钮
    local close_btn = display.newButton("gwj_ui_btn_12.png",nil,nil)
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
    local content_imgI = display.newImage("#game/baodaren/bdr_rule_3.png")
    content_imgI:setAnchorPoint(cc.p(0,0))
    content_imgI:setPosition(cc.p(23,0))
    photo_scroll:addChild(content_imgI)

    local content_imgII = display.newImage("#game/baodaren/bdr_rule_2.png")
    content_imgII:setAnchorPoint(cc.p(0,0))
    content_imgII:setPosition(cc.p(23,content_imgI:getContentSize().height))
    photo_scroll:addChild(content_imgII)
    

    local content_imgIII = display.newImage("#game/baodaren/bdr_rule_1.png")
    content_imgIII:setAnchorPoint(cc.p(0,0))
    content_imgIII:setPosition(cc.p(23,content_imgII:getContentSize().height + content_imgII:getPositionY()))
    photo_scroll:addChild(content_imgIII)

    self.main_layout:addChild(photo_scroll)
    photo_scroll:setContentSize(cc.size(1158,577))
    photo_scroll:setPosition(cc.p(5,12))
    photo_scroll:jumpToTop()
    local scroll_height = content_imgI:getContentSize().height + content_imgII:getContentSize().height + content_imgIII:getContentSize().height
    photo_scroll:setInnerContainerSize(cc.size(1158,scroll_height))
    self.main_layout:runAction(cc.MoveTo:create(0.2,cc.p(D_SIZE.width/2,D_SIZE.height/2)))
end

function BaoDaRenRulePanel.show()
	local ranle = BaoDaRenRulePanel.new()
	display.getRunningScene():addChild(ranle)
end

return BaoDaRenRulePanel