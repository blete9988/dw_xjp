--[[
*	飞龙在天开始游戏
*	端口号：1206
]]
local FeiLongZaiTianPlayConnect = class("FeiLongZaiTianPlayConnect",BaseConnect)
FeiLongZaiTianPlayConnect.port = Port.PORT_FEILONGZAITIAN
FeiLongZaiTianPlayConnect.type = 2

function FeiLongZaiTianPlayConnect:ctor(betMoney,callback)
	self.betMoney = betMoney
	self.callback = callback
end

function FeiLongZaiTianPlayConnect:writeData(data)
	data:writeInt(self.betMoney)
end

function FeiLongZaiTianPlayConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local controller = require("src.games.feilongzaitian.data.FeiLongZaiTianController").getInstance()
		local content_data = require("src.games.feilongzaitian.data.FeiLongZaiTianContentData").new(controller:isFree())
		content_data:byteRead(data)
		controller:updateFreeCount(content_data.useFreeCount)
		controller:updateMaxFreeCount(content_data.useFreeCount + content_data.surplusFreeCount)
		self.params = content_data
	end
	
end

return FeiLongZaiTianPlayConnect