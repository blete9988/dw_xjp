--[[
*	百家乐 游戏房间详细数据请求
*	端口号：1200
]]
local Bjl_RoomDetailedConnect = class("Bjl_RoomDetailedConnect",BaseConnect)
Bjl_RoomDetailedConnect.port = Port.PORT_BJL
Bjl_RoomDetailedConnect.type = 1

function Bjl_RoomDetailedConnect:ctor()
	
end
function Bjl_RoomDetailedConnect:writeData(data)
	
end

function Bjl_RoomDetailedConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		require("src.games.baijiale.data.Bjl_GameMgr").getInstance():initGameBytesRead(data)
	else
		self:showTips(result)
	end
	self.params = result
end

return Bjl_RoomDetailedConnect