--[[
*	左肩形模糊集合函数
*	|___________________			 
*	|			  		\
*	|		   			 \
*	|		  	 		  \
*	|		 		  	   \
*	|				   		\
*	|________________________\______________________________________
*	@author lqh
]]
local FuzzyLeftShoulder = class("FuzzyLeftShoulder",require("src.base.ai.fuzzy.set.FuzzySet"))
FuzzyLeftShoulder.m_mid = 0
FuzzyLeftShoulder.m_leftOffset = 0
FuzzyLeftShoulder.m_rightOffset = 0
--[[
*	@param mid 左肩形 转角点
*	@param leftOffset 顶点向左偏移量
*	@param rightOffset 顶点向右偏移量
]]
function FuzzyLeftShoulder:ctor(mid,leftOffset,rightOffset)
	self:super("ctor",mid - leftOffset/2)
	self.m_mid = mid
	self.m_leftOffset = leftOffset
	self.m_rightOffset = rightOffset
end
--override
function FuzzyLeftShoulder:calculateDOM(value)
	if (self.m_leftOffset == 0 and value == self.m_mid) or (self.m_rightOffset == 0 and value == self.m_mid) then return 1 end
	if value > self.m_mid and value < self.m_mid + self.m_rightOffset then
		local k = 1/self.m_rightOffset
		return 1 - k * (value - self.m_mid)
	elseif value >= self.m_mid - self.m_leftOffset and value <= self.m_mid then
		return 1
	else
		return 0
	end
end
return FuzzyLeftShoulder