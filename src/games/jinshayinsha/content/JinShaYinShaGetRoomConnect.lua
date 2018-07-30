--[[
*	进入游戏房间
*	端口号：1201
]]
local JinShaYinShaGetRoomConnect = class("JinShaYinShaGetRoomConnect",BaseConnect)
JinShaYinShaGetRoomConnect.port = Port.PORT_JINSHAYINSHA
JinShaYinShaGetRoomConnect.type = 1

function JinShaYinShaGetRoomConnect:ctor(callback)
	self.callback = callback
end
function JinShaYinShaGetRoomConnect:writeData(data)
	
end
function JinShaYinShaGetRoomConnect:readData(data)
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
		local multipleType = data:readUnsignedByte()
		local data = require("src.games.jinshayinsha.data.JinShaYinShaDataController").getInstance()
		data:init(stateTime,state,oldResults,multipleType)
		self.params = true
	end
end

return JinShaYinShaGetRoomConnect