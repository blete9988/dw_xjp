--[[
*	抢庄牛牛 摊牌请求
*	端口号：1210
]]
local Sangong_ShowdownConnect = class("Sangong_ShowdownConnect",BaseConnect)
Sangong_ShowdownConnect.port = Port.PORT_SANGONG
Sangong_ShowdownConnect.type = 4

function Sangong_ShowdownConnect:ctor(callback)
	self.callback = callback
end
function Sangong_ShowdownConnect:writeData(data)
	
end

function Sangong_ShowdownConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
	
	end
	self.params = result
end

return Sangong_ShowdownConnect