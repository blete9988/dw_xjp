--[[
*	倒计时 item
*	@author：lqh
]]
local CountDownItem = class("CountDownItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(210,40))
end)

function CountDownItem:ctor(betvalue)
	self:super("ctor")
	
	local txtImg = display.newImage("ui_hhdz_1011.png")
	self:addChild(Coord.ingap(self,txtImg,"LL",0,"CC",0))
	local cdlabel = cc.Label:createWithCharMap(display.getTexture("game/hongheidazhan/hhdz_number_2.png"),40,30,string.byte("0"))
	cdlabel:setAnchorPoint( cc.p(0,0.5) )
	self:addChild(Coord.outgap(txtImg,cdlabel,"RL",20,"CC",0))
	
	self.m_cdlabel = cdlabel
end

function CountDownItem:stop()
	self:stopAllActions()
	self:setVisible(false)
end
--[[
*	设置目标时间
*	@param value 时间
]]
function CountDownItem:setTargetTimeStamp(value)
	self:stop()
	self.m_targetTimeStamp = value
	self.m_cd = self.m_targetTimeStamp - ServerTimer.time
	self.m_cdlabel:setString(self.m_cd)
	
	self:setVisible(true)
	self:m_beganTime()
end
function CountDownItem:m_beganTime()
	self:onTimer(function(t) 
		if not t then return end
		local cd = self.m_targetTimeStamp - ServerTimer.time
		if cd >= self.m_cd then return end
		self.m_cd = cd
		self.m_cdlabel:setString(cd)
			--开启闹铃，最后5s触发
		if self.m_cd < 5 then SoundsManager.playSound("hhdz_cd") end
		
		if cd < 0 then
			self:stop()
		end
	end,0.2)
end
return CountDownItem