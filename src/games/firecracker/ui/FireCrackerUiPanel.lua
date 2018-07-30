--[[
 *	鞭炮UI
 *	@author gwj
]]
local FireCrackerUiPanel = class("FireCrackerUiPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"))

function FireCrackerUiPanel:ctor()
	self.isFreeState = false	--是否免费状态
	self.isShowRemind = false	--是否显示提示
	self.isFreeBegin = false	--是否开始过免费模式
	self.isFreeOver = false	    --是否免费结束
	self.controller = require("src.games.firecracker.data.FirecrackerController").getInstance()
	local main_layout = display.newImage("#game/firecracker/firecracker_Base_bg.jpg")
	main_layout:setAnchorPoint(cc.p(0,0))
	self:addChild(main_layout)
	self.main_layout = main_layout
	--内容
	local content_layout = display.newImage("#game/firecracker/firecracker_content.png")
	content_layout:setAnchorPoint(cc.p(0,0))
	local content_size = content_layout:getContentSize()
	content_layout:setPosition(cc.p((D_SIZE.width - content_size.width)/2,(D_SIZE.height - content_size.height)/2))
	self.main_layout:addChild(content_layout,1)
	self.content_layout = content_layout
	--普通状态下的顶部标题
	local titie_img = display.newImage("firecracker_bg_7.png")
	self.main_layout:addChild(titie_img,2)
	Coord.outgap(content_layout,titie_img,"CC",0,"TB",-35)
	self.title_layout = titie_img
	--顶部提醒控件
	local img_remind = display.newImage()
	self.main_layout:addChild(img_remind,2)
	Coord.outgap(content_layout,img_remind,"CC",0,"TB",50)
	self.img_remind = img_remind
	
	--底部
	local bottom_img = display.newImage("firecracker_bg_2.png")
	bottom_img:setScale9Enabled(true)
	bottom_img:setCapInsets(cc.rect(0,0,1,1))
	bottom_img:setContentSize(cc.size(D_SIZE.width,58))
	self.main_layout:addChild(bottom_img,0)
	Coord.ingap(self.main_layout,bottom_img,"LL",0,"BB",0)
	self.bottom_img = bottom_img
	local zf_img = display.newImage("firecracker_font_11.png")
	Coord.ingap(bottom_img,zf_img,"LL",140,"CC",0)
	bottom_img:addChild(zf_img)
	local zf_txt = display.newNumberText(Player.gold,34,Color.GWJ_I)
	zf_txt:setAnchorPoint(cc.p(0,0.5))
	bottom_img:addChild(zf_txt)
	Coord.outgap(zf_img,zf_txt,"RL",20,"CC",0)
	bottom_img.zf_txt =zf_txt


	local bt_center_img = display.newImage("firecracker_bg_6.png")
	bt_center_img:setScale9Enabled(true)
	bt_center_img:setCapInsets(cc.rect(7,7,109,53))
	bt_center_img:setContentSize(cc.size(400,67))
	bottom_img:addChild(bt_center_img)
	Coord.ingap(bottom_img,bt_center_img,"CC",0,"BB",0)
	local yf_img = display.newImage("firecracker_font_10.png")
	bt_center_img:addChild(yf_img)
	Coord.ingap(bt_center_img,yf_img,"LL",70,"CC",0)
	local yf_txt = display.newNumberText(0,34,Color.GWJ_II)
	bt_center_img:addChild(yf_txt)
	yf_txt:setAnchorPoint(cc.p(0,0.5))
	Coord.outgap(yf_img,yf_txt,"RL",20,"CC",0)
	bottom_img.yf_txt =yf_txt
	local tz_img = display.newImage("firecracker_font_8.png")
	Coord.outgap(bt_center_img,tz_img,"RL",30,"CC",0)
	bottom_img:addChild(tz_img)
	tz_img:setPositionY(bottom_img:getContentSize().height/2)
	local tz_txt = display.newNumberText(0,34,Color.GWJ_I)
	tz_txt:setAnchorPoint(cc.p(0,0.5))
	bottom_img:addChild(tz_txt)
	Coord.outgap(tz_img,tz_txt,"RL",20,"CC",0)
	bottom_img.tz_txt =tz_txt
	tz_txt:setPositionY(tz_img:getPositionY())
	--开始按钮
	local start_btn = require("src.games.firecracker.ui.FireCrackerStartButton").new(1)
	self.main_layout:addChild(start_btn)
	Coord.ingap(self.main_layout,start_btn,"RR",-5,"BB",80)
	local hor_Panel = require("src.games.firecracker.ui.FireCrackerHorShootPanel").new()
	Coord.outgap(start_btn,hor_Panel,"LR",0,"CC",0)
	self.main_layout:addChild(hor_Panel,2)
	hor_Panel:addEventListener("HOR_SHOOTPANEL_CLICK",function(event,value)
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
	local add_btn = display.newButton("firecracker_btn_2.png",nil,nil)
	self.main_layout:addChild(add_btn)
	add_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	self:dispatchEvent("UI_MAIN_EVENT","ADD_BET",nil)
        end
    end)
    Coord.ingap(self.main_layout,add_btn,"RR",-3,"BB",340)
    self.add_btn = add_btn
    --减少按钮
    local cutDown_btn = display.newButton("firecracker_btn_4.png",nil,nil)
	self.main_layout:addChild(cutDown_btn)
	cutDown_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	self:dispatchEvent("UI_MAIN_EVENT","CUTDOWN_BET",nil)
        end
    end)
    Coord.ingap(self.main_layout,cutDown_btn,"RR",-3,"BB",470)
    self.cutDown_btn = cutDown_btn
    --规则按钮
    local rule_btn = display.newButton("firecracker_btn_11.png",nil,nil)
	self.main_layout:addChild(rule_btn,3)
	rule_btn:addTouchEventListener(function(sender,eventype)
	    if eventype == ccui.TouchEventType.ended then  
	    	require("src.games.firecracker.ui.FireCrackerRulePanel").show()
	    end
    end)
    Coord.ingap(self.main_layout,rule_btn,"RR",-10,"TT",-15)
    --银行按钮
    local bank_btn = display.newButton("firecracker_btn_6.png",nil,nil)
	self.main_layout:addChild(bank_btn,3)
	bank_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	display.showWindow("src.ui.window.bank.BankWindows")
        end
    end)
    Coord.ingap(self.main_layout,bank_btn,"LL",3,"BB",130)
    --加速按钮
    local quicken_btn = display.newButton("firecracker_btn_5.png",nil,nil)
	self.main_layout:addChild(quicken_btn,3)
	quicken_btn.isSpeedUp = false
	quicken_btn:addTouchEventListener(function(sender,eventype)
	    if eventype ~= ccui.TouchEventType.ended then
	    	if sender.isSpeedUp then
	    		sender:loadTextureNormal("firecracker_btn_5.png",1)
	    		sender.isSpeedUp = false
	    	else
	    		sender:loadTextureNormal("firecracker_btn_7.png",1)
	    		sender.isSpeedUp = true
	    	end
	    	self:dispatchEvent("UI_MAIN_EVENT","SPEEDUP_EVENT",sender.isSpeedUp)
        end
    end)
    Coord.ingap(self.main_layout,quicken_btn,"LL",3,"BB",250)
    self:initFreeLayout()
end

function FireCrackerUiPanel:initFreeLayout()
	--免费状态下的顶部
	local free_layout = display.newLayout()
	local content_size = self.content_layout:getContentSize()
	free_layout:setContentSize(cc.size(content_size.width,120))	--高度不重要
	self.main_layout:addChild(free_layout,3)
	self.free_layout = free_layout
	Coord.outgap(self.content_layout,free_layout,"CC",0,"TT",-10)
	--免费次数显示
	local freeCount_font = display.newImage("firecracker_font_1.png")
	free_layout:addChild(freeCount_font)
	Coord.ingap(free_layout,freeCount_font,"LL",80,"TB",0)
	local freeCount_label = ccui.TextAtlas:create(30,"game/firecracker/fontnumber_27X37.png",27,37,0)
	self.free_layout:addChild(freeCount_label)
	Coord.outgap(freeCount_font,freeCount_label,"CC",0,"TB",5)
	free_layout.freeCount_label = freeCount_label
	--顶部总赢赏
	local zys_img = display.newImage("firecracker_bg_8.png")
	Coord.ingap(free_layout,zys_img,"CC",0,"TB",-2)
	free_layout:addChild(zys_img)
	local zys_font = ccui.TextAtlas:create(0,"game/firecracker/fontnumber_27X37.png",27,37,0)
	require("src.command.NumberEffect").extend(zys_font)
	zys_font:closeEffect()
	zys_img:addChild(zys_font)
	Coord.ingap(zys_img,zys_font,"CC",0,"BB",15)
	free_layout.zys_font = zys_font
	--倍数显示
	local multiple_font = display.newImage("firecracker_font_2.png")
	free_layout:addChild(multiple_font)
	Coord.ingap(free_layout,multiple_font,"RR",-100,"TB",0)
	self:showNormal()
end

function FireCrackerUiPanel:showFree(freeWinMoney)
	self.isFreeState = true
	self.main_layout:loadTexture("game/firecracker/firecracker_free_bg.jpg",0)
	self.title_layout:setVisible(false)
	self.free_layout:setVisible(true)
	self.add_btn:setVisible(false)
	self.cutDown_btn:setVisible(false)
	self:startFirework()
	self:hidRemid()
	self.start_btn:setVisible(false)
	SoundsManager.stopAllMusic()
	SoundsManager.playMusic("firecracker_free_bg",true)
	self:updateFreeCount()
	self:setFreeZys(freeWinMoney)
	self:updateBet()
	if not self.isFreeBegin then
		local free_title_image = display.newImage("firecracker_font_12.png")
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
end

function FireCrackerUiPanel:sendStartEvent()
	self:dispatchEvent("UI_MAIN_EVENT","START_EVENT",nil)
end

function FireCrackerUiPanel:showNormal()
	self.isFreeOver = false
	self.isFreeState = false
	self.isFreeBegin = false
	self.main_layout:loadTexture("game/firecracker/firecracker_Base_bg.jpg",0)
	self.title_layout:setVisible(true)
	self.free_layout:setVisible(false)
	self.img_remind:setVisible(false)
	self.add_btn:setVisible(true)
	self.cutDown_btn:setVisible(true)
	self.start_btn:setVisible(true)
	self:stopFirework()
	SoundsManager.stopAllMusic()
	SoundsManager.playMusic("firecracker_bg",true)
	self:updateBet()
	if self.free_mask_layout then
		self.free_mask_layout:removeFromParent(true)
		self.free_mask_layout = nil
	end
end

function FireCrackerUiPanel:updateBeginState()
	self.isShowRemind = false
	self.bottom_img.yf_txt:setFormatNumber(0)
	self:hidRemid()
end

function FireCrackerUiPanel:updateOverState(winMoney,totalFreeWinMoney,delay)
	if self.isFreeState then
		if self.controller:getFreeCount() <= 0 then
			self.isFreeOver = true
			self.main_layout:runAction(cc.Sequence:create({
				cc.DelayTime:create(delay),
				cc.CallFunc:create(function(sender)
					require("src.games.firecracker.ui.FireRewardPanel").show(totalFreeWinMoney,function()
						self:showNormal()
						self:dispatchEvent("UI_MAIN_EVENT","FREE_OVER_EVENT",nil)
					end)
				end)
			}))
		end
		self:updateFreeCount()
		self:setFreeZys(totalFreeWinMoney)
	end
	self:setWinScore(winMoney)
	self:updateScore()
end

--免费总赢赏
function FireCrackerUiPanel:setFreeZys(value)
	self.free_layout.zys_font:setNumer(value,30,0.05)
end

function FireCrackerUiPanel:enterFreeState(freeWinMoney)
	if not self.isFreeState then
		self:showFree(freeWinMoney)
	end
end

--免费次数
function FireCrackerUiPanel:updateFreeCount()
	self.free_layout.freeCount_label:setString(self.controller:getFreeCount())
end
--设置投注
function FireCrackerUiPanel:updateBet()
	if self.isFreeState and self.controller.free_bet_money > 0 then
		self.bottom_img.tz_txt:setFormatNumber(self.controller.free_bet_money)
	else
		self.bottom_img.tz_txt:setFormatNumber(self.controller.betMoney)
	end
end
--设置总分
function FireCrackerUiPanel:updateScore()
	self.bottom_img.zf_txt:setFormatNumber(Player.gold)
end
--设置赢分
function FireCrackerUiPanel:setWinScore(value)
	self.bottom_img.yf_txt:setNumer(value,10,0.05)
end

function FireCrackerUiPanel:winMoneyStop()
	self.bottom_img.yf_txt:stopEffect()
	if self.isFreeState then
		self.free_layout.zys_font:stopEffect()
	end
end

local FIREWORK_POINTS={
	cc.p(D_SIZE.width-100,600),
	cc.p(50,500),
	cc.p(200,650),
	cc.p(100,500),
	cc.p(400,650),
	cc.p(100,650),
	cc.p(200,500),
}

--[[播放烟花]]
function FireCrackerUiPanel:startFirework()
	if self.action_firework then return end
	--Command.getRandomNumber(value)
	self.action_firework=self:schedule(function()
		local effect=cc.Sprite:create()
		effect:setPosition(FIREWORK_POINTS[Command.random(#FIREWORK_POINTS)])
		self.main_layout:addChild(effect,0)
		local array={}
		table.insert(array,resource.getAnimateByKey("action_fk_fireworks",false))
		table.insert(array,cc.CallFunc:create(
			function(sender)
				sender:getParent():removeChild(sender,true)
			end))
		effect:runAction(cc.Sequence:create(array))
	end,Command.random(2))
end

--[[停止烟花]]
function FireCrackerUiPanel:stopFirework()
	if self.action_firework then
		self:stopAction(self.action_firework)
		self.action_firework=nil
	end
end

--[[显示提醒]]
function FireCrackerUiPanel:showRemind(gtype)
	if self.isShowRemind then return end
	if gtype == 1 then
		self.img_remind:loadTexture("firecracker_font_4.png",1)		--相同5个
	elseif gtype == 2 then
		self.img_remind:loadTexture("firecracker_font_5.png",1)		--3个可以免费
	elseif gtype == 3 then
		self.img_remind:loadTexture("firecracker_font_3.png",1)		--全屏大奖
	end
	if not self.isFreeState then
		self.title_layout:setVisible(false)
		self.img_remind:setScale(1.4)
		Coord.outgap(self.content_layout,self.img_remind,"CC",0,"TB",5)
	else
		self.img_remind:setScale(1)
		Coord.outgap(self.bottom_img,self.img_remind,"CC",0,"TB",9)
	end
	self.img_remind:setVisible(true)
	self.isShowRemind = true
end

--[[隐藏提醒]]
function FireCrackerUiPanel:hidRemid()
	if not self.isFreeState then
		self.title_layout:setVisible(true)
	else
		self.title_layout:setVisible(false)
	end
	self.img_remind:setVisible(false)
end

function FireCrackerUiPanel:updateAutoCount(value)
	-- self.start_btn:setText(value)
	self.start_btn:setText("∞")
end

function FireCrackerUiPanel:getContentLayout()
	return self.content_layout
end

function FireCrackerUiPanel:setStartBtnState(state)
	self.start_btn:pauseShowType(state)
end

function FireCrackerUiPanel:gameOver()
	self.start_btn:pauseShowType(1)
end

return FireCrackerUiPanel
