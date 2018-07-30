--[[
*	右肩形模糊集合函数
*	|			 ____________________________________
*	|			/
*	|		   /
*	|		  /
*	|		 /
*	|		/
*	|______/__________________________________________________
*	@author lqh
]]
local FuzzyRightShoulder = class("FuzzyRightShoulder",require("src.base.ai.fuzzy.set.FuzzySet"))
FuzzyRightShoulder.m_mid = 0
FuzzyRightShoulder.m_leftOffset = 0
FuzzyRightShoulder.m_rightOffset = 0
--[[
*	@param mid 右肩形 转角点
*	@param leftOffset 顶点向左偏移量
*	@param rightOffset 顶点向右偏移量
]]
function FuzzyRightShoulder:ctor(mid,leftOffset,rightOffset)
	self:super("ctor",mid + rightOffset/2)
	self.m_mid = mid
	self.m_leftOffset = leftOffset
	self.m_rightOffset = rightOffset
end
--override
function FuzzyRightShoulder:calculateDOM(value)
	if (self.m_leftOffset == 0 and value == self.m_mid) or (self.m_rightOffset == 0 and value == self.m_mid) then return 1 end
	if value > self.m_mid - self.m_leftOffset and value < self.m_mid then
		local k = 1/self.m_leftOffset
		return k * (value - (self.m_mid - self.m_leftOffset))
	elseif value >= self.m_mid and value <= self.m_mid + self.m_rightOffset then
		return 1
	else
		return 0
	end
end
return FuzzyRightShoulder