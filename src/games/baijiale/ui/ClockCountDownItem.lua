--[[
*	百家乐 闹钟倒计时
*	@author：lqh
]]
local ClockCountDownItem = class("ClockCountDownItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newSprite("bjl_ui_1008.png")
end)

function ClockCountDownItem:ctor(betvalue)
	self:super("ctor")
	
	local cdlabel = cc.Label:createWithCharMap(display.getTexture("game/baijiale/bjl_number_1.png"),23,33,string.byte("0"))
	cdlabel:setString(30)
	self:addChild(Coord.ingap(self,cdlabel,"CC",0,"CC",5))
	
	self.m_cdlabel = cdlabel
	self:setVisible(false)
end

function ClockCountDownItem:stop()
	if self.m_soundhandler then
		SoundsManager.stopAudio(self.m_soundhandler)
		self.m_soundhandler = nil
	end
	self:stopAllActions()
	
	if self.m_defaultY then
		self:setPositionY(self.m_defaultY)
	end
	self:setSpriteFrame("bjl_ui_1008.png")
	self.m_cdlabel:setString(0)
	
	self:setVisible(false)
	self.isRing = false
end
--[[
*	设置倒计时
*	@param value 时间
*	@param needRing 是否需要5S响铃，默认不
]]
function ClockCountDownItem:setTargetTimeStamp(value,needRing)
	self:stop()
	self:setVisible(true)
	
	self.m_needRing = needRing
	self.m_targetTimeStamp = value
	self.m_cd = value - ServerTimer.time
	self.m_cdlabel:setString(self.m_cd)
	
	if needRing then
		self.m_soundhandler = SoundsManager.playSound("bjl_countdown", true)
	end
	
	self.m_defaultY = self:getPositionY()
	
	self:m_beganTime()
end
function ClockCountDownItem:m_beganTime(tm)
	self:onTimer(function(t) 
		if not t then return end
		local cd = self.m_targetTimeStamp - ServerTimer.time
		if cd >= self.m_cd then return end
		self.m_cd = cd
		
		if cd <= 0 then
			if cd == 0 then
				self:setPositionY(self.m_defaultY)
				self:setSpriteFrame("bjl_ui_1008.png")
				self.m_cdlabel:setString(0)
			else
				self:stop()
			end
			return
		end
		
		if self.m_needRing and cd <= 5 then
			--开启闹铃，最后5s触发
			if not self.isRing then
				self:setPositionY(self.m_defaultY + 15)
				self.m_cdlabel:setString("")
				--播放闹铃剩余
				SoundsManager.stopAudio(self.m_soundhandler)
				self.m_soundhandler = SoundsManager.playSound("bjl_countdown_ring", true)
				
				self:runAction(resource.getAnimateByKey("bjl_clock_ring_" .. cd,false,true))
				self.isRing = true
			end
		else
			self.m_cdlabel:setString(cd)
		end
	end)
end
function ClockCountDownItem:onCleanup()
	if not self.m_soundhandler then return end
	SoundsManager.stopAudio(self.m_soundhandler)
end
return ClockCountDownItem