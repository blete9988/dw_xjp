--[[
*	下庄
*	端口号：1203
]]
local HaoChePiaoYiOutGoBankerConnect = class("HaoChePiaoYiOutGoBankerConnect",BaseConnect)
HaoChePiaoYiOutGoBankerConnect.port = Port.PORT_HAOCHEPIAOYI
HaoChePiaoYiOutGoBankerConnect.type = 6

function HaoChePiaoYiOutGoBankerConnect:ctor(callback)
	self.callback = callback
end
function HaoChePiaoYiOutGoBankerConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		self.params = true
	end
	
end

return HaoChePiaoYiOutGoBankerConnect