--[[
*	获取 游戏房间所有玩家信息
*	端口号：1100
]]
local RoomPlayersConnect = class("RoomPlayersConnect",BaseConnect)
RoomPlayersConnect.port = Port.PORT_NORMAL
RoomPlayersConnect.type = 1

function RoomPlayersConnect:ctor(callback)
	self.callback = callback
end
function RoomPlayersConnect:writeData(data)
	
end
function RoomPlayersConnect:readData(data)
	local result = data:readUnsignedByte()
	local playerList = {}
	if result == 0 then
		local len = data:readShort()
		local info,myinfo
		for i = 1,len do
			info = require("src.app.data.PlayerInfo").new():normalBytesRead(data)
			if info.id == Player.id then
				myinfo = info
			else
				table.insert(playerList,info)
			end
		end
		table.sort(playerList,function(a,b) 
			return b.gold > a.gold
		end)
		if myinfo then
			table.insert(playerList,1,myinfo)
		end
	else
		self:showTips(result)
	end
	self.params = {result = result,playerList = playerList}
end

return RoomPlayersConnect