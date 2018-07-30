--[[
*	上庄
*	端口号：1203
]]
local HaoChePiaoYiBecomeBankerConnect = class("HaoChePiaoYiBecomeBankerConnect",BaseConnect)
HaoChePiaoYiBecomeBankerConnect.port = Port.PORT_HAOCHEPIAOYI
HaoChePiaoYiBecomeBankerConnect.type = 5

function HaoChePiaoYiBecomeBankerConnect:ctor(callback)
	self.callback = callback
end

function HaoChePiaoYiBecomeBankerConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		self.params = true
	end
	
end

return HaoChePiaoYiBecomeBankerConnect