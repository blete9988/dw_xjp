--[[
*	水果拉霸初始化
*	端口号：1209
]]
local ShuiGuoLaBaInitConnect = class("ShuiGuoLaBaInitConnect",BaseConnect)
ShuiGuoLaBaInitConnect.port = Port.PORT_SHUIGUOLABA
ShuiGuoLaBaInitConnect.type = 1

function ShuiGuoLaBaInitConnect:ctor(callback)
	self.callback = callback
end

function ShuiGuoLaBaInitConnect:writeData(data)
end

function ShuiGuoLaBaInitConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local betMaxMoney = data:readLong()	--下注金额
		require("src.games.shuiguolaba.data.ShuiGuoLaBaController").getInstance():setMaxBetMoney(betMaxMoney)
		self.params = true
	end
end

return ShuiGuoLaBaInitConnect