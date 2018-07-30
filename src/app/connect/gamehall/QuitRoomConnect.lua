--[[
*	退出  游戏房间
*	端口号：1100
]]
local QuitRoomConnect = class("QuitRoomConnect",BaseConnect)
QuitRoomConnect.port = Port.PORT_NORMAL
QuitRoomConnect.type = 5

QuitRoomConnect.notShowLoading = true

function QuitRoomConnect:ctor()
	
end
function QuitRoomConnect:writeData(data)
	
end
function QuitRoomConnect:readData(data)
--	local result = data:readUnsignedByte()
--	if result ~= 0 then
--		self:showTips(result)
--	end
end

return QuitRoomConnect