--[[
*	常用全局基础函数扩展
]]


--将成员方法转换为回调方法
function handler(target, method)
	return function(...)
		return method(target, ...)
	end
end
--重新加载文件
function reload(name)
	package.loaded[name] = nil
	return require(name)
end

--重置随机
function RestRandom()
	math.randomseed(tonumber(tostring(os.millis()):reverse()))
	for i = 1,10 do
		--抛弃前10次随机数值
		math.random()
	end
end

--深度克隆
function clone(object)
	local lookup_table = {}
	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end
		--如果是多维table继续递归
		local new_table = {}
		lookup_table[object] = new_table
		for key, value in pairs(object) do
			new_table[_copy(key)] = _copy(value)
		end
		return setmetatable(new_table, getmetatable(object))
	end
	return _copy(object)
end

--转换number
function tonum(v, base)
    return tonumber(v, base) or 0
end
--取整
function toint(v)
    return math.round(tonum(v))
end
--判断bool
function tobool(v)
    return (v ~= nil and v ~= false)
end
--是否为table
function totable(v)
    if type(v) ~= "table" then v = {} end
    return v
end
--table中key值是否存在
function isset(arr, key)
    local t = type(arr)
    return (t == "table" or t == "userdata") and arr[key] ~= nil
end
