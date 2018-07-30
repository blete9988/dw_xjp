--[[
*	获取所有邮件
*	端口号：1314
]]
local AllEmailConnect = class("AllEmailConnect",BaseConnect)
AllEmailConnect.port = Port.PORT_EMAIL
AllEmailConnect.type = 1
AllEmailConnect.notShowLoading = true

function AllEmailConnect:ctor()
end
function AllEmailConnect:writeData(data)
	data:writeInt(Player.emailMgr.crc) 
end
function AllEmailConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		local isnew = data:readBoolean()
		if isnew then
			Player.emailMgr:bytesRead(data)
		end
	end
end

return AllEmailConnect