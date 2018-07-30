--[[
*	登陆管理
*	
*	##登陆流程 
*
*	@author：lqh
]]
local LoginManager = {}
--是否正在使用重连
local isRelogining = false
--是否静默重连
local silenceRelogn = false
local create_callback
local loginserver,user

local loginType, username, password

local function loginCallback(result)
	--关闭loading条
	display.closeLoading()
	if not result then 

		local storage = require("src.base.tools.storage")
		storage.saveXML('acc_loginType', '')
		storage.saveXML('acc_username', '')
		storage.saveXML('acc_password', '')

		display.enterScene("src.ui.scene.login.LoginScene")

		display.showMsg("登陆失败")
		return 
	end
	--注册推送
	ConnectMgr.registorSystemJBackPort()
	--初始化请求一些数据
	ConnectMgr.connect("server.ServerTimeConnect")
	
	--唤醒命令中心
	CommandCenter:awake()
	
	if isRelogining then
		isRelogining = nil
		mlog(DEBUG_W,"<Login> : 断线重连成功！！！！")
	else
		--进入主界面
		display.enterScene("src.ui.scene.MainScene")
	end
end

--[[
*	启动连接
]]
function LoginManager.launch(server,type,account,pwd)
	mlog("loginManager.launch", server, type, account, pwd)

	loginserver 	= server
	-- user 			= userid
	loginType = type
	username = account
	password = pwd
	
	local socketid = PortServerInstance:getInstance():openSocket(server,"mainSocket")
	
	if socketid < 0 then
		mlog(DEBUG_W,"<LoginManager>:主socket创建失败，具体原因不明.")
		if isRelogining then
			LoginManager.relaunch()
		end
		return
	end
	--保存主socket
	ConnectMgr.setMainSocket(socketid)
	
	if not isRelogining then
		--非断线重连，添加默认loading蒙版
		display.showLoading(nil,1,socketid)
	else
		if not silenceRelogn then
			--断线重连添加loading蒙版，文字显示“正在断线重连，请稍等”
			display.showLoading(display.trans("##1000"),0,socketid)
		end
	end
end

--断线重连
function LoginManager.relaunch()
	LoginManager.reset()
	
	if display.getRunningScene():getClass() == "LoginScene" then
		--在登陆界面,提示检查网络
		display.showMsg(display.trans("##1002"))
		return
	elseif isRelogining then
		--已经执行了断线重连
		isRelogining = false
		if not silenceRelogn then
			--提示手动登陆
			display.showPop({
				info = display.trans("##1001"),
				size = 30,
				callback = function()
					display.enterScene("src.ui.scene.login.LoginScene")
				end
			})
		else
			mlog("<LoginManager>:主socket静默重连失败！！！！！！")
		end
		return 
	end
	
	isRelogining = true
	
	timeout(function() 
		LoginManager.launch(loginserver,loginType, username, password)
	end,0.05)
end

function LoginManager.createSocket(url,callback)
	local socketid = PortServerInstance:getInstance():openSocket(url)
	if socketid < 0 then
		mlog(DEBUG_W,"<LoginManager>:逻辑socket创建失败，具体原因不明.")
		return socketid
	end
	create_callback = callback
	return socketid
end

--[[
*	与连接服务器成功，开始正常登陆
]]
function LoginManager.connectSuccess(socketid)
	--启动ping
	require("src.app.connect.ping.PingHeartbeatPort").launchPing(socketid)
		
	if socketid ~= ConnectMgr.getMainSocket() then
		local callback = create_callback
		create_callback = nil
		if callback then
			callback(socketid)
		end
		return
	end
	ConnectMgr.setMainSocketISOnline(true)
	--开始登陆流程
	
	--命令中心睡眠
	CommandCenter:sleep()

	local params = nil

	mlog("loginType=", loginType, username, password)

	if loginType == "user" then
		ConnectMgr.connect("login.LoginConnect", username, password, loginCallback)
	else
		ConnectMgr.connect("login.TrailConnect", username, loginCallback)
	end
end
--设置是否静默重连
function LoginManager.setSilenceRelogn(bool)
	silenceRelogn = bool
end
function LoginManager.resetTypes()
	isRelogining,silenceRelogn = false,false
end
--重置，关闭一些运行中的状态
function LoginManager.reset()
	--停止服务器计时器
	ServerTimer.stop()
	--清理消息中心异步管道
	CommandCenter:clearAsyPipe()
	--唤醒命令中心
	CommandCenter:awake()
end

setmetatable(LoginManager,{
	__index = {},
	__newindex = function(t,k,v)
		error(string.format("<LoginManager> attempt to read undeclared variable <%s>",k))
	end
})

return LoginManager