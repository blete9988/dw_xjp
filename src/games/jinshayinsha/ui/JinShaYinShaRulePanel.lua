--[[
 *	规则弹窗
 *	@author gwj
]]
local JinShaYinShaRulePanel = class("JinShaYinShaRulePanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil


function JinShaYinShaRulePanel:ctor()
	local rule_bg_img = display.newImage("#game/jinshayinsha/jsys_rule_bg.png")
	self:addChild(rule_bg_img)
	Coord.ingap(self,rule_bg_img,"CC",0,"CC",0)
	local bottom_bg = display.newImage("jsys_panel_5.png")
	display.setS9(bottom_bg,cc.rect(5,5,5,5),cc.size(1065,350))
	rule_bg_img:addChild(bottom_bg)
	Coord.ingap(rule_bg_img,bottom_bg,"CC",0,"BB",20)
	local rule_font_img = display.newImage("jsys_icon_3.png")
	rule_bg_img:addChild(rule_font_img)
	Coord.ingap(rule_bg_img,rule_font_img,"CC",0,"TT",-20)
	local introduce_btn = display.newButton("jsys_btn_4_disable.png",nil,nil)
	Coord.ingap(rule_bg_img,introduce_btn,"LL",60,"CC",160)
	rule_bg_img:addChild(introduce_btn)
	introduce_btn:setTouchEnabled(false)
	-- introduce_btn:setEnabled(false)
	local rule_btn = display.newButton("jsys_btn_5_normal.png",nil,nil)
	Coord.outgap(introduce_btn,rule_btn,"RL",40,"CC",0)
	rule_bg_img:addChild(rule_btn)
	rule_btn:setTouchEnabled(true)

	local content_img = display.newImage("#game/jinshayinsha/jsys_rule_1.png")
	content_img:setAnchorPoint(cc.p(0,1))
	bottom_bg:addChild(content_img)
	Coord.ingap(bottom_bg,content_img,"LL",10,"TT",-10)

	local close_btn = display.newButton("jsys_btn_6_normal.png","jsys_btn_6_click.png",nil)
	rule_bg_img:addChild(close_btn)
	close_btn:addTouchEventListener(function(sender,eventype)
		self:removeFromParent(true)
		instance = nil
	end)
	Coord.ingap(rule_bg_img,close_btn,"RR",-10,"TT",-10)

	local function menu_click(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
		if sender == introduce_btn then
			sender:loadTextureNormal("jsys_btn_4_disable.png",1)
			rule_btn:loadTextureNormal("jsys_btn_4_normal.png",1)
			rule_btn:setTouchEnabled(true)
			sender:setTouchEnabled(false)
			content_img:loadTexture("game/jinshayinsha/jsys_rule_1.png",0)
		else
			sender:loadTextureNormal("jsys_btn_5_disable.png",1)
			introduce_btn:loadTextureNormal("jsys_btn_5_normal.png",1)
			introduce_btn:setTouchEnabled(true)
			sender:setTouchEnabled(false)
			content_img:loadTexture("game/jinshayinsha/jsys_rule_2.png",0)
		end
	end
	rule_btn:addTouchEventListener(menu_click)
	introduce_btn:addTouchEventListener(menu_click)


end

function JinShaYinShaRulePanel.show()
	if instance == nil then
		instance = JinShaYinShaRulePanel.new()
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return JinShaYinShaRulePanel
