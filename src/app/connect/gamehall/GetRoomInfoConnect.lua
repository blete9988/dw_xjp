--[[
*	获取 房间信息
*	端口号：1100
]]
local GetRoomInfoConnect = class("GetRoomInfoConnect",BaseConnect)
GetRoomInfoConnect.port = Port.PORT_NORMAL
GetRoomInfoConnect.type = 1

--[[
*	@param callback 回调
*	@param socketid 默认为空（主socket）
]]
function GetRoomInfoConnect:ctor(callback,socket)
	self.callback = callback
	self.socket = socket
end
function GetRoomInfoConnect:writeData(data)
	
end
function GetRoomInfoConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	end
	self.params = {result = result,data = data}
end

return GetRoomInfoConnect