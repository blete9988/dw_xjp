--[[
*	进入 游戏房间
*	端口号：1100
]]
local EntryRoomConnect = class("EntryRoomConnect",BaseConnect)
EntryRoomConnect.port = Port.PORT_NORMAL
EntryRoomConnect.type = 4

function EntryRoomConnect:ctor(room,callback)
	self.room = room
	self.callback = callback
end
function EntryRoomConnect:writeData(data)
	data:writeShort(self.room.id)
end
function EntryRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		if(result == 175)then
			display.showMsg(display.trans("##2074"))
		else
			self:showTips(result)
		end
	end
	mlog(string.format("进入游戏房间，游戏名：%s,房间号：%s",self.room.game.name,self.room.id))
	self.params = result
end

return EntryRoomConnect