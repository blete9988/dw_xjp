--[[
*	逻辑或 操作
*	逻辑模糊 或 运算 == 求逻辑集合中最大的隶属值
*	@author lqh
]]
local FzoOr = class("FzoOr",require("src.base.ai.fuzzy.operate.IFuzzyOperate"))
FzoOr.m_sets = nil
--[[
*	逻辑与运算构造函数
*	@param ... 支持任意>=2个逻辑集合于运算
]]
function FzoOr:ctor(...)
	local lt = {...}
	local len = #lt
	if len < 2 then error("FuzzySet or operate need 2 variable!!!") end
	self.m_sets = {}
	for i = 1,len do
		self.m_sets[i] = lt[i]
	end
end
function FzoOr:getDOM()
	local max,vl = nil
	for i = 1,#self.m_sets do
		vl = self.m_sets[i]:getDOM()
		if not max or vl > max then
			max = vl
		end
	end
	return max
end
function FzoOr:clearDOM()
	for i = 1,#self.m_sets do
		self.m_sets[i]:clearDOM()
	end
end
function FzoOr:orWithDOM(value)
	for i = 1,#self.m_sets do
		self.m_sets[i]:orWithDOM(value)
	end
end
function FzoOr:clone()
	return FzoOr.new(unpack(self.m_sets))
end
return FzoOr