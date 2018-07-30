--[[
*	通比牛牛 加入房间请求
*	端口号：1209
]]
local Tbnn_EntryRoomConnect = class("Tbnn_EntryRoomConnect",BaseConnect)
Tbnn_EntryRoomConnect.port = Port.PORT_TBNN
Tbnn_EntryRoomConnect.type = 1

function Tbnn_EntryRoomConnect:ctor()
	
end
function Tbnn_EntryRoomConnect:writeData(data)
	
end

function Tbnn_EntryRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
		WindowMgr.closeAllWindow()
	end
	self.params = result
end

return Tbnn_EntryRoomConnect