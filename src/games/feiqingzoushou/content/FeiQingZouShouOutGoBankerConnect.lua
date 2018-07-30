--[[
*	下庄
*	端口号：1201
]]
local FeiQingZouShouOutGoBankerConnect = class("FeiQingZouShouOutGoBankerConnect",BaseConnect)
FeiQingZouShouOutGoBankerConnect.port = Port.PORT_FEIQINGZOUSHOU
FeiQingZouShouOutGoBankerConnect.type = 6

function FeiQingZouShouOutGoBankerConnect:ctor(callback)
	self.callback = callback
end
function FeiQingZouShouOutGoBankerConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		self.params = true
	end
	
end

return FeiQingZouShouOutGoBankerConnect