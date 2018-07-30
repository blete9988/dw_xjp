--[[
*	逻辑 非常的
*	@author lqh
]]
local FzoVery = class("FzoVery",require("src.base.ai.fuzzy.operate.IFuzzyOperate"))
FzoVery.m_sets = nil
function FzoVery:ctor(fuzzySet)
	self.m_sets = fuzzySet
end
function FzoVery:getDOM()
	return math.pow(self.m_sets:getDOM(),2)
end
function FzoVery:clearDOM()
	self.m_sets:clearDOM()
end
function FzoVery:orWithDOM(value)
	self.m_sets:orWithDOM(value)
end
function FzoVery:clone()
	return FzoVery.new(self.m_sets)
end
return FzoVery