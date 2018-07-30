--[[
*	闹钟倒计时
*	@author：lqh
]]
local ClockCountDownItem = class("ClockCountDownItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newSprite("fcpy_clock_icon.png")
end)

function ClockCountDownItem:ctor(value,needRing,backfunction)
	self:super("ctor")
	local cdlabel = cc.Label:createWithCharMap(display.getTexture("game/haochepiaoyi/fcpy_number_1.png"),23,33,string.byte("0"))
	cdlabel:setString(value)
	self:addChild(Coord.ingap(self,cdlabel,"CC",0,"CC",5))
	self.m_cdlabel = cdlabel
	self.needRing = needRing
	self.backfunction = backfunction
	self.m_soundhandler = SoundsManager.playSound("fcpy_countdown",true)
	self.m_defaultY = self:getPositionY()
	self.m_countdown = value
	self.isRing = false
	self.m_realdate = os.millis()
	self:schedule(function()
		self:m_timecallback()
	end,0.1)
end

function ClockCountDownItem:m_timecallback()
	if self.m_countdown <= 0 then
		self:clean()
	end
	local nowdate = os.millis()
	local delay = nowdate - self.m_realdate
	if delay >= 1000 then
		self.m_realdate = self.m_realdate + delay - delay%1000
		self.m_countdown = self.m_countdown  - math.floor(delay/1000)
		if self.needRing and self.m_countdown <= 5 then
			--开启闹铃，最后5s触发
			if self.m_countdown <= 5 and not self.isRing then
				self:setPositionY(self:getPositionY() + 15)
				self.m_cdlabel:setString("")
				--播放闹铃剩余
				SoundsManager.stopAudio(self.m_soundhandler)
				self.m_soundhandler = SoundsManager.playSound("fcpy_countdown_ring", true)
				self:runAction(resource.getAnimateByKey("fcpy_clock_ring_"..self.m_countdown,false,true))
				self.isRing = true
			end
		else
			self.m_cdlabel:setString(self.m_countdown)
		end
		if self.m_countdown == 0 then
			self:stopAllActions()
			self.isRing = false
			SoundsManager.stopAudio(self.m_soundhandler)
			self:clean()
		end
	end
end

function ClockCountDownItem:clean()
	if self.backfunction then
		self.backfunction()
	end
	self:removeFromParent(true)
end

function ClockCountDownItem:getSurplusTime()
	return self.m_countdown
end

function ClockCountDownItem:onCleanup()
	if self.m_soundhandler then
		SoundsManager.stopAudio(self.m_soundhandler)
		self.m_soundhandler = nil
	end
end
return ClockCountDownItem