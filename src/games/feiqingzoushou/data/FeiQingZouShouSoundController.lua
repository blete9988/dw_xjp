--[[--
 * 飞禽走兽声音管理
 * @author GWJ
 * 
]]

local FeiQingZouShouSoundController = class("FeiQingZouShouSoundController")
local instance = nil
function FeiQingZouShouSoundController:ctor()
	self.playTurnCount = 0
	self.scoreCount = 0
end

function FeiQingZouShouSoundController:playTurnSound()
	if self.playTurnCount >= 4 then return end
	self.playTurnCount = self.playTurnCount + 1
	SoundsManager.playSound("fqzs_turn",false,function()
		self.playTurnCount = self.playTurnCount - 1
	end)
end

function FeiQingZouShouSoundController:playScoreSound()
	if self.scoreCount >= 4 then return end
	self.scoreCount = self.scoreCount + 1
	SoundsManager.playSound("fqzs_score",false,function()
		self.scoreCount = self.scoreCount - 1
	end) 
end

function FeiQingZouShouSoundController:roundOver()
	self.scoreCount = 0
	self.playTurnCount = 0
end

function FeiQingZouShouSoundController.getInstance()
	if instance == nil then
		instance = FeiQingZouShouSoundController.new()
	end
	return instance
end

return FeiQingZouShouSoundController