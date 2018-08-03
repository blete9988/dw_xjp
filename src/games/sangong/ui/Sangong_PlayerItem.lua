--[[
*	三公 玩家头像
*	@author：lqh
]]
local Sangong_PlayerItem = class("Sangong_PlayerItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(130,190))
end)

function Sangong_PlayerItem:ctor(index)
	self:super("ctor")
	self.index = index
	self:setAnchorPoint( cc.p(0.5,0.5) )
	
	--半透明黑色背景
	local background = display.setS9(display.newImage("qznn_panel_1001.png"),cc.rect(15,15,10,10),cc.size(130,190))
	self:addChild(Coord.ingap(self,background,"CC",0,"CC",0))
	--是否已准备图标
	local readyPic = display.newImage("qznn_ui_1012.png")
	self:addChild(readyPic)
	readyPic:setVisible(false)
	--加倍图标
	local timesPic = display.newImage("qznn_times_20.png")
	self:addChild(timesPic)
	timesPic:setVisible(false)
	
	--头像底框
	local head_frame = display.newImage("qznn_ui_1020.png")
	display.setS9(head_frame,cc.rect(15,15,15,15),cc.size(120,120))
	self:addChild(Coord.ingap(self,head_frame,"CC",0,"CC",0))
	--头像
	local headicon = display.newDynamicImage()
	headicon:setScale(0.85)
	self:addChild(Coord.outgap(background,headicon,"CC",0,"CC",0))
	
	--进度条
	local progressItem = require("src.base.control.RadialProgressComponent").new(display.setS9(display.newImage("qznn_ui_1021.png"),cc.rect(15,15,15,15),cc.size(120,120)))
	self:addChild(Coord.outgap(head_frame,progressItem,"CC",0,"CC",0))
	progressItem:setDuration(20)
	progressItem:setPercent(1)
	--名字文本
	local nameTxt = display.newText("测试啊啊",22)
	self:addChild(Coord.outgap(head_frame,nameTxt,"CC",0,"TB",3))
	--金钱文本
	local goldTxt = display.newText(0,22)
	self:addChild(Coord.outgap(head_frame,goldTxt,"CC",0,"BT",-3))
	
	local zhuangIcon = display.newSprite("qznn_ui_1026.png")
	zhuangIcon:setVisible(false)
	self:addChild(Coord.outgap(head_frame,zhuangIcon,"RC",0,"TC",0))
	
	self.m_readyPic = readyPic
	self.m_timesPic = timesPic
	self.m_headicon = headicon
	self.m_nameTxt = nameTxt
	self.m_goldTxt = goldTxt
	self.m_progressItem = progressItem
	self.m_zhuangIcon = zhuangIcon
	
	self:setPlayerInfo()
end
--设置准备图片坐标
function Sangong_PlayerItem:setReadyPicPos(pos)
	self.m_readyPic:setPosition(pos)
end
--设置加倍图标坐标
function Sangong_PlayerItem:setTimesPicPos(pos)
	self.m_timesPic:setPosition(pos)
end
--开始倒计时
function Sangong_PlayerItem:beganCountdown(tm)
	if tm == 0 then
		self.m_progressItem:setPercent(1)
		if self.playerInfo and self.playerInfo:isSelf() then
			SoundsManager.stopAudio("qznn_countdown")
		end
	else
		if not self.playerInfo then return end
		self.m_progressItem:setPercentFrom(0,1,tm)
		if self.playerInfo:isSelf() then
			SoundsManager.playSound("qznn_countdown",true)
		end
	end
end
--更新信息
function Sangong_PlayerItem:updateInfo()
	self:setPlayerInfo(self.playerInfo)
end
function Sangong_PlayerItem:updateGold()
	if not self.playerInfo then return end
	self.m_goldTxt:setString(string.cnspNmbformat(self.playerInfo.gold))
end
--更新加倍显示图标
function Sangong_PlayerItem:updateTimesStatus()
	if not self.playerInfo then return end
	if self.playerInfo.masterTimesValue >= 0 then
		self.m_timesPic:loadTexture(string.format("qznn_times_%s.png",self.playerInfo.masterTimesValue),1)
		self.m_timesPic:setVisible(true)
	elseif self.playerInfo.addTimesValue > 0 then
		self.m_timesPic:loadTexture(string.format("qznn_times_%s.png",self.playerInfo.addTimesValue),1)
		self.m_timesPic:setVisible(true)
	else
		self.m_timesPic:setVisible(false)
	end
end
--更新准备状态图标
function Sangong_PlayerItem:updateReadyStatus()
	if not self.playerInfo then return end
	if self.playerInfo:isReady() then
		if self.playerInfo:isSelf() then
			SoundsManager.playSound("qznn_ready")
		end
		self.m_readyPic:setVisible(true)
	else
		self.m_readyPic:setVisible(false)
	end
end
--显示庄家图标
function Sangong_PlayerItem:showMasterIcon(noPlayAnim)
	if not self.playerInfo or not self.playerInfo.ismaster then return end
	self.m_zhuangIcon:setVisible(true)
	if not noPlayAnim then
		SoundsManager.playSound("qznn_start")
		self.m_zhuangIcon:setOpacity(0)
		self.m_zhuangIcon:setScale(0.4)
		self.m_zhuangIcon:runAction(cc.Sequence:create({
			cc.Spawn:create({
				cc.ScaleTo:create(0.15,1.6),
				cc.FadeIn:create(0.15)
			}),
			cc.ScaleTo:create(0.07,1),
			cc.DelayTime:create(0.1),
			resource.getAnimateByKey("qznn_zhuozhuang",nil,true)
		}))
	else
		self.m_zhuangIcon:setOpacity(255)
		self.m_zhuangIcon:setScale(1)
	end
end
--显示输赢结果
function Sangong_PlayerItem:showResult()
	if not self.playerInfo then return end
	local value = self.playerInfo.resultGold
	local str
	if math.abs(value) > 999999 then
		str = math.floor(math.abs(value)/10000)
	else
		str = value
	end
	
	local goldTxt = display.newRichText()
	if value > 0 then
		if math.abs(value) > 999999 then
			goldTxt:setString(display.trans("7013",str))
		else
			goldTxt:setString(display.trans("7012",str))
		end
		local anim = display.newParticle("game/sangong/particle/star01.plist")
		anim:setPosition(cc.p(65,40))
		anim:setScale(0.5)
		self:addChild(anim)
		anim:runAction(cc.Sequence:create({
			cc.DelayTime:create(1.5),
			cc.CallFunc:create(function(t) 
				if not t then return end
				t:removeFromParent()
			end)
		}))
	else
		if math.abs(value) > 999999 then
			goldTxt:setString(display.trans("7015",str))
		else
			goldTxt:setString(display.trans("7014",str))
		end
	end
	goldTxt:setOpacity(0)
	self:addChild(Coord.ingap(self,goldTxt,"CC",0,"TB",15))
	goldTxt:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.ScaleTo:create(0.1,1.3),
			cc.FadeIn:create(0.1)
		}),
		cc.ScaleTo:create(0.1,1),
		cc.DelayTime:create(1.5),
		cc.FadeOut:create(0.5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			t:removeFromParent()
		end)
	}))
end
--设置玩家信息
function Sangong_PlayerItem:setPlayerInfo(playerInfo)
	self.playerInfo = playerInfo
	self.m_zhuangIcon:setVisible(false)
	if not playerInfo then
		self:setVisible(false)
	else
		self:setVisible(true)
		self.m_progressItem:setPercent(1)
		self.m_headicon:loadTexture(playerInfo.pic)
		self.playerInfo:setClientIndex(self.index)
		
		self.m_nameTxt:setString(playerInfo.name)
		self:updateGold()
		self:updateReadyStatus()
		self:updateTimesStatus()
	end
end
return Sangong_PlayerItem