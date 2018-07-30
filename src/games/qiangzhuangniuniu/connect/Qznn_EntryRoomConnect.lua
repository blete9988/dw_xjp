--[[
*	抢庄牛牛 加入房间请求
*	端口号：1210
]]
local Qznn_EntryRoomConnect = class("Qznn_EntryRoomConnect",BaseConnect)
Qznn_EntryRoomConnect.port = Port.PORT_QZNN
Qznn_EntryRoomConnect.type = 1

function Qznn_EntryRoomConnect:ctor()
	
end
function Qznn_EntryRoomConnect:writeData(data)
	
end

function Qznn_EntryRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.qiangzhuangniuniu.data.Qznn_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
		WindowMgr.closeAllWindow()
	end
	self.params = result
end

return Qznn_EntryRoomConnect