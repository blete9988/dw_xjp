--[[
 *	debug打印 缓存
 *	@author：lqh
]]
local log = {
	__newindex = function() 
		error("<logcache> attempt to read undeclared variable")
	end
}
--缓存
local debugcache = {}
local mlistener
--日志打印头
local loghead = "<span color='ffffff'>[%s] [log]</span>:%s"

--创建一个日志结构体
local function createLogStruct(msg,priority)
	local struct = {msg = msg,priority = priority,date = os.time()}
	function struct:getMsg()
		return string.format(loghead,os.date("%H:%M:%S",self.date),self.msg)
	end
	return struct
end

function log.pushlog(msg,priority)
--	local msgstruct = {msg 		= msg,priority 	= priority}
	local msgstruct = createLogStruct(msg,priority)
	table.insert(debugcache[0],msgstruct)

	table.insert(debugcache[priority],msgstruct)
	if mlistener then
		mlistener(msgstruct)
	end
end

function log.clear()
	debugcache = {
		[0] = {},
		[Gbv.DEBUG_N] = {},
		[Gbv.DEBUG_W] = {},
		[Gbv.DEBUG_S] = {},
		[Gbv.DEBUG_E] = {},
	}
end
function log.getLog(type)
	return debugcache[type or 0]
end
function log.addListener(listener)
	mlistener = listener
end
--将日志保存到本地
function log.saveToFiles()
	local dir = cc.FileUtils:getInstance():getWritablePath()
	local alllogs = debugcache[0]
	local tb = {}
	for i = 1,#alllogs do
		tb[i] = string.format("[%s]:%s",os.date("%H:%M:%S",alllogs[i].date),alllogs[i].msg)
	end
	io.writefile(
--		dir .. "gamelog.txt",
		"gamelog.txt",
		table.concat(tb," \n")
	)
end
log.clear()

setmetatable(log,log)
return log
