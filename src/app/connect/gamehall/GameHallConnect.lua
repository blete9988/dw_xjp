--[[
*	获取 游戏大厅 数据
*	端口号：1100
]]
local GameHallConnect = class("GameHallConnect",BaseConnect)
GameHallConnect.port = Port.PORT_NORMAL
GameHallConnect.type = 2

function GameHallConnect:ctor(grouptype,callback)
	self.grouptype = grouptype
	self.callback = callback
end
function GameHallConnect:writeData(data)
	data:writeByte(self.grouptype)
end
function GameHallConnect:readData(data)
	local result = data:readUnsignedByte()
	if result == 0 then
		Player.gameMgr:bytesRead(data,self.grouptype)
	else
		self:showTips(result)
	end
	self.params = result
end

return GameHallConnect