--[[
*	逻辑 相当的
*	@author lqh
]]
local FzoFairly = class("FzoFairly",require("src.base.ai.fuzzy.operate.IFuzzyOperate"))
FzoFairly.m_sets = nil
function FzoFairly:ctor(fuzzySet)
	self.m_sets = fuzzySet
end
function FzoFairly:getDOM()
	return math.sqrt(self.m_sets:getDOM())
end
function FzoFairly:clearDOM()
	self.m_sets:clearDOM()
end
function FzoFairly:orWithDOM(value)
	self.m_sets:orWithDOM(value)
end
function FzoFairly:clone()
	return FzoFairly.new(self.m_sets)
end
return FzoFairly