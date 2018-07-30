--[[
*	模糊逻辑原子基类<隶属函数类>，用于表示给定集合 在模糊逻辑中对应的隶属值
*	隶属度的范围 是 0~1
*	@author lqh
]]
local FuzzySet = class("FuzzySet")
--隶属值记录
FuzzySet.m_dom = 0
--[[
*	模糊集合中比较有代表性的一个值，是该集合在隶属值最大(为1)处的值
*	如果集合是三角形，则该值应该为顶点；如果该集合是一个平台，则应该在这个平台的中点
]]
FuzzySet.m_representativeValue = 0
--[[
*	构造方法
*	@param value 代表值(最大置信度处的值)
]]
function FuzzySet:ctor(value)
	self.m_representativeValue = value
end
function FuzzySet:getRepresentativeVal()
	return self.m_representativeValue
end
--[[
*	@need override
*	返回给定值在这个集合中的隶属度
]]
function FuzzySet:calculateDOM(value)
end
--[[
*	多重置信处理方法
*	这里采用最大值法，就是多置信度的或运算。 还有一种方法是采用有界限的和的方法（界限最大值为1）
]]
function FuzzySet:orWithDOM(value)
	if value < 0 or value > 1 then error("<FuzzySet::SetDOM>: invalid value") end
	if value > self.m_dom then self.m_dom = value end
end
function FuzzySet:getDOM()
	return self.m_dom
end
function FuzzySet:setDOM(value)
	if value < 0 or value > 1 then error("<FuzzySet::SetDOM>: invalid value") end
	self.m_dom = value
end
function FuzzySet:clearDOM()
	self.m_dom = 0
end
return FuzzySet