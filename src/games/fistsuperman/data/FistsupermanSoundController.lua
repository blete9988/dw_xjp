--[[--
 * 一拳超人声音管理
 * @author GWJ
 * 
]]

local FistsupermanSoundController = class("FistsupermanSoundController")
local instance = nil
local time_handler = nil
function FistsupermanSoundController:ctor()
	self:init()
end

function FistsupermanSoundController:init()
	self.turnOverCount = 0
	self.addx_handler = nil
	self.click_handler = nil
end

function FistsupermanSoundController:playTurnOver()
	if self.turnOverCount > 3 then return end
	self.turnOverCount = self.turnOverCount + 1
	SoundsManager.playSound("FS_turnOver",false,function()
		self.turnOverCount = self.turnOverCount - 1
	end)
end

function FistsupermanSoundController:playOnlySoundADDX(name)
	if self.addx_handler then return end
	self.addx_handler = SoundsManager.playSound(name)
end

function FistsupermanSoundController:playClickSound()
	self.click_handler = SoundsManager.playSound("FS_Click")
end

function FistsupermanSoundController:roundOver()
	self.addx_handler = nil
	self.turnOverCount = 0
end


function FistsupermanSoundController.getInstance()
	if instance == nil then
		instance = FistsupermanSoundController.new()
	end
	return instance
end

return FistsupermanSoundController