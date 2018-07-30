--[[
*	红黑大战 游戏房间详细数据请求
*	端口号：1300
]]
local Hhdz_RoomDetailedConnect = class("Hhdz_RoomDetailedConnect",BaseConnect)
Hhdz_RoomDetailedConnect.port = Port.PORT_HHDZ
Hhdz_RoomDetailedConnect.type = 1

function Hhdz_RoomDetailedConnect:ctor()
	
end
function Hhdz_RoomDetailedConnect:writeData(data)
	
end

function Hhdz_RoomDetailedConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.hongheidazhan.data.Hhdz_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
	end
	self.params = result
end

return Hhdz_RoomDetailedConnect