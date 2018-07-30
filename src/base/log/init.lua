--[[
*	debug模块初始化，用于在真机和pc平台显示debug信息
*	提供打印级别和不同颜色显示各级别信息
*	使用mlog()方法调试

*	##
*		和系统print使用方法相同
*		消息级别： mlog 的第一参数可以指定消息级别，如果位指定则为普通级别消息
*		DEBUG_S 和 DEBUG_E 消息会同时打印堆栈信息
]]
-- 打印级别常量定义
Gbv.DEBUG_E = "error"		--错误
Gbv.DEBUG_S = "serious"		--严重
Gbv.DEBUG_W = "warning"		--警告
Gbv.DEBUG_N = "normal"		--普通

--日志打印方法
local mlog
local gbv = Gbv

--打印内存使用状况
if Cfg.DEBUG_MEM then
	local function showMemoryUsage()
   		echoInfo(string.format("LUA VM MEMORY USED: %0.2f KB", collectgarbage("count")))
	end
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(showMemoryUsage, 20.0, false)
end
local noprintStack
--if Cfg.DEBUG_TAG then
	local cache = require("src.base.log.log")
	--链接参数列表
	local function connectParams(params)
		for i = 1,#params do
			if not params[i] then
				params[i] = "nil"
			else
				if type(params[i]) ~= "table" then
					params[i] = tostring(params[i])
				else
					params[i] = tostring(params[i]) .. "      " .. require("src.cocos.cocos2d.json"):encode(params[i])
				end
			end
		end
		return table.concat(params,"\n")
	end
	--[[
	*	debug 打印
	*	@param ... 参数列表, 第一个参数是打印级别（可选，如果没有指定打印级别，则默认为最低级）
	*	打印级别<DEBUG_N:普通，白色；DEBUG_W：警告，黄色，DEBUG_S：严重 橙色；DEBUG_E：错误，红色>，严重以上消息将打印堆栈信息
	]]
	function mlog(...)
		local params = {...}
		local front,tm = params[1],os.date("%H:%M:%S",os.time())
		--空消息不打印
		if not front then return end
		if not params[2] then
			--只有一个参数，普通打印
			print(front)
			cache.pushlog(front,gbv.DEBUG_N)
		else
			local str
			if front == gbv.DEBUG_N or front == gbv.DEBUG_W or front == gbv.DEBUG_S or front == gbv.DEBUG_E then
				table.remove(params,1,1)
				str = connectParams(params)
				
				if not noprintStack and (front == gbv.DEBUG_S or front == gbv.DEBUG_E) then
					--严重以上消息将主动打印堆栈
					local trace = debug.traceback()
					
					str = string.format("%s\n#############Log-%s##############\n%s\n##################################",str,front,trace)
				end
				
				print(str)
				cache.pushlog(str,front)
			else
				str = connectParams(params)
				
				print(str)
				cache.pushlog(str,gbv.DEBUG_N)
			end
		end
	end
--else
--	--非调试模式下为空方法
--	function mlog() end
--end
Gbv.mlog = mlog

--lua error traceback
Gbv.__G__TRACKBACK__ = function(msg)
	noprintStack = true
	mlog(
		gbv.DEBUG_E,
		string.format(
			"##LUA ERROR: %s\n################Lua-error#################\n%s\n#########################################",
			tostring(msg),
			debug.traceback()
		)
	)
    noprintStack = false
    return msg
end

return mlog