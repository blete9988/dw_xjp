--[[
*	服务器计时器，精确计时器，能保持和服务器时间同步，误差不超过1s
*	程序内所有的时间操作 都可以通过监听 COMMAND_SERVER_DATE 实现
*	
*	## 建议 
*		程序内所有的时间操作 通过监听 COMMAND_SERVER_DATE 实现
*	
*	每隔指定时间间隔 针会进行一次时间校正
*	@author：lqh
]]

--常量 资源更新时间频率
local SOURCE_UPDATE_RATE = 63		
--常量 服务器时间校对频率
local SERVERTIME_UPDATE_RATE = 180

--[[
*	st 内部对象
*	st属性外部访问为只读属性
*
*	@param st.localTimeZoon 本地时区（真实时间与UTC的时差，如果正在夏令时 + 3600）
*	@param st.serverTimeZoon 服务器时区（真实时间与UTC的时差，如果正在夏令时 + 3600）
*	@param st.time 服务器时间，前台会根据真实时间不断累积该变量
]]
local st = {
	localTimeZoon = 0,
	serverTimeZoon = 0,
	time = 0,
}

--私有变量定义
--服务器时间 校对时间戳
local fixServerTime		
--是否正在请求时间			
local isRequesting,handler					

--初始化本地时区
local function initLocalTimeZoon()
	local test = os.time({year = 1970,month = 1,day = 2,hour = 0})
	--该值是本地真实时区
	st.localTimeZoon = 86400 - test	
	--判断是否在夏令时
	local tm = os.time()
	if math.floor(((tm + st.localTimeZoon)%86400)/3600) ~= tonumber(os.date("%H",tm)) then
		--夏令时
		st.localTimeZoon = st.localTimeZoon + 3600
	end
end
--启动时间校准
local function loop()
	if handler then return end
	local oldtime,nowtime,delaytime = os.time()
	
	handler = timeup(function(t)
		delaytime = os.time() - oldtime
		if delaytime < 1 then return end
		nowtime = os.time()
		if delaytime >= 10 then
			--非合理误差，更新时间
			st.stop()
			ConnectMgr.connect("server.ServerTimeConnect")
			return
		end
		oldtime = nowtime
		
		st.time = st.time + delaytime
		--派发事件
		CommandCenter:sendEvent(ST.COMMAND_SERVER_TIME,math.floor(st.time))
		
    	if st.time >= fixServerTime and not isRequesting then
    		isRequesting = true
    		--校对服务器时间
    		ConnectMgr.connect("server.ServerTimeConnect")
    	end
    end, 0.1)
end
--停止计时
function st.stop()
	if handler then 
		timestop(handler)
		handler = nil
	end
	st.time,fixServerTime = 0,nil
end

--设置当前服务器时间，并启动计时
function st.setServerTime(t)
	isRequesting = false
	initLocalTimeZoon()
	--isRequesting = false
	mlog(DEBUG_W,string.format("<ServerTimer>:local utctime:%s ,local net utctime:%s ,real net utctime:%s ,d-value:%s",os.time(),st.time,t,t - st.time))
	st.time = t
	fixServerTime = t + SERVERTIME_UPDATE_RATE
	loop()
end
--[[
*	设置服务器时区
*	@param utc:服务器当前utc时间
*	@param hour:服务器当天的小时
*	@param timezoon:服务器当前所在时区
]]
function st.setServerTimeZoon(utc,hour,timezoon)
	mlog(string.format("<ServerTimer>:服务器UTC %s , 当天小时 %s , 时区 %s",utc,hour,timezoon/3600))
	if math.floor(((utc + timezoon)%86400)/3600) ~= hour then
		--夏令时
		st.serverTimeZoon = timezoon + 3600
		mlog(string.format("<ServerTimer>:server zoon is:%s,isdst:%s",st.serverTimeZoon,tostring(true)))
	else
		st.serverTimeZoon = timezoon
		mlog(string.format("<ServerTimer>:server zoon is:%s,isdst:%s",st.serverTimeZoon,tostring(false)))
	end
end
--获取服务器时间是今年的第几天
function st.getYearOfDay()
	return tonum(os.date("%j",st.time + (st.serverTimeZoon - st.localTimeZoon)))
end
--获取服务器当天的真实 秒值
function st.getDay()
	return (st.time + st.serverTimeZoon)%86400
end
--[[
*	获取服务器 年-月-日 时:分:秒
*	@param:st 服务器UTC 时间，不填默认为当前服务器UTC时间
]]
function st.getDate(sttime,format)
	sttime = sttime or st.time
	return os.date(format or "%Y-%m-%d %H:%M:%S",sttime + (st.serverTimeZoon - st.localTimeZoon))
end

Gbv.ServerTimer = {}
setmetatable(ServerTimer,{
	__index = function(t,k) 
		if not st[k] then error(string.format("<ServerTimer>:attempt to read undeclared variable, key = <%s>",k)) end
		return st[k]
	end,
  	__newindex = function(t,k,v)
		if st[k] then
			error(string.format("<ServerTimer>:can not change ServerTimer property(%s) value!",k))
			return
		end
		error(string.format("<ServerTimer>:attempt to write new variable ,key = <%s>",k))
  	end,
  	__metatable = "You cannot get the protect metatable"
})
return ServerTimer