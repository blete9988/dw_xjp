--[[
*	修改头像
*	端口号：1100
]]
local ModifyHeadIconConnect = class("ModifyHeadIconConnect",BaseConnect)
ModifyHeadIconConnect.port = Port.PORT_NORMAL
ModifyHeadIconConnect.type = 8

function ModifyHeadIconConnect:ctor(iconIndex,callback)
	self.iconIndex = iconIndex
	self.callback = callback
end
function ModifyHeadIconConnect:writeData(data)
	data:writeByte(self.iconIndex)
end
function ModifyHeadIconConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		Player.setHead(self.iconIndex)
	end
	self.params = result
end

return ModifyHeadIconConnect