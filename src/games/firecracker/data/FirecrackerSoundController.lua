--[[--
 * 鞭炮声音管理
 * @author GWJ
 * 
]]

local FirecrackerSoundController = class("FirecrackerSoundController")
local instance = nil
local time_handler = nil
function FirecrackerSoundController:ctor()
	self.turnOverCount = 0
	self.overHandler = nil
end

function FirecrackerSoundController:playTurnOver()
	if self.turnOverCount > 2 then return end
	self.turnOverCount = self.turnOverCount + 1
	SoundsManager.playSound("firecracker_playover",false,function()
		self.turnOverCount = self.turnOverCount - 1
	end)
end

function FirecrackerSoundController:playOnlyOverSound(name)
	if self.overHandler then return end
	self.overHandler = SoundsManager.playSound(name)
end

function FirecrackerSoundController:playClick()
	SoundsManager.playSound("firecrack_click")
end

function FirecrackerSoundController:roundOver()
	self.overHandler = nil
	self.turnOverCount = 0
end

function FirecrackerSoundController.getInstance()
	if instance == nil then
		instance = FirecrackerSoundController.new()
	end
	return instance
end

return FirecrackerSoundController