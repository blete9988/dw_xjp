--[[
 *	规则弹窗
 *	@author gwj
]]
local FeiQingZouShouRulePanel = class("FeiQingZouShouRulePanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil


function FeiQingZouShouRulePanel:ctor()
	local rule_bg_img = display.newImage("#game/feiqingzoushou/fqzs-rule-bg.png")
	self:addChild(rule_bg_img)
	Coord.ingap(self,rule_bg_img,"CC",0,"CC",0)
	local bottom_bg = display.newImage("fqzs_icon_13.png")
	display.setS9(bottom_bg,cc.rect(5,5,5,5),cc.size(1065,350))
	rule_bg_img:addChild(bottom_bg)
	Coord.ingap(rule_bg_img,bottom_bg,"CC",0,"BB",20)
	local rule_font_img = display.newImage("fqzs-gz-gz.png")
	rule_bg_img:addChild(rule_font_img)
	Coord.ingap(rule_bg_img,rule_font_img,"CC",0,"TT",-20)
	local introduce_btn = display.newButton("fqzs-btn-2.png",nil,nil)
	Coord.ingap(rule_bg_img,introduce_btn,"LL",60,"CC",160)
	rule_bg_img:addChild(introduce_btn)
	introduce_btn:setTouchEnabled(false)
	-- introduce_btn:setEnabled(false)
	local rule_btn = display.newButton("fqzs-btn-4.png",nil,nil)
	Coord.outgap(introduce_btn,rule_btn,"RL",40,"CC",0)
	rule_bg_img:addChild(rule_btn)
	rule_btn:setTouchEnabled(true)

	local content_img = display.newImage("#game/feiqingzoushou/fqzs-guize-content.png")
	content_img:setAnchorPoint(cc.p(0,1))
	self:addChild(content_img)
	Coord.ingap(self,content_img,"CC",-40,"CC",50)

	local close_btn = display.newButton("fqzs-rule-btn-close.png","fqzs-rule-btn-close-dj.png",nil)
	rule_bg_img:addChild(close_btn)
	close_btn:addTouchEventListener(function(sender,eventype)
		self:removeFromParent(true)
		instance = nil
	end)
	Coord.ingap(rule_bg_img,close_btn,"RR",-10,"TT",-10)

	local function menu_click(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
		if sender == introduce_btn then
			sender:loadTextureNormal("fqzs-btn-2.png",1)
			rule_btn:loadTextureNormal("fqzs-btn-4.png",1)
			rule_btn:setTouchEnabled(true)
			sender:setTouchEnabled(false)
			content_img:loadTexture("game/feiqingzoushou/fqzs-guize-content.png",0)
		else
			sender:loadTextureNormal("fqzs-btn-3.png",1)
			introduce_btn:loadTextureNormal("fqzs-btn-1.png",1)
			introduce_btn:setTouchEnabled(true)
			sender:setTouchEnabled(false)
			content_img:loadTexture("game/feiqingzoushou/fqzs-rule-content.png",0)
		end
	end
	rule_btn:addTouchEventListener(menu_click)
	introduce_btn:addTouchEventListener(menu_click)


end

function FeiQingZouShouRulePanel.show()
	if instance == nil then
		instance = FeiQingZouShouRulePanel.new()
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return FeiQingZouShouRulePanel
