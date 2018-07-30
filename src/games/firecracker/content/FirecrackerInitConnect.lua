--[[
*	初始化
*	端口号：1208
]]
local FirecrackerInitConnect = class("FirecrackerInitConnect",BaseConnect)
FirecrackerInitConnect.port = Port.PORT_ZHAOCHAIBIANPAO
FirecrackerInitConnect.type = 1

function FirecrackerInitConnect:ctor(callback)
	self.callback = callback
end

function FirecrackerInitConnect:writeData(data)
end

function FirecrackerInitConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local controller = require("src.games.firecracker.data.FirecrackerController").getInstance()
		controller:byteRead(data)
		self.params = true
	end
	
end

return FirecrackerInitConnect