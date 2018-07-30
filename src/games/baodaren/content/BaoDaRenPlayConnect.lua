--[[
*	包大人开始游戏
*	端口号：1205
]]
local BaoDaRenPlayConnect = class("BaoDaRenPlayConnect",BaseConnect)
BaoDaRenPlayConnect.port = Port.PORT_BAODAREN
BaoDaRenPlayConnect.type = 2

function BaoDaRenPlayConnect:ctor(betMoney,callback)
	self.betMoney = betMoney
	self.callback = callback
end

function BaoDaRenPlayConnect:writeData(data)
	data:writeInt(self.betMoney)
end

function BaoDaRenPlayConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local controller = require("src.games.baodaren.data.BaoDaRenController").getInstance()
		local content_data = require("src.games.baodaren.data.BaoDaRenContentData").new(controller:isFree())
		content_data:byteRead(data)
		controller:updateMaxFreeCount(content_data.useFreeCount + content_data.surplusFreeCount)
		controller:updateFreeCount(content_data.useFreeCount)
		self.params = content_data
	end
	
end

return BaoDaRenPlayConnect