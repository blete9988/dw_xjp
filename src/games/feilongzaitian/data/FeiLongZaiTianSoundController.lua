--[[--
 * 飞龙在天声音管理
 * @author GWJ
 * 
]]

local FeiLongZaiTianSoundController = class("FeiLongZaiTianSoundController")
local instance = nil
local time_handler = nil
function FeiLongZaiTianSoundController:ctor()
	self.turnOverCount = 0
	self.long_handler = nil
end

function FeiLongZaiTianSoundController:playTurnOver()
	if self.turnOverCount>2 then return end
	self.turnOverCount = self.turnOverCount + 1
	SoundsManager.playSound("flzt_turnOver",false,function()
		self.turnOverCount = self.turnOverCount - 1
	end)
end

function FeiLongZaiTianSoundController:playOnlySoundLong(name)
	if self.long_handler then return end
	self.long_handler = SoundsManager.playSound(name)
end

function FeiLongZaiTianSoundController:roundOver()
	self.long_handler = nil
	self.turnOverCount = 0
end


function FeiLongZaiTianSoundController.getInstance()
	if instance == nil then
		instance = FeiLongZaiTianSoundController.new()
	end
	return instance
end

return FeiLongZaiTianSoundController