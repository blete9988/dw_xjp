--[[
*	进入游戏房间
*	端口号：1203
]]
local HaoChePiaoYiGetRoomConnect = class("HaoChePiaoYiGetRoomConnect",BaseConnect)
HaoChePiaoYiGetRoomConnect.port = Port.PORT_HAOCHEPIAOYI
HaoChePiaoYiGetRoomConnect.type = 1

function HaoChePiaoYiGetRoomConnect:ctor(callback)
	self.callback = callback
end
function HaoChePiaoYiGetRoomConnect:writeData(data)
	
end
function HaoChePiaoYiGetRoomConnect:readData(data)
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
			print("old id-------------",oldResults[i])
		end
		local zhuang_id = data:readInt()
		local zhuang_name = data:readString()
		local zhuang_money = data:readLong()
		local apply_number = data:readUnsignedByte()
		local is_banker = data:readBoolean()
		local data = require("src.games.haochepiaoyi.data.HaoChePiaoYiDataController").getInstance()
		data:init(stateTime,state,oldResults,zhuang_id,zhuang_name,zhuang_money,apply_number,is_banker)
		self.params = true
	end
	
end

return HaoChePiaoYiGetRoomConnect