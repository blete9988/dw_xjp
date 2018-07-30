--[[
*	外链服务器 key值获取，该值用于登陆外链服务器
*	端口号：1100
]]
local ServerKeyConnect = class("ServerKeyConnect",BaseConnect)
ServerKeyConnect.port = Port.PORT_NORMAL
ServerKeyConnect.type = 7

function ServerKeyConnect:ctor(callback)
	self.callback = callback
end
function ServerKeyConnect:writeData(data)
	
end
function ServerKeyConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		Player.setSecretID( data:readInt() )
	end
	self.params = result
end

return ServerKeyConnect