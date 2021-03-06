--[[
 *	飞龙在天
 *	@author gwj
]]
local FeiLongZaiTianSceneUiPanel = class("FeiLongZaiTianSceneUiPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"))

function FeiLongZaiTianSceneUiPanel:ctor()
	self.isFreeState = false  --是否处于免费显示状态
	self.isFreeOver = false	    --是否免费结束
	self.controller = require("src.games.feilongzaitian.data.FeiLongZaiTianController").getInstance()
	local main_layout = display.newImage("#game/feilongzaitian/flzt_normal_bg.jpg")
	main_layout:setAnchorPoint(cc.p(0,0))
	self:addChild(main_layout)
	self.main_layout = main_layout
	--内容
	local content_layout = display.newImage("#game/feilongzaitian/flzt_content.png")
	content_layout:setAnchorPoint(cc.p(0,0))
	local content_size = content_layout:getContentSize()
	content_layout:setPosition(cc.p((D_SIZE.width - content_size.width)/2,(D_SIZE.height - content_size.height)/2))
	self.main_layout:addChild(content_layout,1)
	self.content_layout = content_layout
	--普通状态下的顶部标题
	local titie_img = display.newImage("flzt_icon_1.png")
	self.main_layout:addChild(titie_img,2)
	Coord.outgap(content_layout,titie_img,"CC",0,"TB",-35)
	self.title_layout = titie_img
	--顶部提醒控件
	local img_remind = display.newImage()
	self.main_layout:addChild(img_remind,2)
	Coord.outgap(content_layout,img_remind,"CC",0,"TB",50)
	self.img_remind = img_remind
	--底部
	local bottom_img = display.newImage("gwj_ui_bg_2.png")
	bottom_img:setScale9Enabled(true)
	bottom_img:setCapInsets(cc.rect(0,0,1,1))
	bottom_img:setContentSize(cc.size(D_SIZE.width,58))
	self.main_layout:addChild(bottom_img,0)
	Coord.ingap(self.main_layout,bottom_img,"LL",0,"BB",0)
	local zf_img = display.newImage("gwj_ui_font_11.png")
	Coord.ingap(bottom_img,zf_img,"LL",140,"CC",0)
	bottom_img:addChild(zf_img)
	local zf_txt = display.newNumberText(Player.gold,34,Color.GWJ_I)
	zf_txt:setAnchorPoint(cc.p(0,0.5))
	bottom_img:addChild(zf_txt)
	Coord.outgap(zf_img,zf_txt,"RL",20,"CC",0)
	bottom_img.zf_txt =zf_txt
	local bt_center_img = display.newImage("gwj_ui_bg_6.png")
	bt_center_img:setScale9Enabled(true)
	bt_center_img:setCapInsets(cc.rect(7,7,109,53))
	bt_center_img:setContentSize(cc.size(400,67))
	bottom_img:addChild(bt_center_img)
	Coord.ingap(bottom_img,bt_center_img,"CC",0,"BB",0)
	local yf_img = display.newImage("gwj_ui_font_10.png")
	bt_center_img:addChild(yf_img)
	Coord.ingap(bt_center_img,yf_img,"LL",70,"CC",0)
	local yf_txt = display.newNumberText(0,34,Color.GWJ_II)
	yf_txt:setAnchorPoint(cc.p(0,0.5))
	bt_center_img:addChild(yf_txt)
	Coord.outgap(yf_img,yf_txt,"RL",20,"CC",0)
	bottom_img.yf_txt =yf_txt
	local tz_img = display.newImage("gwj_ui_font_8.png")
	Coord.outgap(bt_center_img,tz_img,"RL",30,"CC",0)
	bottom_img:addChild(tz_img)
	tz_img:setPositionY(bottom_img:getContentSize().height/2)
	local tz_txt = display.newNumberText(1,34,Color.GWJ_I)
	tz_txt:setAnchorPoint(cc.p(0,0.5))
	bottom_img:addChild(tz_txt)
	Coord.outgap(tz_img,tz_txt,"RL",20,"CC",0)
	bottom_img.tz_txt =tz_txt
	tz_txt:setPositionY(tz_img:getPositionY())
	self.bottom_img = bottom_img
	--开始按钮
	local start_btn = require("src.games.feilongzaitian.ui.FeiLongZaiTianStartButton").new(1)
	self.main_layout:addChild(start_btn)
	Coord.ingap(self.main_layout,start_btn,"RR",-18,"BB",80)
	local hor_Panel = require("src.games.feilongzaitian.ui.FeiLongZaiTianRightShootPanel").new()
	Coord.outgap(start_btn,hor_Panel,"LR",0,"CC",0)
	self.main_layout:addChild(hor_Panel,2)
	hor_Panel:addEventListener("RIGHT_SHOOTPANEL_CLICK",function(event,value)

		self:dispatchEvent("UI_MAIN_EVENT","ACTO_EVENT",value)
		start_btn:showType(2)
	end)

	start_btn:addEventListener("START_CLICK",function(event,islong,btntype)
		if btntype == 1 then
			if islong and not self.isFreeState then
				-- hor_Panel:show()
				self:dispatchEvent("UI_MAIN_EVENT","ACTO_EVENT",999)
				start_btn:showType(2)
			else
				hor_Panel:moveGo()
				self:sendStartEvent()
			end
		elseif btntype ==2 then
			if islong then
				self:dispatchEvent("UI_MAIN_EVENT","ACTO_EVENT",0)
				start_btn:pauseShowType(1)
			else
				self:sendStartEvent()
			end
		else
			if not islong then
				self:sendStartEvent()
			end
		end
	end)
	self.start_btn = start_btn
	--添加按钮
	local add_btn = display.newButton("gwj_ui_btn_2.png",nil,nil)
	self.main_layout:addChild(add_btn)
	add_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	self:dispatchEvent("UI_MAIN_EVENT","ADD_BET",nil)
        end
    end)
    Coord.ingap(self.main_layout,add_btn,"RR",-15,"BB",340)
    self.add_btn = add_btn
    --减少按钮
    local cutDown_btn = display.newButton("gwj_ui_btn_4.png",nil,nil)
	self.main_layout:addChild(cutDown_btn)
	cutDown_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	self:dispatchEvent("UI_MAIN_EVENT","CUTDOWN_BET",nil)
        end
    end)
    Coord.ingap(self.main_layout,cutDown_btn,"RR",-15,"BB",470)
    self.cutDown_btn = cutDown_btn
    --规则按钮
    local rule_btn = display.newButton("gwj_ui_btn_11.png",nil,nil)
	self.main_layout:addChild(rule_btn,3)
	rule_btn:addTouchEventListener(function(sender,eventype)
	    if eventype == ccui.TouchEventType.ended then
	    	require("src.games.feilongzaitian.ui.FeiLongZaiTianRulePanel").show()
        end
    end)
    Coord.ingap(self.main_layout,rule_btn,"RR",-10,"TT",-15)
    
    local multiple_label = ccui.TextAtlas:create(1,"game/feilongzaitian/flzt_number_4.png",42,60,0)
	self.multiple_label = multiple_label

    local left_Panel = require("src.games.feilongzaitian.ui.FeiLongZaiTianLeftShootPanel").new()
	self.main_layout:addChild(left_Panel,2)
	left_Panel:addEventListener("LEFT_SHOOTPANEL_CLICK",function(event,value)
		multiple_label:setString(value)
		self.controller:setBetMultiple(value)
	    self:updateScore()
	end)
    --倍数按钮
    local multiple_btn = display.newImage("gwj_ui_btn_3.png")
    multiple_btn:setTouchEnabled(true)
	self.main_layout:addChild(multiple_btn)
	multiple_btn:addChild(multiple_label)
	Coord.ingap(multiple_btn,multiple_label,"CC",0,"BB",20)
	multiple_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	left_Panel:show()
        end
    end)
    Coord.ingap(self.main_layout,multiple_btn,"LL",18,"BB",120)
    Coord.outgap(multiple_btn,left_Panel,"RL",0,"TT",0)
    self.multiple_btn = multiple_btn

    --银行按钮
    local bank_btn = display.newButton("gwj_ui_btn_6.png",nil,nil)
	self.main_layout:addChild(bank_btn,3)
	bank_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	display.showWindow("src.ui.window.bank.BankWindows")
        end
    end)
    Coord.ingap(self.main_layout,bank_btn,"LL",18,"BB",300)

    --加速按钮
    local quicken_btn = display.newButton("gwj_ui_btn_5.png",nil,nil)
	self.main_layout:addChild(quicken_btn,3)
	quicken_btn.isSpeedUp = false
	quicken_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	if sender.isSpeedUp then
	    		sender:loadTextureNormal("gwj_ui_btn_5.png",1)
	    		sender.isSpeedUp = false
	    	else
	    		sender:loadTextureNormal("gwj_ui_btn_7.png",1)
	    		sender.isSpeedUp = true
	    	end
	    	self:dispatchEvent("UI_MAIN_EVENT","SPEEDUP_EVENT",sender.isSpeedUp)
        end
    end)
    Coord.ingap(self.main_layout,quicken_btn,"LL",18,"BB",500)
    self:initFree()
end

--免费显示初始化
function FeiLongZaiTianSceneUiPanel:initFree()
	local free_tit_layout = display.newLayout()
	free_tit_layout:setContentSize(cc.size(self.content_layout:getContentSize().width,50))
	free_tit_layout:setVisible(false)
	self.main_layout:addChild(free_tit_layout)
	Coord.outgap(self.content_layout,free_tit_layout,"LL",0,"TB",10)
	self.free_tit_layout = free_tit_layout
	local free_count_font = display.newImage("flzt_font_1.png")
	self.free_tit_layout:addChild(free_count_font)
	Coord.ingap(self.free_tit_layout,free_count_font,"LL",20,"BB",0)
	local current_count_label = ccui.TextAtlas:create(0,"game/feilongzaitian/flzt_number_1.png",22,29,0)
	current_count_label:setPosition(cc.p(204,18))
	free_count_font:addChild(current_count_label)
	self.free_tit_layout.current_count_label = current_count_label
	local max_count_label = ccui.TextAtlas:create(5,"game/feilongzaitian/flzt_number_1.png",22,29,0)
	max_count_label:setPosition(cc.p(300,18))
	free_count_font:addChild(max_count_label)
	self.free_tit_layout.max_count_label = max_count_label
	local zgjr_image = display.newImage("flzt_font_2.png")
	self.free_tit_layout:addChild(zgjr_image)
	Coord.ingap(self.free_tit_layout,zgjr_image,"RR",-120,"BB",0)
	local zgjr_count_label = ccui.TextAtlas:create(0,"game/feilongzaitian/flzt_number_1.png",22,29,0)
	self.free_tit_layout:addChild(zgjr_count_label)
	Coord.ingap(self.free_tit_layout,zgjr_count_label,"RR",-80,"BB",0)
	local zgjr_icon = display.newImage("flzt_dragon_ball.png")
	zgjr_icon:setScale(0.3)
	zgjr_icon:setPosition(cc.p(zgjr_count_label:getPositionX() + 70,zgjr_count_label:getPositionY()))
	self.free_tit_layout:addChild(zgjr_icon)
	self.free_tit_layout.zgjr_count_label = zgjr_count_label
	self:updateFreeCount()
end

--设置免费模式
function FeiLongZaiTianSceneUiPanel:showFree(totalFreeWinMoney)
	self.title_layout:setVisible(false)
	self.add_btn:setVisible(false)
	self.cutDown_btn:setVisible(false)
	self.multiple_btn:setVisible(false)
	self.free_tit_layout:setVisible(true)
	self.start_btn:setVisible(false)
	self.main_layout:loadTexture("game/feilongzaitian/flzt_free_bg.jpg")
	self.content_layout:loadTexture("game/feilongzaitian/flzt_free_content.png")
	SoundsManager.playMusic("flzt_freeBg",true)
	self.isFreeState = true
	self:updateFreeCount()
	self:updateMaxCount()
	self:updateBet()
	self:updateDragonBall(self.controller.dragon_ball)
	self.bottom_img.yf_txt:setString(totalFreeWinMoney)
	self.isFreeBegin = false
	local free_title_image = display.newImage("flzt_icon_3.png")
	Coord.ingap(self.main_layout,free_title_image,"CC",0,"CC",0)
	self.main_layout:addChild(free_title_image,10)
	self.free_title_image = free_title_image

	local free_mask_layout = display.newLayout(cc.size(D_SIZE.width,D_SIZE.height))
	free_mask_layout:setTouchEnabled(true)
	self.main_layout:addChild(free_mask_layout,2)
	free_mask_layout:addTouchEventListener(function(sender,eventype)
	    if eventype == ccui.TouchEventType.ended then
	    	if self.isFreeOver then return end
	    	if self.free_title_image then
	    		self.isFreeBegin = true
	    		self.free_title_image:removeFromParent(true)
	    		self.free_title_image = nil
	    	end
			self:sendStartEvent()
        end
    end)
    self.free_mask_layout = free_mask_layout
end

function FeiLongZaiTianSceneUiPanel:showNormal()
	self.isFreeOver = false
	self.title_layout:setVisible(true)
	self.add_btn:setVisible(true)
	self.cutDown_btn:setVisible(true)
	self.multiple_btn:setVisible(true)
	self.free_tit_layout:setVisible(false)
	self.start_btn:setVisible(true)
	self.main_layout:loadTexture("game/feilongzaitian/flzt_normal_bg.jpg")
	self.content_layout:loadTexture("game/feilongzaitian/flzt_content.png")
	SoundsManager.stopAllMusic()
	self.isFreeState = false
	self:updateBet()
	if self.free_mask_layout then
		self.free_mask_layout:removeFromParent(true)
		self.free_mask_layout = nil
	end
end

function FeiLongZaiTianSceneUiPanel:sendStartEvent()
	self:dispatchEvent("UI_MAIN_EVENT","START_EVENT",nil)
end

--进入免费的特效
function FeiLongZaiTianSceneUiPanel:enterFreeEffect(value)
	if self.isFreeState then
		require("src.games.feilongzaitian.ui.FeiLongZaiTianRewardPanel").show(3,value)
	else
		self:runAction(cc.Sequence:create({
			cc.DelayTime:create(1),
			cc.CallFunc:create(function(sender)
				self:showFree(0)
				require("src.games.feilongzaitian.ui.FeiLongZaiTianRewardPanel").show(2,value)
			end)}))
	end
end

function FeiLongZaiTianSceneUiPanel:updateBeginFreeLabels()
	if self.isFreeState then
		self:updateFreeCount()
	else
		self.bottom_img.yf_txt:setString(0)
	end
end

function FeiLongZaiTianSceneUiPanel:updateFreeOverState(winMoney,dragonball,totalFreeWinMoney,delay)
	if self.isFreeState then
		self.bottom_img.yf_txt:setNumer(totalFreeWinMoney)
		if self.controller.maxFreeCount == self.controller.freeCountNow then
			self.isFreeOver = true
			self.main_layout:runAction(cc.Sequence:create({
				cc.DelayTime:create(delay),
				cc.CallFunc:create(function(sender)
					require("src.games.feilongzaitian.ui.FeiLongZaiTianRewardPanel").show(1,totalFreeWinMoney,function()
						self:updateScore()
						self:setWinScore(0)
						self:showNormal()
						self:dispatchEvent("UI_MAIN_EVENT","FREE_OVER_EVENT",totalFreeWinMoney)
					end)
				end)
			}))
		else
			self:updateDragonBall(dragonball)
			self:updateMaxCount()
			self:updateScore()
		end
	else
		self:setWinScore(winMoney)
	end
end

function FeiLongZaiTianSceneUiPanel:updateDragonBall(value)
	local count = tonumber(self.free_tit_layout.zgjr_count_label:getString())
	if value > count then
		require("src.games.feilongzaitian.ui.FeiLongZaiTianRewardPanel").show(4,value)
	end
	self.free_tit_layout.zgjr_count_label:setString(value)
end

--更新当前免费次数
function FeiLongZaiTianSceneUiPanel:updateFreeCount()
	self.free_tit_layout.current_count_label:setString(self.controller.freeCountNow)
end
--更新总的免费次数
function FeiLongZaiTianSceneUiPanel:updateMaxCount()
	self.free_tit_layout.max_count_label:setString(self.controller.maxFreeCount)
end
--设置投注
function FeiLongZaiTianSceneUiPanel:updateBet()
	if self.isFreeState and self.controller.free_bet_money > 0 then
		self.bottom_img.tz_txt:setFormatNumber(self.controller.free_bet_money)
	else
		self.bottom_img.tz_txt:setFormatNumber(self.controller.betMoney)
	end
end
--更新总分
function FeiLongZaiTianSceneUiPanel:updateScore()
	local temp = math.ceil(Player.gold/self.controller.betMultiple)
	self.bottom_img.zf_txt:setFormatNumber(temp)
end
--设置赢分
function FeiLongZaiTianSceneUiPanel:setWinScore(value)
	self.bottom_img.yf_txt:setNumer(math.ceil(value/self.controller.betMultiple))
	self:updateScore()
end
function FeiLongZaiTianSceneUiPanel:winMoneyStop()
	self.bottom_img.yf_txt:stopEffect()
end
function FeiLongZaiTianSceneUiPanel:updateAutoCount(value)
	-- self.start_btn:setText(value)
	self.start_btn:setText("∞")
end
function FeiLongZaiTianSceneUiPanel:getContentLayout()
	return self.content_layout
end
function FeiLongZaiTianSceneUiPanel:setStartBtnState(state)
	self.start_btn:pauseShowType(state)
end

function FeiLongZaiTianSceneUiPanel:gameOver()
	self.start_btn:pauseShowType(1)
end


return FeiLongZaiTianSceneUiPanel
