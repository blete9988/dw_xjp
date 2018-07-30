require "src.app.connect.Port"
--[[
*	Lua通讯后台管理类（单列模式）
*	推送端口可以通过registorTranmitPort()方法注册推送
*	通过ConnectMgr.connect()方法直接访问后台
* 
*	@author lqh
]]
local ConnectMgr = {}
-- -------------------------@private value-----------------------------------
local mainSocket		= 0			--主socket ID
local mainSocketOnline	= false		--主socket 是否已经链接
local customSockets		= {}		--自定义链接列表
local jabckPorts		= {}		--注册的推送列表
-- -------------------------@private function--------------------------------
local handleString,handleBuffer,handleByte,isOtherSocket,closeSocket,closeAllSocket,unRegistorAllJBackPort
-- --------------------------------------------------------------------------
local portserver = PortServerInstance:getInstance()

--设置主链接socket
function ConnectMgr.setMainSocket(id)
	mainSocket = id
end
function ConnectMgr.getMainSocket()
	return mainSocket
end
function ConnectMgr.mainSocketISOnline()
	return mainSocketOnline
end
function ConnectMgr.setMainSocketISOnline(bool)
	mainSocketOnline = bool
end
--检测主链接是否正常
function ConnectMgr.chekMainSocket()
	if mainSocket == 0 then
		require("src.app.connect.LoginManager").relaunch()
		return false
	end
	return true
end
--保存socket
function ConnectMgr.saveSocketID(key,id)
	if id <= 0 then return end
	customSockets[key] = id
end
--获取socket
function ConnectMgr.getSocket(key)
	return customSockets[key] or 0
end
--自定义注册推送端口
function ConnectMgr.registorJBackPort(socketid,port,callback)
	if not jabckPorts[socketid] then jabckPorts[socketid] = {} end
	jabckPorts[socketid][port] = port
	
	portserver:registerChannel(port,callback)
end
--移除推送端口
function ConnectMgr.unRegistorJBackPort(socketid,port)
	if not jabckPorts[socketid] or not jabckPorts[socketid][port] then return end
	
	jabckPorts[socketid][port] = nil
	portserver:unregisterChanel(port)
end
--注册通用推送端口
function ConnectMgr.registorSystemJBackPort()
	portserver:registerChannel(Port.CUSTOM_RETURN_CHANNEL,require("src.app.connect.jback.JbackPort").extend())
end
--[[
*	socket 请求
*	@param:calss 类名
*	@param:... 参数列表(动态参数)
]]
function ConnectMgr.connect(classname , ...)
	local head = classname:sub(1,4)
	if head == "src." or head == "src/" then
		require(classname).new(...):connect()
	else
		require("src.app.connect." .. classname).new(...):connect()
	end
end

--C++通知监听
function ConnectMgr.noticehandler(data,params)
	local typeclass = type(data)
	if typeclass == "string" then
		handleString(data)
	elseif typeclass == "userdata" then
		handleBuffer(data,params)
	elseif typeclass == "number" then
		handleByte(data,params)
	end
end
--打印C++ 字符串通知
function handleString(str)
	mlog(DEBUG_W,string.format("<ConnectMgr>:recieve c++ string notice : %s",str))
end
--处理bytebuffer 信息
function handleBuffer(data,params)
	mlog(DEBUG_W,"<ConnectMgr>:recieve c++ bytebuffer notice")
	--关闭loading条
	display.closeLoading()
	
	local errorMSG = data:readUTF()
	mlog(DEBUG_W,string.format("recieve server error MSG: %s",errorMSG))
	display.showPop({info = errorMSG,title = "Error"})
	
	if display.getRunningScene():getClass() == "LoginScene" then
   		--当前正在登陆页面(登陆报错)，关闭socket
		closeAllSocket()
	end
end
--处理int信息
function handleByte(value,socketID)
	mlog(DEBUG_W,string.format("<ConnectMgr>:recieve c++ byte notice : %s   ,socket id is : %s",value,socketID))
	--mlog(DEBUG_W,debug.traceback())
	
	if value == ST.TYPE_SOCKET_REV_ENCRYPTION then 
		--连接后台成功并收到密钥
		mlog(DEBUG_W,string.format(">>收到服务器socket链接密钥。开始进入登陆流程 socket id is %s <<",socketID)) 
		require("src.app.connect.LoginManager").connectSuccess(socketID)
		return 
	end
	
	display.closeLoading()
	if value == ST.TYPE_SOCKET_CLOSE_ALL then 
		--主动关闭所有连接
		mlog(DEBUG_W,">>手动调用关闭         所有socket链接<<")
		closeAllSocket()
		return
	elseif value == ST.TYPE_SOCKET_CLOSE then 
		--主动调用关闭socket
		mlog(DEBUG_W,">>手动调用关闭socket<<")
		if socketID == mainSocket then
			if not isOtherSocket() then
				--只有主socket 可以关闭
				closeAllSocket()
			else
				mlog(">> 不允许在其他socket未关闭的情况下，单独关闭主socket链 <<")
			end
		else
			--非主socket直接关闭
			closeSocket(socketID)
		end
		return 
	elseif value == ST.TYPE_PROGAM_ONBACK then
		mlog(DEBUG_W,">>主程序进入后台<<")
		SoundsManager.pauseAllSounds()
		SoundsManager.pauseAllMusic()
		return
	elseif value == ST.TYPE_PROGAM_ONFRONT then
		mlog(DEBUG_W,">>主程序回到前台<<")
		SoundsManager.resumeAllSounds()
		SoundsManager.resumeAllMusic()
		return
	end  
	
	if value == ST.TYPE_SOCKET_CONNECT_ERROR then
		mlog(DEBUG_W,">>socket断开原因：初始化连接服务器失败<<")
	elseif value == ST.TYPE_SOCKET_SEND_ERROR then
		mlog(DEBUG_W,">>socket断开原因：发送消息出错<<")
	elseif value == ST.TYPE_SOCKET_LARGE_DATA then
		mlog(DEBUG_W,">>socket断开原因：收到消息过长，不能完全读取<<")
	elseif value == ST.TYPE_SOCKET_OUTTIME then 
		mlog(DEBUG_W,">>socket断开原因：发送消息连接超时<<")
	elseif value == ST.TYPE_SOCKET_PING_TERMAIL then
		mlog(DEBUG_W,">>socket断开原因：ping心跳暂停超过时间限制<<")
	end
	
	if socketID == mainSocket then
		mlog(DEBUG_W,string.format("主socket断开链接--------------- id : %s",socketID))
		closeSocket(socketID)
		CommandCenter:sendEvent(ST.COMMAND_MAINSOCKET_BREAK)
		--主socket则执行自动重连
		require("src.app.connect.LoginManager").relaunch()
	else
		mlog(DEBUG_W,string.format("自定义socket断开链接----------- id : %s",socketID))
		closeSocket(socketID)
		--非主socket 通知socket断开连接
		CommandCenter:sendEvent(ST.COMMAND_SOCKET_BREAK,socketID)
	end
end

--是否有除主socket以外的其他socket
function isOtherSocket()
	if next(customSockets) then return true end
	return false
end
--关闭socket，并移除对应的推送
function closeSocket(socketid)
	--C++关闭该socket
	portserver:closeSocket(socketid)
	--停止对应的心跳
	require("src.app.connect.ping.PingHeartbeatPort").stopPing(socketid)
	
	if jabckPorts[socketid] then
		for port, var in pairs(jabckPorts[socketid]) do
			ConnectMgr.unRegistorJBackPort(socketid,port)
		end
		jabckPorts[socketid] = nil
	end
	
	if socketid == mainSocket then
		mainSocket = 0
		mainSocketOnline = false
	else
		customSockets[socketid] = nil
	end
end
--关闭所有通讯，并移除注册的推送端口
function closeAllSocket()
	require("src.app.connect.ping.PingHeartbeatPort").stopAllPing()
	require("src.app.connect.LoginManager").reset()
	mainSocket = 0
	mainSocketOnline = false
	unRegistorAllJBackPort()
	portserver:closeAllSocket()
end
--移除所有推送端口，谨慎调用
function unRegistorAllJBackPort()
	jabckPorts = {}
	portserver:removeAllChannel()
end

--注册C++异常通知回调	
NoticeLuaToolkit:getInstance():setNoticeHandler(ConnectMgr.noticehandler) 

Gbv.ConnectMgr = ConnectMgr
setmetatable(Gbv.ConnectMgr,{
	__index = function(t,k) 
		if not ConnectMgr[k] then mlog(DEBUG_E,string.format("<ConnectMgr>:attempt to read undeclared variable, key = <%s>",k)) end
		return ConnectMgr[k]
	end,
	__newindex = function(t,k,v)
		if ConnectMgr[k] then
			mlog(DEBUG_E,string.format("<ConnectMgr>:can not change ST property(%s) value!",k))
			return
		end
		mlog(DEBUG_E,string.format("<ConnectMgr> attempt to write new variable ,key = <%s>",k))
  	end,
  	__metatable = "You cannot get the protect metatable"
})

return ConnectMgr