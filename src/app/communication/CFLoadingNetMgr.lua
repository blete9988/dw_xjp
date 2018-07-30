local T = class("CFLoadingNetMgr",IEventListener)

--- 返回类型
T.RET_TYPE={
	SUCC = "succ",
	ERR_GET_SECRETS_KEY_FAIL = "err_get_secrets_key_fail" ,
	ERR_CREATE_SOCKET_FAIL = "err_create_socket_fail",
	ERR_CONNECT_FAIL = "err_connect_fail"
}

--- 状态
T.STATE={
	UNINIT = 0,
	GET_SECRET_KEY_ING = 1,
	CONNECTING = 2,
	CONNECTED  = 3,
	ERR = 4,
	BREAKED = 5,
	CONNECT_ERR = 6,
}

--- 连接超时
T.CONNECT_TIMEOUT_SECOND = 5

function T:ctor()
	--	self:super("ctor")

	Gbv.CFLoadingNetMgr = self

	self._state = T.STATE.UNINIT
end

function T:connect(url,callback)
	self._url = url
	self._callback = callback

	self._state = T.STATE.GET_SECRET_KEY_ING
	ConnectMgr.connect("src.app.connect.gamehall.ServerKeyConnect" , function(code)
		if code ~= 0 then
			self._state = T.STATE.ERR

			if callback ~= nil then
				callback(T.RET_TYPE.ERR_GET_SECRETS_KEY_FAIL)
			end

			--错误信息已被处理
			return
		end

		self:connectServer()
	end)
end

function T:connectServer()
	self._state = T.STATE.CONNECTING

	local timeoutID = nil;

	self:addEvent(ST.COMMAND_SOCKET_BREAK)
	local socketID = require("src.app.connect.LoginManager").createSocket(self._url,function(socketID)
		self._state = T.STATE.CONNECTED

		if timeoutID ~= nil then
			timestop(timeoutID)
		end

		if self._callback ~= nil then
			self._callback(T.RET_TYPE.SUCC,socketID)
		end
	end)

	if socketID < 0 then
		self._state = T.STATE.ERR

		if self._callback ~= nil then
			self._callback(T.RET_TYPE.ERR_CONNECT_FAIL)
		end
		return
	end

	--非断线重连，添加默认loading蒙版
	display.showLoading(nil,20,socketID)

	self._socketID = socketID
	ConnectMgr.saveSocketID(self._url,socketID)

	-- 连接超时判断
	timeoutID = timeout(function()
		ConnectMgr.noticehandler(ST.TYPE_SOCKET_CLOSE,socketID)

		if self._callback ~= nil then
			self._callback(T.RET_TYPE.ERR_CREATE_SOCKET_FAIL)
		end
	end,T.CONNECT_TIMEOUT_SECOND)
end

function T:handlerEvent(evt,arg)
	if arg == self._socketID then
		if evt == ST.COMMAND_SOCKET_BREAK then
			self:handleBreak()
		end
	end
end

function T:handleBreak()
	if self._state == T.STATE.CONNECTING then
		-- 没连接上
		self._state = T.STATE.CONNECT_ERR

		self:release()

		if self._callback ~= nil then
			self._callback(T.RET_TYPE.ERR_CONNECT_FAIL)
		end
	elseif self._state == T.STATE.CONNECTED then
		ConnectMgr.noticehandler(ST.TYPE_SOCKET_CLOSE,self._socketID)

		-- 连接断开
		self._state = T.STATE.BREAKED
	end
end

function T:getState()
	return self._state
end

function T:release()
	self:removeEvent(ST.COMMAND_SOCKET_BREAK)

	--关闭loading条
	display.closeLoading()

	Gbv.CFLoadingNetMgr = nil
end

return T
