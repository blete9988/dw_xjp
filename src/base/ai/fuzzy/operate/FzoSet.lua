--[[
*	逻辑单个操作
*	@author lqh
]]
local FzoSet = class("FzoSet",require("src.base.ai.fuzzy.operate.IFuzzyOperate"))
FzoSet.m_sets = nil
function FzoSet:ctor(fuzzySet)
	self.m_sets = fuzzySet
end
function FzoSet:getDOM()
	return self.m_sets:getDOM()
end
function FzoSet:clearDOM()
	self.m_sets:clearDOM()
end
function FzoSet:orWithDOM(value)
	self.m_sets:orWithDOM(value)
end
function FzoSet:clone()
	return FzoSet.new(self.m_sets)
end
return FzoSet