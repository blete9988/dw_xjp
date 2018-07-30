--[[
 *	服务器时间获取
 *	端口号：5000
 *	@author：lqh
 *			cb：回调函数
]]
local ServerTimeConnect = class("ServerTimeConnect",BaseConnect)
ServerTimeConnect.port = Port.PORT_SERVER
ServerTimeConnect.type = 10
ServerTimeConnect.notShowLoading = true
function ServerTimeConnect:ctor()

end
function ServerTimeConnect:writeData(data)
	self.sendtm = os.millis()
end
function ServerTimeConnect:readData(data)
	local server_utc = data:readInt()
	--时区
	local zoon = data:readByte()
	--当天时分
	local hour = data:readByte()
	--精确计算服务器的日期
	ServerTimer.setServerTimeZoon(server_utc,hour,zoon*3600)
	--网络请求数据延迟
	local dtm = os.millis() - self.sendtm
	--计算时间误差
	dtm = math.floor(dtm/1000)
	server_utc = server_utc + dtm
	
	ServerTimer.setServerTime(server_utc)
end

return ServerTimeConnect