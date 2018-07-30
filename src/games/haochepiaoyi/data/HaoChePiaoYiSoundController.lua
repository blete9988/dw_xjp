--[[--
 * 豪车飘逸声音管理
 * @author GWJ
 * 
]]

local HaoChePiaoYiSoundController = class("HaoChePiaoYiSoundController")
local instance = nil
local time_Handler = nil
function HaoChePiaoYiSoundController:ctor()
	self.playTurnCount = 0
	self.scoreCount = 0
end

function HaoChePiaoYiSoundController:playTurnSound()
	if self.playTurnCount >= 4 then return end
	local function turnSoundBack()
		self.playTurnCount = self.playTurnCount - 1
	end
	self.playTurnCount = self.playTurnCount + 1
	SoundsManager.playSound("fcpy_turn",false,turnSoundBack)
end

function HaoChePiaoYiSoundController:playScoreSound()
	if self.scoreCount >= 4 then return end
	self.scoreCount = self.scoreCount + 1
	SoundsManager.playSound("fcpy_score",false,function()
		self.scoreCount = self.scoreCount - 1
	end) 
end

function HaoChePiaoYiSoundController.getInstance()
	if instance == nil then
		instance = HaoChePiaoYiSoundController.new()
	end
	return instance
end

return HaoChePiaoYiSoundController