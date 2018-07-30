--[[--
 * 声音管理
 * @author GWJ
 * 
]]

local BaoDaRenSoundController = class("BaoDaRenSoundController")
local instance = nil
local time_handler = nil
function BaoDaRenSoundController:ctor()
	self.chile_handler = nil
	self.turnOverCount = 0
end


function BaoDaRenSoundController:playTurnOver()
	if self.turnOverCount > 2 then return end
	self.turnOverCount = self.turnOverCount + 1
	SoundsManager.playSound("bdr_turnOver",false,function()
		self.turnOverCount = self.turnOverCount - 1
	end)
end

function BaoDaRenSoundController:playOnlySoundChiLe(name)
	if self.chile_handler then return end
	self.chile_handler = SoundsManager.playSound(name)
end

function BaoDaRenSoundController:roundOver()
	self.chile_handler = nil
	self.turnOverCount = 0
end


function BaoDaRenSoundController.getInstance()
	if instance == nil then
		instance = BaoDaRenSoundController.new()
	end
	return instance
end

return BaoDaRenSoundController