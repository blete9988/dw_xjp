--[[
*	水浒传初始化
*	端口号：1207
]]
local ShuiHuZhuanInitConnect = class("ShuiHuZhuanInitConnect",BaseConnect)
ShuiHuZhuanInitConnect.port = Port.PORT_SHUIHUZHUAN
ShuiHuZhuanInitConnect.type = 1

function ShuiHuZhuanInitConnect:ctor(callback)
	self.callback = callback
end

function ShuiHuZhuanInitConnect:writeData(data)
end

function ShuiHuZhuanInitConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local betinitMoney = data:readInt()	--下注金额
		require("src.games.shuihuzhuan.data.ShuiHuZhuanController").getInstance():serBetMoney(betinitMoney)
		self.params = true
	end
end

return ShuiHuZhuanInitConnect