--[[
*	计时器
*	@author：lqh
]]
local sharedScheduler = cc.Director:getInstance():getScheduler()
--用于记录所有调用timeout和timeup的 的handler
local timer_handler_list = {}

local timeout,timeup,timestop,timeclean
--[[
*	延迟执行函数  全局方法
*	@param：callback 回调方法
*	@param：delay 	延迟时间（秒）
*	@param: target
*	@param：... 		回调函数参数列表
]]
function timeout(callback,delay,target,...)
	local handleID
	local params = {...}
	delay = delay or 0
	handleID = sharedScheduler:scheduleScriptFunc(function(tm)
		timestop(handleID)
		if target then
			callback(target,tm,unpack(params))
		else
			callback(tm,unpack(params))
		end
	end, delay, false)
	timer_handler_list[handleID] = true
	return handleID
end
--[[
*	无限循环执行	全局方法
*	@param： callback 回调函数
*	@param： interval 每次执行间隔（默认值为0，即每帧都执行）
]]
function timeup(callback,interval,target)
	local handleID = sharedScheduler:scheduleScriptFunc(function(tm)
		if target then
			callback(target,tm)
		else
			callback(tm)
		end
	end,interval or 0, false)
	timer_handler_list[handleID] = true
	return handleID
end
--[[
*	停止指定时间函数	全局方法
*	@param：handleID 时间函数id
]]
function timestop(handleID)
	timer_handler_list[handleID] = nil
	sharedScheduler:unscheduleScriptEntry(handleID)
end
function timeclean()
	for k,v in pairs(timer_handler_list) do
		sharedScheduler:unscheduleScriptEntry(k)
	end
end
Gbv.timeout		= timeout
Gbv.timeup		= timeup
Gbv.timestop	= timestop
Gbv.timeclean	= timeclean