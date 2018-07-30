--[[
*	模糊逻辑 类
*	@author lqh
]]
local FuzzyModule = class("FuzzyModule")
--模糊变量 表
FuzzyModule.m_variableMap = nil
--模糊逻辑规则列表
FuzzyModule.m_rules = nil
--构造函数
function FuzzyModule:ctor()
	self.m_variableMap = {}
	self.m_rules = {}
end
--创建一个模糊变量
function FuzzyModule:createFLV(name)
	self.m_variableMap[name] = require("src.base.ai.fuzzy.FuzzyVariable").new()
	return self.m_variableMap[name]
end
--[[
*	添加模糊变量规则
*	@param antecedent 因
*	@param consequence 果
]]
function FuzzyModule:addRule(antecedent,consequence)
	table.insert(self.m_rules,require("src.base.ai.fuzzy.FuzzyRule").new(antecedent,consequence))
end
function FuzzyModule:addRules(list)
	for i = 1,#list do
		self:addRule(list[i][1],list[i][2])
	end
end
--[[
*	调用一个指定模糊变量的模糊方法
]]
function FuzzyModule:fuzzify(name,value)
	self.m_variableMap[name]:fuzzify(value)
end
--[[
*	调用一个指定模糊变量的反模糊化方法
*	@param name 名字
*	@param method 方法(1:最大值法，2：中心点法)
]]
function FuzzyModule:deFuzzify(name,method)
	for i = 1,#self.m_rules do
		self.m_rules[i]:calculate()
	end
	if method == 1 then
		return self.m_variableMap[name]:deFuzzifyMaxValue()
	elseif method == 2 then
		--此处用20个采样点
		return self.m_variableMap[name]:deFuzzifyCentroid(20)
	end
	return 0
end
--[[
*	重置所有集合的最大dom值为0
*	每次模糊化之前都应该调用该方法刷新dom值为0
]]
function FuzzyModule:flushDOMToZero()
	for k,v in pairs(self.m_variableMap) do
		v:flushDOMToZero()
	end
end
--[[
*	执行模糊逻辑运算
*	@param fuzzifylist 模糊化的 name,value列表
*	@param deFuzzifylist 反模糊化的name,method列表
]]
function FuzzyModule:calculate(fuzzifylist,deFuzzifylist)
	self:flushDOMToZero()
	for i = 1,#fuzzifylist do
		self:fuzzify(fuzzifylist[i].name,fuzzifylist[i].value)
	end
	local result = {}
	for i = 1,#deFuzzifylist do
		result[i] = self:deFuzzify(deFuzzifylist[i].name,deFuzzifylist[i].method)
	end
	return unpack(result)
end

return FuzzyModule