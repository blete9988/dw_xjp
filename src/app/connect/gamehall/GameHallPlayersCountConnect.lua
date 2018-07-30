--[[
*	获取 游戏大厅人数 请求
*	端口号：1100
]]
local GameHallPlayersCountConnect = class("GameHallPlayersCountConnect",BaseConnect)
GameHallPlayersCountConnect.port = Port.PORT_NORMAL
GameHallPlayersCountConnect.type = 20
GameHallPlayersCountConnect.notShowLoading = true

function GameHallPlayersCountConnect:ctor()
	
end
function GameHallPlayersCountConnect:writeData(data)
	
end
function GameHallPlayersCountConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		Player.gameMgr:updateGameHallPlayersCount(data)
	else
		self:showTips(result)
	end
end

return GameHallPlayersCountConnect