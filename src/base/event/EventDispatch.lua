--[[
 *	事件派发
 *	@author:lqh
]]
local EventDispatch = {}
--[[
 *	继承
 *	@param：target 母体
]]
function EventDispatch.extend(target)
	for k,v in pairs(EventDispatch) do
		target[k] = v
	end
	return target
end
--初始化
function EventDispatch:m_initEvent()
	self.m_listeners 		= {}
	self.m_oncallingRecord 	= {}	--记录正在派发的事件名
end
--[[
*	事件添加监听
*	@param:event		事件名
*	@param:listener		回掉函数
*	@param:target		宿主对象
]]
function EventDispatch:addEventListener(event,listener,target--[[=nil]])
	if not listener then return false end
	if not self.m_listeners then self:m_initEvent() end
	
	local ls = self.m_listeners[event]
	if not ls then 
		ls = {}
		self.m_listeners[event] = ls 
	end
	
	local key = string.format("%s|%s",tostring(target or "nil"),tostring(listener))
	if ls[key] then return false end --已添加
	
	ls[key] = {
		listener 	= listener,
		target		= target
	}
	
	return true
end

--[[
*	派发事件，回掉函数的第一个参数永远保持event
*	@param:event		事件名
*	@param:...			不定参数
]]
function EventDispatch:dispatchEvent(event,...)
	if not self.m_listeners then return end
	
	local evtls = self.m_listeners[event]
	if not evtls then return end
	
	local templs = {}
	for k,v in pairs(evtls) do
		table.insert(templs,v)
	end
	
	local oncallingRecord = self.m_oncallingRecord
	oncallingRecord[event] = true
	local f,t
	for i = 1,#templs do
		f,t = templs[i].listener,templs[i].target
		if f then
			if t then
				f(t,event,...)
			else
				f(event,...)
			end
		end
	end
	oncallingRecord[event] = false
end

--[[
*	移除单个事件的监听
*	@param:event 			事件名
*	@param:listener			回掉函数
*	@param:target			宿主对象
]]
function EventDispatch:removeEventListener(event,listener,target--[[=nil]])
	if not self.m_listeners then return end
	
	local ls = self.m_listeners[event]
	if not ls then return end
	
	local key = string.format("%s|%s",tostring(target or "nil"),tostring(listener))
	
	if not ls[key] then return end
	
	if self.m_oncallingRecord[event] then
		ls[key].listener = nil
	end
	ls[key] = nil
end

--移除某个event的所有监听
function EventDispatch:removeEventByName(event)
	if not self.m_listeners then return end
	
	if self.m_listeners[event] and self.m_oncallingRecord[event] then
		for k,v in pairs(self.m_listeners[event]) do
			v.listener = nil
		end
	end
	self.m_listeners[event] = nil
end

--[[
*	移除某一个宿主的所有监听或者某个方法的所有回掉监听
*
*	任何一个参数为空参数，都会移除和非空参数相关的所有监听
*
*	如果两个参数都不为空，则会移除和参数一样的所有监听
*	@param:listener		回调方法
*	@param:target		宿主对象
]]
function EventDispatch:removeEventByTarget(listener,target)
	if not self.m_listeners then return end
	
	if not listener and not target then return end
	
	if not listener or not target then
		if listener then
			local key = tostring(listener)
			for ename,elst in pairs(self.m_listeners) do
				for k,v in pairs(elst) do
					if k:split("|")[2] == key then
						if self.m_oncallingRecord[ename] then v.listener = nil end
						elst[k] = nil
					end
				end
			end
		else
			local key = tostring(target)
			for ename,elst in pairs(self.m_listeners) do
				for k,v in pairs(elst) do
					if k:split("|")[1] == key then
						if self.m_oncallingRecord[ename] then v.listener = nil end
						elst[k] = nil
					end
				end
			end
		end
	else
		local key = string.format("%s|%s",tostring(target or "nil"),tostring(listener))
		for ename,elst in pairs(self.m_listeners) do
			for k,v in pairs(elst) do
				if k == key then
					if self.m_oncallingRecord[ename] then v.listener = nil end
					elst[k] = nil
				end
			end
		end
	end
	
end

--移除所有监听
function EventDispatch:removeAllEventListeners()
	if self.m_listeners then
		for ename,elst in pairs(self.m_listeners) do
			if self.m_oncallingRecord[ename] then
				for k,v in pairs(elst) do
					v.listener = nil
				end
			end
		end
	end
	self.m_listeners = nil
end

function EventDispatch:printAllEvents()
	local str = ""
	for ename,elst in pairs(self.m_listeners) do
		str = str .. string.format("event name <%s> ",ename) .. " is in calling " .. tostring(tobool(self.m_oncallingRecord[ename])) .. "  ：   "
		for k,v in pairs(elst) do
			str = str .. " ,  " .. k
		end
		str = str .. "\n"
	end
	mlog(str)
end

return EventDispatch