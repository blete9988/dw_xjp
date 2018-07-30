--[[
*	抢庄牛牛 换桌请求
*	端口号：1210
]]
local Qznn_ChangeRoomConnect = class("Qznn_ChangeRoomConnect",BaseConnect)
Qznn_ChangeRoomConnect.port = Port.PORT_QZNN
Qznn_ChangeRoomConnect.type = 7

function Qznn_ChangeRoomConnect:ctor()
	
end
function Qznn_ChangeRoomConnect:writeData(data)
	
end

function Qznn_ChangeRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.qiangzhuangniuniu.data.Qznn_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
	end
	self.params = result
end

return Qznn_ChangeRoomConnect