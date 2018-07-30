--[[
 *	规则弹窗
 *	@author gwj
]]
local HaoChePiaoYiRulePanel = class("HaoChePiaoYiRulePanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil


function HaoChePiaoYiRulePanel:ctor()
	local rule_bg_img = display.newImage("#game/haochepiaoyi/fcpy_rule_bg.png")
	self:addChild(rule_bg_img)
	Coord.ingap(self,rule_bg_img,"CC",0,"CC",0)
	local bottom_bg = display.newImage("fcpy_icon_48.png")
	display.setS9(bottom_bg,cc.rect(5,5,5,5),cc.size(1065,350))
	rule_bg_img:addChild(bottom_bg)
	Coord.ingap(rule_bg_img,bottom_bg,"CC",0,"BB",20)
	local rule_font_img = display.newImage("fcpy_icon_49.png")
	rule_bg_img:addChild(rule_font_img)
	Coord.ingap(rule_bg_img,rule_font_img,"CC",0,"TT",-20)
	local introduce_btn = display.newButton("fcpy_btn_17.png",nil,nil)
	Coord.ingap(rule_bg_img,introduce_btn,"LL",60,"CC",160)
	rule_bg_img:addChild(introduce_btn)
	introduce_btn:setTouchEnabled(false)
	-- introduce_btn:setEnabled(false)
	local rule_btn = display.newButton("fcpy_btn_19.png",nil,nil)
	Coord.outgap(introduce_btn,rule_btn,"RL",40,"CC",0)
	rule_bg_img:addChild(rule_btn)
	rule_btn:setTouchEnabled(true)

	local content_img = display.newImage("#game/haochepiaoyi/fcpy_guize_content.png")
	content_img:setAnchorPoint(cc.p(0,1))
	bottom_bg:addChild(content_img)
	Coord.ingap(bottom_bg,content_img,"LL",10,"TT",-10)

	local close_btn = display.newButton("fcpy_rule_btn-close.png","fcpy_rule_btn_close-dj.png",nil)
	rule_bg_img:addChild(close_btn)
	close_btn:addTouchEventListener(function(sender,eventype)
		self:removeFromParent(true)
		instance = nil
	end)
	Coord.ingap(rule_bg_img,close_btn,"RR",-10,"TT",-10)

	local function menu_click(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
		if sender == introduce_btn then
			sender:loadTextureNormal("fcpy_btn_17.png",1)
			rule_btn:loadTextureNormal("fcpy_btn_19.png",1)
			rule_btn:setTouchEnabled(true)
			sender:setTouchEnabled(false)
			content_img:loadTexture("game/haochepiaoyi/fcpy_guize_content.png",0)
		else
			sender:loadTextureNormal("fcpy_btn_18.png",1)
			introduce_btn:loadTextureNormal("fcpy_btn_16.png",1)
			introduce_btn:setTouchEnabled(true)
			sender:setTouchEnabled(false)
			content_img:loadTexture("game/haochepiaoyi/fcpy_rule_content.png",0)
		end
	end
	rule_btn:addTouchEventListener(menu_click)
	introduce_btn:addTouchEventListener(menu_click)


end

function HaoChePiaoYiRulePanel.show()
	if instance == nil then
		instance = HaoChePiaoYiRulePanel.new()
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return HaoChePiaoYiRulePanel
