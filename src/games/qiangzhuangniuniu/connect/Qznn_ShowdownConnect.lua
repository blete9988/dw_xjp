--[[
*	抢庄牛牛 摊牌请求
*	端口号：1210
]]
local Qznn_ShowdownConnect = class("Qznn_ShowdownConnect",BaseConnect)
Qznn_ShowdownConnect.port = Port.PORT_QZNN
Qznn_ShowdownConnect.type = 4

function Qznn_ShowdownConnect:ctor(callback)
	self.callback = callback
end
function Qznn_ShowdownConnect:writeData(data)
	
end

function Qznn_ShowdownConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
	
	end
	self.params = result
end

return Qznn_ShowdownConnect