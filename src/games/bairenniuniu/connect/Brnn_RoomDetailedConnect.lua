--[[
*	百人牛牛 游戏房间详细数据请求
*	端口号：1208
]]
local Brnn_RoomDetailedConnect = class("Brnn_RoomDetailedConnect",BaseConnect)
Brnn_RoomDetailedConnect.port = Port.PORT_BRNN
Brnn_RoomDetailedConnect.type = 1

function Brnn_RoomDetailedConnect:ctor()
	
end
function Brnn_RoomDetailedConnect:writeData(data)
	
end

function Brnn_RoomDetailedConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
	end
	self.params = result
end

return Brnn_RoomDetailedConnect