--[[
*	三公 加入房间请求
*	端口号：1210
]]
local Sangong_EntryRoomConnect = class("Sangong_EntryRoomConnect",BaseConnect)
Sangong_EntryRoomConnect.port = Port.PORT_SANGONG
Sangong_EntryRoomConnect.type = 1

function Sangong_EntryRoomConnect:ctor()
	
end
function Sangong_EntryRoomConnect:writeData(data)
	
end

function Sangong_EntryRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.sangong.data.Sangong_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
		WindowMgr.closeAllWindow()
	end
	self.params = result
end

return Sangong_EntryRoomConnect