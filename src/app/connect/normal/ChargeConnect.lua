--[[
*	充值 请求
*	端口号：1100
]]
local ChargeConnect = class("ChargeConnect",BaseConnect)
ChargeConnect.port = Port.PORT_CHARGE
ChargeConnect.type = 0

function ChargeConnect:ctor(productId,callback)
	self.productId = productId
	self.callback = callback
end
function ChargeConnect:writeData(data)
	data.writeString(self.productId)
end
function ChargeConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		display.showMsg(display.trans("##1006"))
	else
        local sign = data.readString()

        result = sign
	end
	self.params = result
end

return DepositConnect