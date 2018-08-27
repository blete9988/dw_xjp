--[[
*	抢庄牛牛 加入房间请求
*	端口号：1210
]]
local Likuibuyu_EntryRoomConnect = class("Likuibuyu_EntryRoomConnect",BaseConnect)
Likuibuyu_EntryRoomConnect.port = Port.PORT_LIKUIBUYU
Likuibuyu_EntryRoomConnect.type = 1

function Likuibuyu_EntryRoomConnect:ctor()
	
end
function Likuibuyu_EntryRoomConnect:writeData(data)
	
end

function Likuibuyu_EntryRoomConnect:readData(data)
	local result = data:readUnsignedShort()
	-- mlog(DEBUG_W,"data = "..tostring(data:length()))
	-- mlog(DEBUG_W,"result = "..tostring(result))
	if result == 0 then
		require("src.games.likuibuyu.content.GameFrame").getInstance().m_secene.curscene:onEventGameScene(data)
	else
		self:showTips(result)
		WindowMgr.closeAllWindow()
	end
	self.params = result
end

return Likuibuyu_EntryRoomConnect