--[[
*	获取游戏 下载地址
*	端口号：1100
]]
local GetGameZipAddressConnect = class("GetGameZipAddressConnect",BaseConnect)
GetGameZipAddressConnect.port = Port.PORT_NORMAL
GetGameZipAddressConnect.type = 6

function GetGameZipAddressConnect:ctor(gamedata,callback)
	self.gamedata = gamedata
	self.callback = callback
end
function GetGameZipAddressConnect:writeData(data)
	data:writeShort(self.gamedata.sid)
end
function GetGameZipAddressConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
		local url = data:readString()
		mlog(string.format("获取 %s 下载地址，下载地址为:%s",self.gamedata.name,url))
		self.gamedata:setDownLoadURL(url)
	end
	self.params = result
end

return GetGameZipAddressConnect