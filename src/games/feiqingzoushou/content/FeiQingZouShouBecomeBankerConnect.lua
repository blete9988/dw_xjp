--[[
*	上庄
*	端口号：1201
]]
local FeiQingZouShouBecomeBankerConnect = class("FeiQingZouShouBecomeBankerConnect",BaseConnect)
FeiQingZouShouBecomeBankerConnect.port = Port.PORT_FEIQINGZOUSHOU
FeiQingZouShouBecomeBankerConnect.type = 5

function FeiQingZouShouBecomeBankerConnect:ctor(callback)
	self.callback = callback
end

function FeiQingZouShouBecomeBankerConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		self.params = true
	end
	
end

return FeiQingZouShouBecomeBankerConnect