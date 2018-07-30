--[[
*	通比牛牛 换桌请求
*	端口号：1209
]]
local Tbnn_ChangeRoomConnect = class("Tbnn_ChangeRoomConnect",BaseConnect)
Tbnn_ChangeRoomConnect.port = Port.PORT_TBNN
Tbnn_ChangeRoomConnect.type = 5

function Tbnn_ChangeRoomConnect:ctor()
	
end
function Tbnn_ChangeRoomConnect:writeData(data)
	
end

function Tbnn_ChangeRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
	end
	self.params = result
end

return Tbnn_ChangeRoomConnect