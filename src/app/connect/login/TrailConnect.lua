--[[
 *	登陆
 *	端口号：1001
 *	@author：lqh
 *	@args：
 *		cb：回调函数
]]
local TrailConnect = class("TrailConnect",BaseConnect)
TrailConnect.port = Port.PORT_SERVER
TrailConnect.type = 1
TrailConnect.notShowLoading = true
function TrailConnect:ctor(username,cb)
	self.username = username
	self.callback = cb
end
function TrailConnect:writeData(data)
	data:writeString(self.username)
end
function TrailConnect:readData(data)
	local bool = data:readBoolean()
	if bool then
		Player.bytesRead(data)
	else
		mlog("<TrailConnect>:服务器发送type 为 false ,Player 未能序列化")
	end
	self.params = bool
end
return TrailConnect