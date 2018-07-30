--[[
*	单一水平线段 模糊集合函数
*	@author lqh
]]
local FuzzySingl = class("FuzzySingl",require("src.base.ai.fuzzy.set.FuzzySet"))
FuzzySingl.m_mid = 0
FuzzySingl.m_leftOffset = 0
FuzzySingl.m_rightOffset = 0
--[[
*	@param mid 水平线段 中点
*	@param leftOffset 顶点向左偏移量
*	@param rightOffset 顶点向右偏移量
]]
function FuzzySingl:ctor(mid,leftOffset,rightOffset)
	self:super("ctor",mid)
	self.m_mid = mid
	self.m_leftOffset = leftOffset
	self.m_rightOffset = rightOffset
end
--override
function FuzzySingl:calculateDOM(value)
	if value >= self.m_leftOffset and value <= self.m_rightOffset then return 1 end
	return 0 
end
return FuzzySingl