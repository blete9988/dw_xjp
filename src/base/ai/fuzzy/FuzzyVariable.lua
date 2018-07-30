--[[
*	模糊变量
*	一个模糊变量是由几段（集合类型）的模糊集合组成
*	模糊变量应使用者该满足模糊逻辑的两个条件
*	@1:通过模糊变量的任何竖线，在每个同他相交的模糊集合中的隶属度总和应该接近于1
*	@2:模糊变量中的集合，应该只于1个或者更少的集合相交
*	|			 /\    /\
*	|			/   \ /	 \
*	|		   /	 X	  \
*	|		  /		/ \	   \
*	|		 /	   /   \	\
*	|		/	  /		\	 \
*	|	   /	 /		 \	  \
*	|_____/_____/_________\____\_____________________________________
*	不满足1，这种集合在X处相交，但是分别在两个集合中的隶属度 相加远大于1.
*	|
*	|
*	|
*	|		   /\		  /\
*	|		  /	 \		 /	\
*	|		 /	  \		/	 \
*	|		/	   \   /	  \
*	|______/________\_/__	   \
*	|	  /			 X	 \		\
*	|____/__________/_\___\______\_____________________________________
*	不满足条件2,，左肩集合同时和2个集合相交
*	@author lqh
]]
local FuzzyVariable = class("FuzzyVariable")
--集合最小值
FuzzyVariable.m_minRange = nil
--集合最大值
FuzzyVariable.m_maxRange = nil
--集合函数 table表
FuzzyVariable.m_memberSet = nil

--构造函数
function FuzzyVariable:ctor()
	self.m_memberSet = {}
end
--[[
*	@private
*	修改集合区间
]]
function FuzzyVariable:m_fixRange(min,max)
	if not self.m_minRange or min < self.m_minRange then self.m_minRange = min end
	if not self.m_maxRange or max > self.m_maxRange then self.m_maxRange = max end
end
--[[
*	添加三角形模糊 集合
*	@param name 集合名
*	@param left 左值
*	@param mid 顶点
*	@param right 右值
]]
function FuzzyVariable:addFuzzyTriangle(name,left,mid,right)
	self.m_memberSet[name] = require("src.base.ai.fuzzy.set.FuzzyTriangle").new(mid,mid-left,right-mid)
	self:m_fixRange(left,right)
	return require("src.base.ai.fuzzy.operate.FzoSet").new(self.m_memberSet[name])
end
--[[
*	添加左肩模糊 集合
*	@param name 集合名
*	@param left 左值
*	@param mid 中间值
*	@param right 右值
]]
function FuzzyVariable:addFuzzyLeftShoulder(name,left,mid,right)
	self.m_memberSet[name] = require("src.base.ai.fuzzy.set.FuzzyLeftShoulder").new(mid,mid-left,right-mid)
	self:m_fixRange(left,right)
	return require("src.base.ai.fuzzy.operate.FzoSet").new(self.m_memberSet[name])
end
--[[
*	添加右肩模糊 集合
*	@param name 集合名
*	@param left 左值
*	@param mid 中间值
*	@param right 右值
]]
function FuzzyVariable:addFuzzyRightShoulder(name,left,mid,right)
	self.m_memberSet[name] = require("src.base.ai.fuzzy.set.FuzzyRightShoulder").new(mid,mid-left,right-mid)
	self:m_fixRange(left,right)
	return require("src.base.ai.fuzzy.operate.FzoSet").new(self.m_memberSet[name])
end
--[[
*	添加单一水平直线模糊 集合
*	@param name 集合名
*	@param left 左值
*	@param mid 中间值
*	@param right 右值
]]
function FuzzyVariable:addFuzzySingle(name,left,mid,right)
	self.m_memberSet[name] = require("src.base.ai.fuzzy.set.FuzzySingle").new(mid,mid-left,right-mid)
	self:m_fixRange(left,right)
	return require("src.base.ai.fuzzy.operate.FzoSet").new(self.m_memberSet[name])
end
--重置所有集合的最大dom值为0
function FuzzyVariable:flushDOMToZero()
	for k,v in pairs(self.m_memberSet) do
		v:clearDOM()
	end
end
--模糊化一个值
function FuzzyVariable:fuzzify(value)
	--超过边界，不进行计算，默认为0
	if value < self.m_minRange or value > self.m_maxRange then return end
	for k,v in pairs(self.m_memberSet) do
		v:setDOM(v:calculateDOM(value))
	end
end
--[[
*	用最大值平均法去模糊化
*	每种集合的 代表值*置信度（隶属值）叠加 / 每种集合的置信度叠加
]]
function FuzzyVariable:deFuzzifyMaxValue()
	local bottom,top,vl = 0,0
	for k,v in pairs(self.m_memberSet) do
		vl = v:getDOM()
		bottom = bottom + vl
		top = top + v:getRepresentativeVal() * vl
	end
	if bottom == 0 then return 0 end
	return top/bottom
end
--[[
*	用中心法去模糊化，比最大平均值法更精确
*	每个采样点的值*这个采样点的模糊逻辑隶属值 叠加 / 每个采样点的模糊逻辑隶属值 叠加
*	采样点越多越精确
*	@param simpleRate 采样率
]]
function FuzzyVariable:deFuzzifyCentroid(simpleRate)
	local step = (self.m_maxRange - self.m_minRange)/simpleRate
	local bottom,top,vl,sign = 0,0
	for k,v in pairs(self.m_memberSet) do
		for i = 1,simpleRate do
			sign = self.m_minRange + step*(i - 1)
			vl = math.min(v:calculateDOM(sign),v:getDOM())
			bottom = bottom + vl
			top = top + sign*vl
		end
	end
	if bottom == 0 then return 0 end
	return top/bottom
end
return FuzzyVariable