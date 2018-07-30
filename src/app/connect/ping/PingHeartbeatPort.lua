--[[
*	游客id请求
*	port = 8080
*	@author：lqh
]]

local instace					--单列
local PING_INTERVAL = 22000 	--ping间隔，20000毫秒
local PING_TIMEOUT 	= 15000		--ping超时时间 15000毫秒
local PING_TERMINATION_TIME = 5000	--ping最大停止时间5000毫秒后将会断线

local instanceList = {}		--实力列表


local PingHeartbeatPort = class("PingHeartbeatPort",BaseConnect)
PingHeartbeatPort.port = Port.PORT_PING
PingHeartbeatPort.notShowLoading = true
PingHeartbeatPort.printlog		 = false
function PingHeartbeatPort:ctor(socketid)
	self.socket = socketid
	self.pingcd = 0
	self.timeout = 0
	self.iswaiting = false
	self.timehandler = nil
end

function PingHeartbeatPort:writeData(data)
	--空消息不用写入数据
end
function PingHeartbeatPort:readData(data)
	self.iswaiting = false
	self.realTimeStamp = os.millis()
	self.pingcd = PING_INTERVAL
end
function PingHeartbeatPort:loop()
	if self.timehandler then mlog("PingHeartbeatPort had launch,dont launch again!!!") return end
	self.iswaiting = false
	self.pingcd = PING_INTERVAL
	self.realTimeStamp = os.millis()
	--当前世界时间，和上一次的时间差
	local curetime,dtime
	self.timehandler = timeup(function() 
		curetime =  os.millis()
		dtime = curetime - self.realTimeStamp
		self.realTimeStamp = curetime
		if dtime >= PING_TERMINATION_TIME then
			--主线程停止太久，启动重连，超过5秒
			mlog(DEBUG_W,"<PingHeartbeatPort>：程序后台暂停过久，被再次进入，启动重连。")
			--停止心跳
			self:stop()
			ConnectMgr.noticehandler(ST.TYPE_SOCKET_PING_TERMAIL,self.socket)
			return
		end
		
		if not self.iswaiting then
			self.pingcd = self.pingcd - dtime
			if self.pingcd <= 0 then
				--心跳通知后台
				self.iswaiting = true
				self.timeoutcd = PING_TIMEOUT
				self:connect()
			end
		else
			self.timeoutcd = self.timeoutcd - dtime
			if self.timeoutcd <= 0 then
				--ping超时未返回
				mlog(DEBUG_W,"<PingHeartbeatPort>：ping链接超时未返回，马上将就行断线重连！")
				--停止心跳
				self:stop()
				--启动重连通知
				ConnectMgr.noticehandler(ST.TYPE_SOCKET_OUTTIME,self.socket)
			end
		end
	end,2)
	return self
end
function PingHeartbeatPort:stop()
	if not self.timehandler then return end
	timestop(self.timehandler)
	self.timehandler = nil
end

--@static 启动心跳包
function PingHeartbeatPort.launchPing(socketid)
	if instanceList[socketid] then
		instanceList[socketid]:loop()
	else
		instanceList[socketid] = PingHeartbeatPort.new(socketid):loop()
	end
end
--@static 关闭心跳包
function PingHeartbeatPort.stopPing(socketid)
	if not socketid or not instanceList[socketid] then return end
	instanceList[socketid]:stop()
end
function PingHeartbeatPort.stopAllPing()
	for k,v in pairs(instanceList) do
		v:stop()
		instanceList[k] = nil
	end
end
return PingHeartbeatPort