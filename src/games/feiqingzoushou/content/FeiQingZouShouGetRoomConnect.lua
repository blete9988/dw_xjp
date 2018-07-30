--[[
*	进入游戏房间
*	端口号：1201
]]
local FeiQingZouShouGetRoomConnect = class("FeiQingZouShouGetRoomConnect",BaseConnect)
FeiQingZouShouGetRoomConnect.port = Port.PORT_FEIQINGZOUSHOU
FeiQingZouShouGetRoomConnect.type = 1

function FeiQingZouShouGetRoomConnect:ctor(callback)
	self.callback = callback
end
function FeiQingZouShouGetRoomConnect:writeData(data)
	
end
function FeiQingZouShouGetRoomConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local stateTime = data:readInt()	--状态时间
		local state = data:readUnsignedByte()	--状态0:等待下注 1:下注中
		local length = data:readUnsignedByte()	--之前的结果
		local oldResults = {}
		for i=1,length do
			table.insert(oldResults,data:readInt())
		end
		local zhuang_id = data:readInt()
		local zhuang_name = data:readString()
		local zhuang_money = data:readLong()
		local apply_number = data:readUnsignedByte()
		local is_banker = data:readBoolean()
		local data = require("src.games.feiqingzoushou.data.FeiQingZouShouDataController").getInstance()
		data:init(stateTime,state,oldResults,zhuang_id,zhuang_name,zhuang_money,apply_number,is_banker)
		self.params = true
	end
	
end

return FeiQingZouShouGetRoomConnect