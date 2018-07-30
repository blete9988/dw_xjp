--[[
*	设置密码 请求
*	端口号：1100
]]
local PswSettingConnect = class("PswSettingConnect",BaseConnect)
PswSettingConnect.port = Port.PORT_NORMAL
PswSettingConnect.type = 12

function PswSettingConnect:ctor(psw,callback)
	self.psw = psw
	self.callback = callback
end
function PswSettingConnect:writeData(data)
	data:writeString(self.psw)
end
function PswSettingConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		Player.status:setStatus(ST.STATUS_PLAYER_PSW_SETTED,1)
	end
	self.params = result
end

return PswSettingConnect