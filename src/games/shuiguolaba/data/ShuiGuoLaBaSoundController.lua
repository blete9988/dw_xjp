--[[--
 * 声音管理
 * @author GWJ
 * 
]]

local ShuiGuoLaBaSoundController = class("ShuiGuoLaBaSoundController")
local instance = nil
function ShuiGuoLaBaSoundController:ctor()
	self.playTurnCount = 0
	self.scoreCount = 0
end

function ShuiGuoLaBaSoundController:playTurnSound()
	if self.playTurnCount >= 4 then return end
	self.playTurnCount = self.playTurnCount + 1
	SoundsManager.playSound("sglb_turn",false,function()
		self.playTurnCount = self.playTurnCount - 1
	end)
end

function ShuiGuoLaBaSoundController:playScoreSound()
	SoundsManager.playSound("sglb_bet")
end

function ShuiGuoLaBaSoundController:roundOver()
	self.scoreCount = 0
	self.playTurnCount = 0
end

function ShuiGuoLaBaSoundController.getInstance()
	if instance == nil then
		instance = ShuiGuoLaBaSoundController.new()
	end
	return instance
end

return ShuiGuoLaBaSoundController