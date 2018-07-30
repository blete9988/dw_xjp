--[[
*	socket 连接基类，所有socket请求需继承该类实现连接服务器
*	
*	## 基本属性
*	@param:port 连接端口号
*	@param:type 连接type值
*	@param:params 回调参数容器
*	@param:callback 回调函数
*	@param:notShowLoading 是否关闭loading条遮挡(默认不关闭)
*	@param:isnotice 是否紧是通知请求(默认false，通知请求无返回)
*	@param:tips 错误消息前缀值(默认50000)
*
*	@author:lqh
]]
local BaseConnect = class("BaseConnect")
--链接socket  ID
BaseConnect.socket = nil
--端口号
BaseConnect.port = nil
--type 值
BaseConnect.type = nil
--回调函数参数
BaseConnect.params = nil
--回调函数引用
BaseConnect.callback = nil
--是否show loading条（default false）
BaseConnect.notShowLoading = nil	
--错误提示base数值
BaseConnect.tips = 50000			
--是否是通知请求(无返回请求)
BaseConnect.isnotice = nil		
--是否打印日志
BaseConnect.printlog = true

--构造函数，需要子类继承复写（构造函数参数列表，应该在子类中添加注释）
function BaseConnect:ctor(...)
	
end
--数据写入
function BaseConnect:writeData(data)
	
end
--读取后台数据
function BaseConnect:readData(data)
	
end
--显示服务器错误提示
function BaseConnect:showTips(result)
	display.showMsg(display.trans(self.tips + result))
end
--调用注册的回调函数
function BaseConnect:callFun()
	if self.callback then self.callback(self.params) end
end

function BaseConnect:m_printLog(...)
	if not self.printlog then return end
	mlog(...)
end

local portserver = PortServerInstance:getInstance()
local cmgr = ConnectMgr
--连接后台（不需要被重写）
function BaseConnect:connect()
	
	--默认使用主socket 通讯
	self.socket = self.socket or cmgr.getMainSocket()
	if self.socket <= 0 then
		mlog( DEBUG_W, string.format("<%s>: no socket can use !!!!!!!!!!!!!",self:getClass()))
		return
	end
	
	if not self.notShowLoading and not self.isnotice then
		display.showLoading(nil,1,self.socket)
	end
	
	local data = ByteBuffer:create()
	
	--type写入
	if self.type then 
		data:writeByte(self.type) 
	end	
	--业务逻辑写入
	self:writeData(data)
	
	if not self.isnotice then
		--新建后台连接回调函数
		self.__connetcb = function(data)
			local dt = os.millis() - self._connectbegan
			if dt > 300 then
				mlog(string.format("<%s>:请求延迟为 %s millisecond",self:getClass(),dt))
			end
			
			self:m_printLog(string.format("<%s>:had receive server callback,port:%d,type%s",self.__cname,self.port,(self.type or "null")))
			
			if not self.notShowLoading and not self.isnotice then
				display.closeLoading()
			end
			--业务逻辑解析
			self:readData(data)
			--调用回掉函数
			self:callFun()
			self.callback,self.__connetcb,self.params = nil
		end
		
		portserver:send(self.socket,4,self.port,data,self.__connetcb)
		
		self._connectbegan = os.millis()
		
		self:m_printLog(string.format("<%s>:request server,port:%d,type: %s",self.__cname,self.port,(self.type or "null")))
	else
		self.callback = nil
		portserver:send(self.socket,4,self.port,data,nil)
		
		self:m_printLog(string.format("<%s>:no callback request server,port:%d,type: %s",self.__cname,self.port,(self.type or "null")))
	end
	data:release()
end

Gbv.BaseConnect = BaseConnect

return BaseConnect