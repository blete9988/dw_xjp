--[[
*	修改名字
*	端口号：1100
]]
local ModifyNameConnect = class("ModifyNameConnect",BaseConnect)
ModifyNameConnect.port = Port.PORT_NORMAL
ModifyNameConnect.type = 9

function ModifyNameConnect:ctor(newname,callback)
	self.newname = newname
	self.callback = callback
end
function ModifyNameConnect:writeData(data)
	data:writeString(self.newname)
end
function ModifyNameConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		display.showMsg(display.trans("##20011"))
	else
		Player.setName(self.newname)
		Player.status:setStatus(ST.STATUS_PLAYER_NAME_CHANGED,1)
	end
	self.params = result
end

return ModifyNameConnect