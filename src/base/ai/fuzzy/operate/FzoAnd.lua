--[[
*	逻辑与 操作
*	逻辑模糊 与 运算 == 求逻辑集合中最小的隶属值
*	@author lqh
]]
local FzoAnd = class("FzoAnd",require("src.base.ai.fuzzy.operate.IFuzzyOperate"))
FzoAnd.m_sets = nil
--[[
*	逻辑与运算构造函数
*	@param ... 支持任意>=2个逻辑集合于运算
]]
function FzoAnd:ctor(...)
	local lt = {...}
	local len = #lt
	if len < 2 then error("FuzzySet and operate need 2 variable!!!") end
	self.m_sets = {}
	for i = 1,len do
		self.m_sets[i] = lt[i]
	end
end
function FzoAnd:getDOM()
	local min,vl = nil
	for i = 1,#self.m_sets do
		vl = self.m_sets[i]:getDOM()
		if not min or vl < min then
			min = vl
		end
	end
	return min
end
function FzoAnd:clearDOM()
	for i = 1,#self.m_sets do
		self.m_sets[i]:clearDOM()
	end
end
function FzoAnd:orWithDOM(value)
	for i = 1,#self.m_sets do
		self.m_sets[i]:orWithDOM(value)
	end
end
function FzoAnd:clone()
	return FzoAnd.new(unpack(self.m_sets))
end
return FzoAnd