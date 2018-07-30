--[[
*	一拳超人开始游戏
*	端口号：1204
]]
local FistSuperManPlayConnect = class("FistSuperManPlayConnect",BaseConnect)
FistSuperManPlayConnect.port = Port.PORT_FISTSUPERMAN
FistSuperManPlayConnect.type = 2

function FistSuperManPlayConnect:ctor(betMoney,callback)
	self.betMoney = betMoney
	self.callback = callback
end

function FistSuperManPlayConnect:writeData(data)
	data:writeInt(self.betMoney)
end

function FistSuperManPlayConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local controller = require("src.games.fistsuperman.data.FistsupermanController").getInstance()
		local content_data = require("src.games.fistsuperman.data.FistsupermanContentData").new(controller:isFree())
		content_data:byteRead(data)
		controller:updateFreeCount(content_data.useFreeCount)
		controller:updateMaxFreeCount(content_data.useFreeCount + content_data.surplusFreeCount)
		self.params = content_data
	end
	
end

return FistSuperManPlayConnect