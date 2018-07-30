--[[
*	招财鞭炮
*	port = 1208
*	@author：gwj
]]
local FirecrackerPlayConnect = class("FirecrackerPlayConnect",BaseConnect)
FirecrackerPlayConnect.port = Port.PORT_ZHAOCHAIBIANPAO
FirecrackerPlayConnect.type = 2
--money:下注筹码 
function FirecrackerPlayConnect:ctor(money,cb,isfree)
	self.callback = cb
	self.money = money
	self.isfree = isfree
end
function FirecrackerPlayConnect:writeData(data)
	data:writeInt(self.money)
end
function FirecrackerPlayConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local content_data = require("src.games.firecracker.data.FirecrackerContentData").new()
		content_data:byteRead(data)
		self.params = content_data
	end
end
return FirecrackerPlayConnect