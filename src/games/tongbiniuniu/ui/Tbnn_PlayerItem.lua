--[[
*	通比牛牛 玩家头像
*	@author：lqh
]]
local Tbnn_PlayerItem = class("Tbnn_PlayerItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(130,190))
end)

function Tbnn_PlayerItem:ctor(index)
	self:super("ctor")
	self.index = index
	self:setAnchorPoint( cc.p(0.5,0.5) )
	
	local winnerEffect = display.newSprite("tbnn_ui_1015.png")
	self:addChild(Coord.ingap(self,winnerEffect,"CC",0,"TC",0))
	winnerEffect:setVisible(false)
	--胜利背景
	local winnerBg = display.newImage("tbnn_ui_1013.png")
	winnerBg:setScale(1.15)
	self:addChild(Coord.ingap(self,winnerBg,"CC",0,"CC",0,true))
	local winnerIcon = display.newImage("tbnn_ui_1014.png")
	winnerBg:addChild(Coord.ingap(winnerBg,winnerIcon,"CC",0,"TT",5,true))
	winnerBg:setVisible(false)
	
	--半透明黑色背景
	local background = display.setS9(display.newImage("tbnn_panel_1001.png"),cc.rect(15,15,10,10),cc.size(130,190))
	self:addChild(Coord.ingap(self,background,"CC",0,"CC",0))
	--是否已准备图标
	local readyPic = display.newImage("tbnn_ui_1012.png")
	self:addChild(readyPic)
	readyPic:setVisible(false)
	
	--头像底框
	local head_frame = display.newImage("tbnn_ui_1020.png")
	display.setS9(head_frame,cc.rect(15,15,15,15),cc.size(120,120))
	self:addChild(Coord.ingap(self,head_frame,"CC",0,"CC",0))
	--头像
	local headicon = display.newDynamicImage()
	headicon:setScale(0.85)
	self:addChild(Coord.outgap(background,headicon,"CC",0,"CC",0))
	
	--进度条
	local progressItem = require("src.base.control.RadialProgressComponent").new(display.setS9(display.newImage("tbnn_ui_1021.png"),cc.rect(15,15,15,15),cc.size(120,120)))
	self:addChild(Coord.outgap(head_frame,progressItem,"CC",0,"CC",0))
	progressItem:setDuration(20)
	progressItem:setPercent(1)
	--名字文本
	local nameTxt = display.newText("测试啊啊",22)
	self:addChild(Coord.outgap(head_frame,nameTxt,"CC",0,"TB",3))
	--金钱文本
	local goldTxt = display.newText(0,22)
	self:addChild(Coord.outgap(head_frame,goldTxt,"CC",0,"BT",-3))
	
	self.m_winnerEffect = winnerEffect
	self.m_winnerBg = winnerBg
	self.m_readyPic = readyPic
	self.m_headicon = headicon
	self.m_nameTxt = nameTxt
	self.m_goldTxt = goldTxt
	self.m_progressItem = progressItem
	
	self:setPlayerInfo()
end
--设置准备图片坐标
function Tbnn_PlayerItem:setReadyPicPos(pos)
	self.m_readyPic:setPosition(pos)
end
--开始倒计时
function Tbnn_PlayerItem:beganCountdown(tm)
	if tm == 0 then
		self.m_progressItem:setPercent(1)
		if self.playerInfo and self.playerInfo:isSelf() then
			SoundsManager.stopAudio("tbnn_countdown")
		end
	else
		if not self.playerInfo then return end
		self.m_progressItem:setPercentFrom(0,1,tm)
		if self.playerInfo:isSelf() then
			SoundsManager.playSound("tbnn_countdown",true)
		end
	end
end
--更新信息
function Tbnn_PlayerItem:updateInfo()
	if not self.playerInfo then return end
	self.m_goldTxt:setString(string.cnspNmbformat(self.playerInfo.gold))
end
--更新准备状态图标
function Tbnn_PlayerItem:updateReadyStatus()
	if not self.playerInfo then return end
	if self.playerInfo:isReady() then
		if self.playerInfo:isSelf() then
			SoundsManager.playSound("tbnn_ready")
		end
		self.m_readyPic:setVisible(true)
		
	else
		self.m_readyPic:setVisible(false)
	end
end
--设置玩家信息
function Tbnn_PlayerItem:setPlayerInfo(playerInfo)
	self.m_winnerEffect:setVisible(false)
	self.m_winnerBg:setVisible(false)
	self.playerInfo = playerInfo
	if not playerInfo then
		self:setVisible(false)
	else
		self:setVisible(true)
		self.m_progressItem:setPercent(1)
		self.m_headicon:loadTexture(playerInfo.pic)
		self.playerInfo:setClientIndex(self.index)
		
		self.m_nameTxt:setString(playerInfo.name)
		self:updateInfo()
		self:updateReadyStatus()
	end
end
--显示胜利动画
function Tbnn_PlayerItem:showWinnerEffect(playerInfo)
	if not self.playerInfo or not self.playerInfo:isWinner() then return end
	
	self.m_winnerEffect:setVisible(true)
	self.m_winnerBg:setVisible(true)
	self.m_winnerEffect:setRotation(0)
	self.m_winnerEffect:runAction(cc.Sequence:create({
		cc.RotateTo:create(2,220),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self.m_winnerEffect:setVisible(false)
			self.m_winnerBg:setVisible(false)
		end),
	}))
end
return Tbnn_PlayerItem