--[[
*	闹钟倒计时
*	@author：gwj
]]
local ClockCountDownItem = class("ClockCountDownItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newSprite("jsys_time_bg.png")
end)

function ClockCountDownItem:ctor()
	self:super("ctor")
	local cdlabel = ccui.TextAtlas:create("","game/jinshayinsha/jsys_number_4.png",18,21,0)
	-- cdlabel:setString(30)
	self:addChild(Coord.ingap(self,cdlabel,"CC",0,"CC",2))
	self.m_cdlabel = cdlabel
end

function ClockCountDownItem:stop()
	if self.m_timehandler then
		timestop(self.m_timehandler)
		self.m_timehandler = nil
		SoundsManager.stopAudio(self.m_soundhandler)
		self.m_soundhandler = nil
		self.m_realdate = nil
		self:setPositionY(self.m_defaultY)
		self.m_cdlabel:setString(self.m_countdown)
	end
end
--[[
*	设置倒计时
*	@param value 时间
*	@param needRing 是否需要5S响铃，默认不
]]
function ClockCountDownItem:setCountDown(value,needRing,backfunction)
	self:stop()
	self.isRing = false
	self.m_cdlabel:setString(value)
	self.m_countdown = value
	self.m_needRing = needRing
	self.m_realdate = os.millis()
	self.backfunction = backfunction
	self.m_defaultY = self:getPositionY()
	self.m_timehandler = timeup(handler(self,self.m_timecallback),0.1)
end
function ClockCountDownItem:m_timecallback(tm)
	local nowdate = os.millis()
	local delay = nowdate - self.m_realdate
	if delay >= 1000 then
		self.m_realdate = self.m_realdate + delay - delay%1000
		self.m_countdown = self.m_countdown  - math.floor(delay/1000)
		if self.m_needRing and self.m_countdown <= 5 then
			--开启闹铃，最后5s触发
			if self.m_countdown <= 5 and not self.isRing then
				self.m_soundhandler = SoundsManager.playSound("jsys_time_qiaozhong")
				self.isRing = true
			end
		end
		if self.m_countdown < 10 then
			self.m_cdlabel:setString("0"..self.m_countdown)
		else
			self.m_cdlabel:setString(self.m_countdown)
		end
		if self.m_countdown == 0 then
			self:stop()
			if self.backfunction then
				self.backfunction()
			end
			self.isRing = false
		end
	end
end

function ClockCountDownItem:onCleanup()
	if self.m_timehandler then
		timestop(self.m_timehandler)
		self.m_timehandler = nil
	end
end
return ClockCountDownItem