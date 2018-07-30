--[[--
 * 声音管理
 * @author GWJ
 * 
]]

local ShuiHuZhuanSoundController = class("ShuiHuZhuanSoundController")
local instance = nil
local time_handler = nil
function ShuiHuZhuanSoundController:ctor()
	self.turnOverCount = 0
	self.only_handler = nil
end

function ShuiHuZhuanSoundController:playTurnOver()
	if self.turnOverCount>2 then return end
	self.turnOverCount = self.turnOverCount + 1
	SoundsManager.playSound("flzt_turnOver",false,function()
		self.turnOverCount = self.turnOverCount - 1
	end)
end

function ShuiHuZhuanSoundController:playOnlySound(name)
	if self.long_handler then return end
	self.only_handler = SoundsManager.playSound(name)
end

function ShuiHuZhuanSoundController:roundOver()
	self.only_handler = nil
end


function ShuiHuZhuanSoundController.getInstance()
	if instance == nil then
		instance = ShuiHuZhuanSoundController.new()
	end
	return instance
end

return ShuiHuZhuanSoundController