--[[
*	水浒传开始游戏
*	端口号：1207
]]
local ShuiHuZhuanPlayConnect = class("ShuiHuZhuanPlayConnect",BaseConnect)
ShuiHuZhuanPlayConnect.port = Port.PORT_SHUIHUZHUAN
ShuiHuZhuanPlayConnect.type = 2

function ShuiHuZhuanPlayConnect:ctor(betMoney,callback)
	self.betMoney = betMoney
	self.callback = callback
end

function ShuiHuZhuanPlayConnect:writeData(data)
	data:writeInt(self.betMoney)
end

function ShuiHuZhuanPlayConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local content_data = require("src.games.shuihuzhuan.data.ShuiHuZhuanContentData").new()
		content_data:byteRead(data)
		self.params = content_data
	end
	
end

return ShuiHuZhuanPlayConnect