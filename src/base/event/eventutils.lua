--[[
*	事件通知中心(命令观察者模式)，该类统一调度事件发送。执行超过一定时长将自动进入异步发送模式
*	
*	事件的发送顺序由优先级决定，同一优先级事件的派发顺序是无序的
* 	可以异步派发事件
]]
local CommandCenter = {}

local MAX_DURATION = 800			--事件允许执行最大时长

CommandCenter.MAX_PRO = 0			--最大优先级
CommandCenter.MIN_PRO = 10			--最低优先级

require("src.base.tools.timer")

local sortfunc,comparefunc

--[[
*	派发事件
*	@param cmd 		命令
*	@param arg 		参数数组
*	@param isasyc 	是否为异步
*	@param delay	延迟时间，默认0（即下一帧发送）
]]
function CommandCenter:sendEvent(cmd,arg,isasyc,delay--[[=0]],isinnerUser)
	local registers = self.m_cmdRegisters[cmd]
	if not registers then return end
	
	if self.m_ondoasyc and not isinnerUser then
		--异步管道正在使用
		table.insert(self.m_waitPipe,{cmd,arg,isasyc,delay})
		return
	end
	
	--当 asyctype为true 或者 通知中心处于睡眠的时候将进行异步发送
	if self.m_excuteDuration > MAX_DURATION or (isasyc or self.m_sleepStamp > 0) then
		--异步发送，return
		self:m_addAsycCMD(cmd,arg,delay or 0)
		return
	end
	
	local begantm = os.millis()
	local list = {}
	
	--取出监听队列
	for k,v in pairs(registers) do
		table.insert(list,v)
	end
	--监听队列为空 return
	if #list == 0 then return end
	--对监听队列 进行优先级排序
	table.sort(list,sortfunc)
	
	--同步发送
	for i = 1,#list do
		self:m_dispachCMD(list[i].listener,cmd,arg)
	end
	
	local duration = os.millis() - begantm
	self.m_excuteDuration = self.m_excuteDuration + duration
	
	if duration >= 400 then
		mlog(DEBUG_W,string.format("<CommandCenter>: event : %s is too heavy,use %s millisecond",cmd,duration))
	end
	if self.m_excuteDuration >= MAX_DURATION then
		self.m_delay = 0.11
		--执行总时间超过200毫秒，即进入下一次执行
		mlog(DEBUG_W,string.format("<CommandCenter>:in one frame CommandCenter used %s millisecond",self.m_excuteDuration))
	end
end
--[[
*	撤销异步命令
*	@cmd 命令
]]
function CommandCenter:undoCMD(cmd)
	if not cmd or not self.m_asyPipe[cmd] then return end
	local pipe = self.m_asyPipe[cmd]
	self.m_asyPipe[cmd] = {}
	for i = 1,#pipe do
		pipe[i].isremove = true
	end
end
--命令中心睡眠	所有命令派发将会存进异步管道。
function CommandCenter:sleep()
	self.m_sleepStamp = os.millis()
end
-- 唤醒命令中心	唤醒时将派发所有异步管道事件
function CommandCenter:awake()
	if self.m_sleepStamp == 0 then return end 
	local interval = os.millis() - self.m_sleepStamp
	self.m_sleepStamp = 0
	mlog(string.format("<CommandCenter>: CommandCenter sleep %s millisecond.",interval))
	self:m_timeCallback(interval/1000)
end
--清除异步管道
function CommandCenter:clearAsyPipe()
	self.m_asyPipe = {}
	self.m_waitPipe = {}
end
function CommandCenter:clear()
	--睡眠时间标签
	self.m_sleepStamp 		= 0
	--事件执行用时
	self.m_excuteDuration	= 0
	--消息过中，将延迟0.1s，才启用中心，缓解画面卡顿
	self.m_delay			= 0
	--注册列表
	self.m_cmdRegisters 	= {}
	--异步派发列表
	self.m_asyPipe 			= {}
	--是否正在执行异步发送
	self.m_ondoasyc 		= false
	--缓冲管道
	self.m_waitPipe			= {}
	--移除时间函数
	if self.m_timehandler then
		timestop(self.m_timehandler)
		self.m_timehandler = nil
	end
end
--重置命令中心，谨慎使用，会清楚当前所有已监听命令
function CommandCenter:reset()
	self:clear()
	timeup(self.m_timeCallback,1/30,self)
end
--@private 派发命令
function CommandCenter:m_dispachCMD(target,cmd,arg)
	--激活状态为真且，该事件真实在监听对象的记录中则进行事件派发
	if target.activity_ and target.events_ and target.events_[cmd] then
		if Cfg.DEBUG_TAG then
			--调试模式
			target:handlerEvent(cmd,arg)
		else
			--非调试模式进行异常捕获
			pcall(function() 
				target:handlerEvent(cmd,arg)
			end)
		end
	end
end
--@private 添加命令
function CommandCenter:m_registerCMD(cmd,listener,proprity)
	local registers = self.m_cmdRegisters[cmd]  
	if not registers then 
		registers = {} 
		self.m_cmdRegisters[cmd] = registers
	end
	registers[listener.listenerid_] = {listener = listener,proprity = proprity}
end
--@private 移除命令监听
function CommandCenter:m_removeCMD(cmd,commander)
	local registers = self.m_cmdRegisters[cmd]
	if not registers then return end
	
	registers[commander.listenerid_] = nil
end
--@private 异步发送添加
function CommandCenter:m_addAsycCMD(cmd,arg,delay)
	local cache = self.m_asyPipe[cmd]
	if not cache then 
		cache = {}
		self.m_asyPipe[cmd] = cache 
	end
	
	local entity = {params = arg,delay = delay}
	for i = 1,#cache do
		--相同的异步消息将被过滤
		if comparefunc(cache[i],entity) then return end
	end
	table.insert(cache,entity)
end
--@private 时间监听回掉方法
function CommandCenter:m_timeCallback(interval)
	if self.m_sleepStamp > 0 then return end
	if self.m_excuteDuration > 0 then
		self.m_delay = self.m_delay - interval
		if self.m_delay >= 0 then
			return
		else
			interval = -self.m_delay
			self.m_excuteDuration = 0
			self.m_delay = 0
		end
	end
	
	self.m_ondoasyc = true
	
	local temp,list
	for cmd,entities in pairs(self.m_asyPipe) do
		if self.m_excuteDuration > MAX_DURATION then break end
		list = table.merge({}, entities)
		for i = #list,1,-1 do
			temp = list[i]
			temp.delay = temp.delay - interval
			if (temp.delay <= 0 and not temp.isremove) then
				table.remove(entities,i)
				self:sendEvent(cmd,temp.params,nil,0,true)
			end
			if self.m_excuteDuration > MAX_DURATION then break end
		end
		if #entities == 0 then self.m_asyPipe[cmd] = nil end
	end

	self.m_ondoasyc = false
	
	--执行缓冲管道
	for i = 1,#self.m_waitPipe do
		self:sendEvent(unpack(self.m_waitPipe[i]))
		self.m_waitPipe[i] = nil
	end
end
--初始化命令中心
CommandCenter:reset()

--[[
*	listener接口，所有对象继承该接口后，通过CommandCenter 添加监听，可以接收到事件
*	默认优先级为 5
*	
*	@param: events_			监听事件id列表
*	@param: activity_		是否处于激活状态
*	@param: listenerid_		listener id号
]]
local IEventListener = {activity_ = true,priority_ = 5}
local Listener_id = 0

--继承方法，所有对象均可通过该方法继承
function IEventListener.extend(target)
	
	--target.activity_ = true
	--target.priority_ = 5
	
	for k,v in pairs(IEventListener) do
		target[k] = v
	end
	
	return target
end
--初始化 id
function IEventListener:initListenerid__()
	self.events_ = {}
	Listener_id = Listener_id + 1
	self.listenerid_ = Listener_id
end
--[[
 *	注册监听事件，相同事件可以重复调用注册，只有最后一次注册才会生效
 *	@param：event 事件id
 *	@param：proprity 优先级（为设置将会调用listener自身优先级)取值范围（0 - 10），值越小，优先级越大
]]
function IEventListener:addEvent(event,proprity)
	if not self.listenerid_ then self:initListenerid__() end
	self.events_[event] = event
	CommandCenter:m_registerCMD(event,self,proprity or self.priority_)
end
--[[
 *	移除监听
 *	@param：event 事件id
]]
function IEventListener:removeEvent(event)
	if not self.listenerid_ then return end
	if not self.events_[event] then return end
	CommandCenter:m_removeCMD(event,self)
	self.events_[event] = nil
end
--[[
 *	事件接收方法， 需要被重写（override）
 *	@param：event 事件id
 *	@param：arg 事件参数
]]
function IEventListener:handlerEvent(event,arg)
	--overried
end
--设置优先级
function IEventListener:setPriority(value)
	self.priority_ = value
end
--[[
 *	设置监听器 是否为激活状态
 *	@param：value 参数（不带任何参数，默认为true）
]]
function IEventListener:setActivity(value)
	if value == nil then value = true end
	self.activity_ = value
end
--[[
 *	移除所有注册监听事件
]]
function IEventListener:removeAllEvent()
	--设置激活状态为空，因为在异步派发的时候可能监听已进入对象列表
	self.activity_ = nil
	if not self.listenerid_ then return end
	for k,v in pairs(self.events_) do
		CommandCenter:m_removeCMD(v,self)
	end
end

--排序迭代
function sortfunc(a,b)
	if a.proprity < b.proprity then
		return true
	end
end
function comparefunc(vlue_a,value_b)
	if not vlue_a or not value_b then 
		if not vlue_a and not value_b then return true end
		return false
	end
	
	local desc = type(vlue_a)
	if desc == type(value_b) then
		if desc == "table" then
			if vlue_a == value_b then return true end
			--为表时
			for k,v in pairs(vlue_a) do
				if not value_b[k] or not comparefunc(value_b[k],v) then
					return false
				end 
			end
			for k,v in pairs(value_b) do
				if not vlue_a[k] then 
					return false 
				end
			end
			return true
		elseif vlue_a == value_b then
			return true
		else
			return false
		end
	else
		return false
	end
end

Gbv.CommandCenter 	= CommandCenter
Gbv.IEventListener	= IEventListener

return CommandCenter