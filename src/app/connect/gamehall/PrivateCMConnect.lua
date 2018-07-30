--[[
*	聊天发送
*	端口号：5000
]]
local PrivateCMConnect = class("PrivateCMConnect",BaseConnect)

function PrivateCMConnect:ctor(params)
	self.notShowLoading = true
	self.port = 1313
	self.type = 1
	self.m_params = params
end
function PrivateCMConnect:writeData(data)
	for i = 1,#self.m_params do
		data:writeLong(self.m_params[i])
	end
end
function PrivateCMConnect:readData(data)
	
end

return PrivateCMConnect