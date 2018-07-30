--[[
*	系统邮件管理
*	@author lqh
]]
local EmailMgr = class("EmailMgr")
EmailMgr.crc = 0		--email验证码,验证是否有最新邮件
EmailMgr.list = nil		--邮件


function EmailMgr:clear()
	self.crc = 0
	self.list = nil
end

function EmailMgr:getEmailByIndex(index)
	if not self.list then return "" end
	return self.list[index] or ""
end

function EmailMgr:updateEmail()
	ConnectMgr.connect("email.AllEmailConnect")
end

function EmailMgr:bytesRead(data)
	self.crc = data:readInt()
	self.list = {}
	local len = data:readByte()
	for i = 1,len do
		self.list[i] = data:readString()
	end
end

return EmailMgr