--[[
*	水浒传
*	端口号：1207
]]
local ShuiHuZhuanDiceOutConnect = class("ShuiHuZhuanDiceOutConnect",BaseConnect)
ShuiHuZhuanDiceOutConnect.port = Port.PORT_SHUIHUZHUAN
ShuiHuZhuanDiceOutConnect.type = 4

function ShuiHuZhuanDiceOutConnect:ctor(callback)
	self.callback = callback
end

function ShuiHuZhuanDiceOutConnect:writeData(data)
end

function ShuiHuZhuanDiceOutConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		self.params = true
	end
end

return ShuiHuZhuanDiceOutConnect