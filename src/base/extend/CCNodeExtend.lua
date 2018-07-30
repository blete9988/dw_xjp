local CCNodeExtend = class("CCNodeExtend",function(target) 
	return target
end)

function CCNodeExtend.extend(target)
--    local t = tolua.getpeer(target)
--    if not t then
--        t = {}
--        tolua.setpeer(target, t)
--    end
--    setmetatable(t, {__index = CCNodeExtend})
    setmetatableex(target,CCNodeExtend)
    return target
end

--[[
	-类似于帧函数，每隔interval时间都会执行一次callback方法
	-callback：回调方法
	-interval：间隔时间
--]]
function CCNodeExtend:schedule(callback, interval)
	local seq
	if interval and interval ~= 0 then
		seq = cc.Sequence:create({
			cc.DelayTime:create(interval),
			cc.CallFunc:create(callback)
		})
	else
		seq = cc.Sequence:create({
			cc.CallFunc:create(callback)
		})
	end
    local action = cc.RepeatForever:create(seq)
    self:runAction(action)
    return action
end
function CCNodeExtend:onTimer(callback,interval)
	self:schedule(callback,interval)
end
--[[
	-延迟执行函数（只执行一次）
	-callback：回调函数
	-delay：延迟时间
--]]
function CCNodeExtend:performWithDelay(callback, delay)
    local action = cc.Sequence:create({
        cc.DelayTime:create(delay),
        cc.CallFunc:create(callback)
    })
    self:runAction(action)
    return action
end
function CCNodeExtend:delayTimer(callback, delay)
	self:performWithDelay(callback, delay)
end

function CCNodeExtend:onEnter()
end

function CCNodeExtend:onExit()
end

function CCNodeExtend:onDestory()
end

function CCNodeExtend:onEnterTransitionFinish()
end

function CCNodeExtend:onExitTransitionStart()
end

function CCNodeExtend:onCleanup()
end
function CCNodeExtend:m_nodeEventHandler(event)
	if event == "enter" then
        self:onEnter()
    elseif event == "exit" then
        self:onExit()
    elseif event == "destory" then
    	self:onDestory()
    elseif event == "enterTransitionFinish" then
        self:onEnterTransitionFinish()
    elseif event == "exitTransitionStart" then
        self:onExitTransitionStart()
    elseif event == "cleanup" then
        self:onCleanup()
    end
end

function CCNodeExtend:setNodeEventEnabled(enabled, callback--[[ = nil ]])
    if enabled then
        if not callback then
            callback = handler(self,self.m_nodeEventHandler)
        end
        self:registerScriptHandler(callback)
    else
        self:unregisterScriptHandler()
    end
    return self
end
return CCNodeExtend