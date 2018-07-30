--[[
*	文本缓存池
*	@author:lqh
]]
local LabelPools = {}
--gc 间隔 2.5s
local pause = 2.5
--gc 步长 5
local gcstep = 15
--[[
*	缓存池
*	@whitepools 白色缓存池存 放新生对象(顺序表)
*	@greenpools 绿色缓存池存放 中期对象(顺序表)
*	@redpools 红色缓存池存放 将释放的对象(散列表)
]]
local whitepools,greenpools,redpools = {}
--键值
local keyseed = 0
local gc_timehandler = nil
local greenNoFree = false

local function GetKey()
	keyseed = keyseed + 1
	return tostring(keyseed)
end

local function AddToWhite(label)
	whitepools[GetKey()] = label
end

local function AddToRed(label)
	redpools[GetKey()] = label
end

local function AddToGreen(label)
	greenpools[GetKey()] = label
end

local function Launch_gcloop()
	if gc_timehandler then return end
	local index = 0
	local offset = 1
	gc_timehandler = timeup(function() 
		greenNoFree = false
		index = index + 1
		for k,v in pairs(whitepools) do
			AddToGreen(v)
			whitepools[k] = nil
		end
		if index%2 ~= 0 then return end
		--回收 红色缓存池的文本对象
		local step = gcstep
		for k,v in pairs(redpools) do
			v:release()
			redpools[k] = nil
			step = step - 1
			if step < 1 then break end
		end
		--将绿色缓存池的文本放入红色缓存池
		for k,v in pairs(greenpools) do
			if v.outpool then
				v:release()
				greenpools[k] = nil
			elseif v:getReferenceCount() == 1 then
				AddToRed(v)
				greenpools[k] = nil
			end
		end
--		LabelPools.tostring()
	end,pause)
end

--[[
*	@private static
*	获取一个缓存label
]]
local function GetPoolLabel()
	--首先从红色缓存池中获取文本对象
	local k,v = next(redpools)
	if k then
		redpools[k] = nil
		return v
	end
end

function LabelPools.getLabel()
	--从缓存池获取文本对象
	local label = GetPoolLabel()
	if not label then
		--新建一个文本对象并添加引用
		label = cc.Label:create()
		label:retain()
	else
		label:disableEffect()
		label:setScale(1)
		label:setOpacity(255)
		label:setRotation(0)
	end
	--放入新生代缓存池
	AddToWhite(label)
	return label
end
--设置gc间隔
function LabelPools.setGcpause(t)
	if not t or t == pause then return end
	pause = t
	LabelPools.clear()
end
--设置gc步长，每次回收数量
function LabelPools.setGcStep(step)
	if not step then return end
	gcstep = step
end
function LabelPools.tostring()
	local count = 0
	for k,v in pairs(whitepools) do count = count + 1 end
	mlog(string.format("<LabelPools>:whitepools len is : %d",count))
	count = 0
	for k,v in pairs(greenpools) do count = count + 1 end
	mlog(string.format("<LabelPools>:greenpools len is : %d",count))
	count = 0
	for k,v in pairs(redpools) do count = count + 1 end
	mlog(string.format("<LabelPools>:redpools len is : %d",count))
end

--清楚所有缓存
function LabelPools.clear()
	LabelPools.stop()
	
	Launch_gcloop()
end
function LabelPools.stop()
	--停止gc
	if gc_timehandler then timestop(gc_timehandler) end
	
	--清除当前缓存池中的所有文本对象
	local list  = {whitepools,greenpools,redpools}
	for i = 1,#list do
		for k,v in pairs(list[i]) do
			v:release()
		end
	end
	whitepools,greenpools,redpools = {},{},{}
	gc_timehandler = nil
end
LabelPools.clear()

return LabelPools