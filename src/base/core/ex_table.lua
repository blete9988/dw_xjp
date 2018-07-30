--[[
*	table扩展
*	增加一些table的常用拷贝，插入，段插入，删除，查找方法
]]


--求表成员数量
function table.nums(t)
	local count = 0
	for k, v in pairs(t) do
		count = count + 1
	end
	return count
end
--乱序有序表
function table.randomList(list)
	local clonelist,len,index = table.merge({},list),#list,1
	while len > 0 do
		list[index] = table.remove(clonelist,(math.floor(math.random()*len*100000)%len) + 1)
		len = len - 1
		index = index + 1
	end
end
--返回一个散列表的所有key的列表
function table.keys(t)
	local keys,index = {},1
	for k, v in pairs(t) do
		keys[index] = k
		index = index + 1
	end
	return keys
end
--将一个散列表，转换成一个顺序列表
function table.values(t)
	local values,index = {},1
	for k, v in pairs(t) do
		values[index] = v
		index = index + 1
	end
	return values
end
--[[
*	将src对象数据合并到 dest 目标数据上
*	@param:dest		目标表
*	@param:src		源表
]]
function table.merge(dest, src)
	dest = dest or {}
	for k, v in pairs(src) do
		dest[k] = v
	end
	return dest
end
--[[
*	查找散列表上元素的 key（键）为 value（值）的键值
*	@return key键
]]
function table.findKeyOf(map,key,value)
	for k,v in pairs(map) do
		if v[key] == value then
			return k
		end
	end
end
--[[
*	查找散列表上元素的 key（键）为 value（值）的元素
*	@return item项
]]
function table.findKeyOfItem(map,key,value)
	local mapkey = table.findKeyOf(map,key,value)
	if mapkey then
		return map[mapkey]
	end
end
--[[
*	查找散列表上 指定元素的 键值
*	@return key键
]]
function table.findItem(map,item)
	for k,v in pairs(map) do
		if v == item then
			return k
		end
	end
end
--交换table的值
function table.swap(t,destIndex,targetIndex)
	local temp = t[destIndex]
	t[destIndex] = t[targetIndex]
	t[targetIndex] = temp
end
-- ---------------------顺序表（list）---------------------------
--反向列表
function table.reverse(t)
	local len = #t
	if len <= 1 then return t end
	for i = 1,math.floor(len*0.5) do
		table.swap(t,i,len - i + 1)
	end
	return t
end
--[[
*	截取数组的指定起始索引 到 结束索引的数据
*	@param：t 			数组
*	@param：fromIndex：	指定起始所以（默认参数为1）（包括)
*	@param：toIndex：	指定结束索引（默认参数为数组长度）（包括)
]]
function table.copyOf(t,fromIndex,toIndex--[[ = nill]])
	fromIndex = fromIndex or 1
	toIndex = toIndex or #t
	local list,index = {},1
	for i = fromIndex,toIndex do
		list[index] = t[i]
		index = index + 1
	end
	return list
end
--[[
*	返回此列表中首次出现的指定元素的索引，或如果此列表不包含元素，则返回 -1。
*	从index指定位置正向搜索
*	@param：t 		指定列表
*	@param：item 	指定元件
*	@param：index 	指定查找起始索引位置（默认值 1）
]]
function table.indexOf(t,item,index--[[ = 1]])
	index = index or 1
	for i = index,#t do
		if t[i] == item then
			return i
		end
	end
	return -1
end
--[[
*	返回此列表中最后一次出现的指定元素的索引，或如果此列表不包含索引，则返回 -1。
*	从index指定位置逆向搜索
*	@param：t 		指定列表
*	@param：item 	指定元件
*	@param：index 	未指定则为默认数组末尾
]]
function table.lastIndexOf(t,item,index--[[ = nill]])
	index = index or #t
	if index < 1 then return -1 end
	for i = index,1,-1 do
		if t[i] == item then
			return i
		end
	end
	return -1
end
--[[
*	返回此列表中首次出现的指定 成员变量（key）值为（value）的索引，或如果此列表不包含索引，则返回 -1。
*	从index指定位置逆向搜索
*	@param：t 			指定列表
*	@param：key 			指定变量
*	@param：value 		指定值
*	@param：index 		未指定则为默认数组起始位置
]]
function table.indexOfKey(t,key,value,index--[[ = 1]])
	index = index or 1
	local len,item = #t
	for i = index,len do
		item = t[i]
		if item and item[key] == value then
			return i
		end
	end
	return -1
end
--[[
*	移除列表中索引在 fromIndex（包括）和 toIndex（包括）之间的所有元素。数组所有后面元素将向前移动
*	@param:t			指定列表
*	@param:fromIndex	指定开始位置
*	@param:toIndex		指定结束位置(默认为数组长度)
]]
function table.removeRange(t,fromIndex,toIndex--[[ = nill]])
	fromIndex = fromIndex or 1
	toIndex = toIndex or #t
	local list = table.copyOf(t,toIndex + 1)
	local index = 1
	for i = fromIndex,#t do
		t[i] = list[index]
		index = index + 1
	end
end
--[[
*	移除列表中指定的item项
*	@param：t 			数组
*	@param：item 		指定数据对象
*	@param：index 		指定索引位置开始查找（默认值为数组起始位置）
]]
function table.removeItem(t,item,index--[[ = 1]])
	local checkIndex = table.indexOf(t,item,index)
	if checkIndex > 0 then
		table.remove(t,checkIndex)
		return true
	end
end
--[[
*	移除列表中的项 指定key为value的项
*	@param：t 			列表
*	@param：key 			键
*	@param：value 		值
*	@param：index 		指定开始索引位置（默认值为数组起始位置）
]]
function table.removeKey(t,key,value,index--[[ = 1]])
	local checkIndex = table.indexOfKey(t,key,value,index)
	if checkIndex > 0 then
		table.remove(t,checkIndex)
	end
end