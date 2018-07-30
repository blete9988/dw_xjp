--[[
 *	登陆
 *	端口号：1001
 *	@author：lqh
 *	@args：
 *		cb：回调函数
]]
local LoginConnect = class("LoginConnect",BaseConnect)
LoginConnect.port = Port.PORT_SERVER
LoginConnect.type = 2
LoginConnect.notShowLoading = true
function LoginConnect:ctor(username,password,cb)
	self.username = username
	self.password = password
	self.callback = cb
end
function LoginConnect:writeData(data)
	data:writeString(self.username)
	data:writeString(self.password)
end
function LoginConnect:readData(data)
	local bool = data:readBoolean()
	if bool then
		Player.bytesRead(data)
	else
		mlog("<LoginConnect>:服务器发送type 为 false ,Player 未能序列化")
	end
	self.params = bool
end
return LoginConnect