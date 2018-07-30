--[[
*	面向对象 编程扩展
*	添加class 全局方法，添加 setmetatableex 方法用作setmetatable的扩展实现面向对象编程
]]

local getmetatable = getmetatable
local setmetatable = setmetatable
function setmetatableex(t,index)
	if type(t) == "userdata" then
		local peer = tolua.getpeer(t)
		if not peer then
			peer = {}
			tolua.setpeer(t, peer)
        end
    	setmetatableex(peer,index)
    else
        local mt = getmetatable(t)
        if not mt then 
        	--没有metatable，直接设置metatable
        	if index.__index then
        		setmetatable(t, index) 
        	else
        		setmetatable(t, {__index = index}) 
        	end
        else
        	if not mt.__index then
        		mt.__index = index
           		setmetatable(t, mt)
        	else
        		if type(mt.__index) == "function" then
        			mt.__indexlen = mt.__indexlen + 1
        			mt.__indexlist[mt.__indexlen] = index
        		else
        			local newmt = {}
        			newmt.__indexlist 	= {mt.__index,index}
        			newmt.__indexlen 	= 2
        			newmt.__index = function(t,key)
        				local _mt = getmetatable(t)
        				for i = _mt.__indexlen ,1,-1 do
        					if _mt.__indexlist[i][key] then return _mt.__indexlist[i][key] end
        				end
        				return nil
        			end
        			setmetatable(t, newmt)
        		end
        	end
        end
    end
end
--有循环引用会造成栈溢出
local function merge(dest,src,ignore)
	ignore = ignore or {}
	for k,v in pairs(src) do
		if not ignore[k] then
			if type(v) == "table" then
				if v.__cname then
					dest[k] = v
				else
					dest[k] = merge({},v,ignore)
				end
			else
				dest[k] = v
			end
		end
	end
	return dest
end

--所有类的模板基类
local classtemplate = {
	ctor = function() end,
	--获取类名
	getClass = function(t)
		return t.__cname
	end,
	--调用父方法
	super = function(t,k,...)
		--debug.getinfo(1).name
		--记录正在执行的super方法
		if not t.__dosuper then t.__dosuper = {} end
		local csp
		
		if t.__dosuper[k] then 
			csp = t.__dosuper[k].__super 
		else
			csp = t.__super
		end
		if not csp then error("attemp to get invalid superclass") return end
		
		--调用该方法当前所处环境类
		local envircls = t.__dosuper[k] or t
		while csp and envircls[k] == csp[k] do
			--方法未重载
			envircls = csp
			csp = csp.__super
		end
		
		if not csp or not csp[k] then error(string.format("attempt to get superclass function by name <%s> is invalid",k)) end
		
		t.__dosuper[k] = csp
		local result = {csp[k](t,...)}
		t.__dosuper[k] = nil
		return unpack(result)
	end,
	--判断是否 name类
	iskindof = function(t,name)
		local super = t
		while super do
			if super.__cname == name then
				return true
			end
			super = super.__super
		end
		return false
	end
}
--interface拷贝忽略模板
local ignore = {
	ctor 		= true,
	getClass 	= true,
	super 		= true,
	iskindof 	= true,
	__create 	= true,
	__index 	= true,
	__cname		= true,
	__super		= true,
	class		= true
}
--[[
*	类构建
*	@param classname 	类名
*	@param super 		父类
*	@param ... 			接口，可以至多有一个方法，如果有方法则会代替__create 方法
]]
function class(classname,super--[[ = nil]],...--[[ = nil]])
	if not classname then error("class must have a name !!") end
	local supertype = type(super)
	local cls = {}
	local interface = {...}
	for i = 1,#interface do
		local interfacetype = type(interface[i])
		if interfacetype == "table" then
			cls = merge(cls,interface[i],ignore)
			
		elseif interfacetype == "function" then
			if cls.__create then error(string.format("class '%s' already had __create function,can not set again",classname)) end
			cls.__create = interface[i]
		end
	end
	
	if super and (supertype == "function" or supertype == "table") then
		if supertype == "function" then
			if cls.__create then error(string.format("class '%s' already had __create function",classname)) end
			
			cls = merge(cls,classtemplate)
			cls.__create = super
		else
			if super.__cname then
				--忽略 class,__index,__super等会循环引用和重置的属性
				cls = merge(cls,super,{
					__create 	= tobool(cls.__create),
					class 		= true,
					__index 	= true,
					__super 	= true
				})
				cls.__super = super
			else
				cls = merge(cls,super,ignore)
				cls = merge(cls,classtemplate)
			end
		end
	else
		cls = merge(cls,classtemplate)
	end
	cls.__cname,cls.class = classname,cls
--	cls.__index = nil
	cls.__index = cls
	
	cls.new = function(...)
        local obj
        if cls.__create then
            obj = cls.__create(...)
        else
            obj = {}
        end
    	
        setmetatableex(obj, cls)
        obj:ctor(...)
        return obj
    end
	return cls
end