--[[
*	模糊逻辑规则 类
*	@author lqh
]]
local FuzzyRule = class("FuzzyRule")
FuzzyRule.m_antecedent = nil
FuzzyRule.m_consequence = nil
--[[
*	@param antecedent 前因
*	@param consequence 结果
]]
function FuzzyRule:ctor(antecedent,consequence)
	self.m_antecedent = antecedent
	self.m_consequence = consequence
end
--执行
function FuzzyRule:calculate()
	self.m_consequence:orWithDOM(self.m_antecedent:getDOM())
end
return FuzzyRule