--[[
*	获取 游戏房间数据
*	端口号：1100
]]
local GameRoomConnect = class("GameRoomConnect",BaseConnect)
GameRoomConnect.port = Port.PORT_NORMAL
GameRoomConnect.type = 3

function GameRoomConnect:ctor(gamedata,callback)
	self.gamedata = gamedata
	self.callback = callback
end
function GameRoomConnect:writeData(data)
	data:writeShort(self.gamedata.sid)
end
function GameRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		self.gamedata:bytesRead(data)
	else
		self:showTips(result)
	end
	self.params = result
end

return GameRoomConnect