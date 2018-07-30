--[[
*	排行榜请求
*	端口号：1107
]]
local LeaderBoardConnect = class("LeaderBoardConnect",BaseConnect)
LeaderBoardConnect.port = Port.PORT_LEADERBOARD
LeaderBoardConnect.type = 1

function LeaderBoardConnect:ctor(startIndex,callback)
	self.startIndex = startIndex
	self.callback = callback
end
function LeaderBoardConnect:writeData(data)
	data:writeByte(self.startIndex)
end
function LeaderBoardConnect:readData(data)
	local result = data:readUnsignedByte()
	local playerslist = {}
	if result ~= 0 then
		self:showTips(result)
	else
		local len = data:readByte()
		for i = 1,len do
			playerslist[i] = require("src.app.data.PlayerInfo").new():leaderBoardBytesRead(data,self.startIndex + (i - 1))
		end
	end
	self.params = {result = result,playerslist = playerslist}
end

return LeaderBoardConnect