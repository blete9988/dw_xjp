--[[
*	三角形模糊集合函数
*	|			 /\
*	|			/  \
*	|		   /	\
*	|		  /		 \
*	|		 /		  \
*	|		/		   \
*	|______/____________\_______________________________________________
*	@author lqh
]]
local FuzzyTriangle = class("FuzzyTriangle",require("src.base.ai.fuzzy.set.FuzzySet"))
FuzzyTriangle.m_mid = 0
FuzzyTriangle.m_leftOffset = 0
FuzzyTriangle.m_rightOffset = 0
--[[
*	@param mid 三角形顶点
*	@param leftOffset 顶点向左偏移量
*	@param rightOffset 顶点向右偏移量
]]
function FuzzyTriangle:ctor(mid,leftOffset,rightOffset)
	self:super("ctor",mid)
	self.m_mid = mid
	self.m_leftOffset = leftOffset
	self.m_rightOffset = rightOffset
end
--override
function FuzzyTriangle:calculateDOM(value)
	if (self.m_leftOffset == 0 and value == self.m_mid) or (self.m_rightOffset == 0 and value == self.m_mid) then return 1 end
	if value > self.m_mid - self.m_leftOffset and value <= self.m_mid then
		local k = 1/self.m_leftOffset
		return k * (value - (self.m_mid - self.m_leftOffset))
	elseif value > self.m_mid and value < self.m_mid + self.m_rightOffset then
		local k = 1/self.m_rightOffset
		return 1 - k * (value - self.m_mid)
	else
		return 0
	end
end
return FuzzyTriangle