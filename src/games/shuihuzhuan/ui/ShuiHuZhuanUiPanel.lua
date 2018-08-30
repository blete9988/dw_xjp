--[[
 *	水浒传UI
 *	@author gwj
]]
local ShuiHuZhuanUiPanel = class("ShuiHuZhuanUiPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"))
local YA_XIAN = 9
function ShuiHuZhuanUiPanel:ctor()
	self.isAutoState = false
	self.controller = require("src.games.shuihuzhuan.data.ShuiHuZhuanController").getInstance()
	local main_layout = display.newImage("#game/shuihuzhuan/shz_background.jpg")
	main_layout:setAnchorPoint(cc.p(0,0))
	self:addChild(main_layout)
	self.main_layout = main_layout

	local content_bg = display.newImage("#game/shuihuzhuan/shz_background_frame_bg.jpg")
	content_bg:setAnchorPoint(cc.p(0,0))
	content_bg:setPosition(cc.p(131,128))
	self.main_layout:addChild(content_bg,0)
	self.content_layout = content_bg

	local content_layout = display.newImage("#game/shuihuzhuan/shz_background_frame.png")
	local content_size = content_layout:getContentSize()
	content_layout:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
	self.main_layout:addChild(content_layout,1)

	local left_sprite = display.newSprite()
	left_sprite:setPosition(cc.p(260,680))
	self.main_layout:addChild(left_sprite,0)
	left_sprite:runAction(resource.getAnimateByKey("shz_action_dagu",true))
	local right_sprite = display.newSprite()
	right_sprite:setPosition(cc.p(1087,660))
	self.main_layout:addChild(right_sprite,0)
	right_sprite:runAction(resource.getAnimateByKey("shz_action_yaoqi_1",true))
	self.right_sprite = right_sprite

	--底部
	--name
	local name_label = display.newText(Player.name,24,Color.WHITE)
	name_label:setAnchorPoint(cc.p(0,0.5))
	name_label:setPosition(cc.p(95,95))
	self.main_layout:addChild(name_label,2)
	--vip
	local vip_icon = display.newImage("shz_icon_23.png")
	vip_icon:setPosition(cc.p(271,93))
	self.main_layout:addChild(vip_icon,2)
	local vip_label = ccui.TextAtlas:create("1","game/shuihuzhuan/shz_number_1.png",14.2,21,0)
    self.main_layout:addChild(vip_label,2)
    Coord.outgap(vip_icon,vip_label,"RL",2,"CC",0)
    --金币
	local gold_layout = display.newImage("shz_icon_2.png")
	display.setS9(gold_layout,cc.rect(30,10,30,10),cc.size(320,39))
	gold_layout:setPosition(cc.p(254,33))
	self.main_layout:addChild(gold_layout,2)
	local gold_icon = display.newImage("shz_icon_1.png")
	Coord.ingap(gold_layout,gold_icon,"LL",0,"CC",0)
	gold_layout:addChild(gold_icon)
	local gold_label = display.newText(Player.gold,24,Color.WHITE)
	gold_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(gold_icon,gold_label,"RL",20,"CC",0)
	gold_layout:addChild(gold_label)
	self.gold_label = gold_label
	--押线
	local yafen_layout = display.newImage("shz_icon_2.png")
	display.setS9(yafen_layout,cc.rect(30,10,30,10),cc.size(340,39))
	yafen_layout:setPosition(cc.p(490,95))
	self.main_layout:addChild(yafen_layout,2)
	local yaxian_icon = display.newImage("shz_icon_21.png")
	Coord.ingap(yafen_layout,yaxian_icon,"LL",10,"CC",0)
	yafen_layout:addChild(yaxian_icon)
	local yaxian_label = display.newText(YA_XIAN,24,Color.WHITE)
	yaxian_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(yaxian_icon,yaxian_label,"RL",10,"CC",0)
	yafen_layout:addChild(yaxian_label)
	local yafen_icon = display.newImage("shz_icon_20.png")
	Coord.ingap(yafen_layout,yafen_icon,"LL",180,"CC",0)
	yafen_layout:addChild(yafen_icon)
	local yafen_label = display.newText(0,24,Color.WHITE)
	yafen_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(yafen_icon,yafen_label,"RL",10,"CC",0)
	yafen_layout:addChild(yafen_label)
	self.yafen_label = yafen_label
	--得分
	local defen_layout = display.newImage("shz_icon_2.png")
	display.setS9(defen_layout,cc.rect(30,10,30,10),cc.size(450,39))
	defen_layout:setPosition(cc.p(900,95))
	self.main_layout:addChild(defen_layout,2)
	local zongyafen_icon = display.newImage("shz_icon_22.png")
	Coord.ingap(defen_layout,zongyafen_icon,"LL",10,"CC",0)
	defen_layout:addChild(zongyafen_icon)
	local zongyafen_label = display.newText(0,24,Color.WHITE)
	zongyafen_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(zongyafen_icon,zongyafen_label,"RL",10,"CC",0)
	defen_layout:addChild(zongyafen_label)
	self.zongyafen_label = zongyafen_label
	local defen_icon = display.newImage("shz_icon_3.png")
	Coord.ingap(defen_layout,defen_icon,"LL",260,"CC",0)
	defen_layout:addChild(defen_icon)
	local defen_label = display.newText(0,24,Color.WHITE)
	defen_label:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(defen_icon,defen_label,"RL",10,"CC",0)
	defen_layout:addChild(defen_label)
	self.defen_label = defen_label
	--银行按钮
	local bank_btn = require("src.ui.item.ExButton").new("shz_btn_14_normal.png",nil,"shz_btn_14_disable.png")
	bank_btn:setPosition(cc.p(489,37))
	self.main_layout:addChild(bank_btn,2)
	bank_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			display.showWindow("src.ui.window.bank.BankWindows")
	    end)
	self.bank_btn = bank_btn
	--加注按钮
	local addchip_btn = require("src.ui.item.ExButton").new("shz_btn_10_normal.png","shz_btn_10_click.png","shz_btn_10_disable.png")
	addchip_btn:setPosition(cc.p(786,38))
	self.main_layout:addChild(addchip_btn,2)
	addchip_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			self:dispatchEvent("UI_MAIN_EVENT","ADD_BET")
	    end)
	self.addchip_btn = addchip_btn
	--减注按钮
	local reduce_btn = require("src.ui.item.ExButton").new("shz_btn_3_normal.png","shz_btn_3_click.png","shz_btn_3_disable.png")
	reduce_btn:setPosition(cc.p(640,38))
	self.main_layout:addChild(reduce_btn,2)
	reduce_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			self:dispatchEvent("UI_MAIN_EVENT","CUTDOWN_BET")
	    end)
	self.reduce_btn = reduce_btn
	--比倍按钮
	local compare_btn = require("src.ui.item.ExButton").new("shz_btn_8_normal.png","shz_btn_8_click.png",nil)
	compare_btn:setPosition(cc.p(928,38))
	self.main_layout:addChild(compare_btn,2)
	compare_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			self:dispatchEvent("UI_MAIN_EVENT","DICE_ENTER")
	    end)
	compare_btn:setDisable(true)
	self.compare_btn = compare_btn
	--自动按钮
	local auto_btn = require("src.ui.item.ExButton").new("shz_btn_9_normal.png","shz_btn_9_click.png","shz_btn_9_disable.png")
	auto_btn:setPosition(cc.p(1066,38))
	self.main_layout:addChild(auto_btn,2)
	auto_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			self:setStartState(false)
			self:dispatchEvent("UI_MAIN_EVENT","ACTO_EVENT")
	    end)
	self.auto_btn = auto_btn
	--开始按钮
	local start_btn = require("src.ui.item.ExButton").new("shz_btn_1_normal.png","shz_btn_1_click.png","shz_btn_1_disable.png")
	start_btn:setPosition(cc.p(1204,57))
	start_btn.state = true
	self.main_layout:addChild(start_btn,2)
	start_btn:addTouchEventListener(function(sender,eventype)
		if eventype ~= ccui.TouchEventType.ended then return end
			self:dispatchEvent("UI_MAIN_EVENT","START_EVENT")
	    end)
	self.start_btn = start_btn

	--规则按钮
	local rule_btn = display.newButton("shz_btn_11_normal.png","shz_btn_11_click.png",nil)
	rule_btn:setPosition(cc.p(1228,634))
	self.main_layout:addChild(rule_btn,2)
	rule_btn:addTouchEventListener(function(sender,eventype)
		    if eventype == ccui.TouchEventType.ended then return end
		    require("src.games.shuihuzhuan.ui.ShuiHuZhuanRulePanel").show()
	    end)
end

function ShuiHuZhuanUiPanel:getContentLayout()
	return self.content_layout
end

function ShuiHuZhuanUiPanel:setStartState(value)
	if value then
		self.start_btn:loadTextures("shz_btn_1_normal.png","shz_btn_1_click.png","shz_btn_1_disable.png",1)
		self.start_btn.state = true
	else
		self.start_btn:setTouchEnabled(false)
		self.start_btn:setBright(false)
		self.start_btn:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.5),
			cc.CallFunc:create(function(senderI)
				senderI:loadTextures("shz_btn_2_normal.png","shz_btn_2_click.png","shz_btn_2_disable.png",1)
				senderI:setTouchEnabled(true)
				senderI:setBright(true)
				self.start_btn.state = false
			end)}))
	end
end

function ShuiHuZhuanUiPanel:beginUpdateState()
	if not self.isAutoState then
		self.auto_btn:setDisable(true)
		self.bank_btn:setDisable(true)
		self.addchip_btn:setDisable(true)
		self.reduce_btn:setDisable(true)
	end
	self.defen_label:setString(0)
end

function ShuiHuZhuanUiPanel:overUpdateState(defenScore)
	print("overUpdateState-------------------------------------------------")
	if not self.isAutoState then
		self.auto_btn:setDisable(false)
		self.bank_btn:setDisable(false)
		self.addchip_btn:setDisable(false)
		self.reduce_btn:setDisable(false)
	end
	self:updateDeFen(defenScore)
	self:updateGold()
end

function ShuiHuZhuanUiPanel:updateYaFen()
	self.yafen_label:setString(self.controller.betMoney)
	self:updateZongYaFen(self.controller.betMoney*YA_XIAN)
end

function ShuiHuZhuanUiPanel:updateZongYaFen(value)
	self.zongyafen_label:setString(value)
end

function ShuiHuZhuanUiPanel:updateDeFen(value)
	self.defen_label:setString(value)
end

function ShuiHuZhuanUiPanel:updateGold()
	print("Player.gold-------------------------------------",Player.gold)
	self.gold_label:setString(Player.gold)
end

function ShuiHuZhuanUiPanel:getBetMoney()
	return tonumber(self.zongyafen_label:getString())
end

function ShuiHuZhuanUiPanel:setCompareBtnState(value)
	self.compare_btn:setDisable(not value)
end

function ShuiHuZhuanUiPanel:autoMode()
	self.addchip_btn:setDisable(true)
	self.reduce_btn:setDisable(true)
	self.auto_btn:setDisable(true)
	self.bank_btn:setDisable(true)
	self.isAutoState = true
end

function ShuiHuZhuanUiPanel:normalMode()
	self.addchip_btn:setDisable(false)
	self.reduce_btn:setDisable(false)
	self.auto_btn:setDisable(false)
	self.bank_btn:setDisable(false)
	self.isAutoState = false
end


return ShuiHuZhuanUiPanel
