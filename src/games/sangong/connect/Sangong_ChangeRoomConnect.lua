--[[
*	三公 换桌请求
*	端口号：1210
]]
local Sangong_ChangeRoomConnect = class("Sangong_ChangeRoomConnect",BaseConnect)
Sangong_ChangeRoomConnect.port = Port.PORT_SANGONG
Sangong_ChangeRoomConnect.type = 7

function Sangong_ChangeRoomConnect:ctor()
	
end
function Sangong_ChangeRoomConnect:writeData(data)
	
end

function Sangong_ChangeRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.sangong.data.Sangong_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
	end
	self.params = result
end

return Sangong_ChangeRoomConnect