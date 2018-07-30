--[[
*	os扩展
*	添加一个 获取当前世界时间精确到毫秒的方法
]]

function os.millis()
	return TimeUtils:getCurrentMillis()
end