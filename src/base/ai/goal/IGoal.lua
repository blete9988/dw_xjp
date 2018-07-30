--[[
*	只能体目标驱动原子 接口
*	@author lqh
]]
local IGoal = class("IGoal")
--状态参数定义
IGoal.active = 0		--目标活跃的，并且每一步更新中都要被处理
IGoal.inactive = 1		--目标闲置的，目标等待被激活
IGoal.completed = 2		--目标完成，在下一次更新时将被删除
IGoal.failed = 3		--目标失败，下次更新中要么重新规划，要么被删除
--成员变量定义
IGoal.m_status = IGoal.inactive	--目标当前状态，默认为闲置
IGoal.m_type = nil				--类型
function IGoal:ctor(type)
	self.m_type = type
end
--[[
*	激活目标
*	@need override
]]
function IGoal:activate()
	self.m_status = IGoal.active
end
--[[
*	处理目标 
*	@need override
*	@return status 返回当前子目标状态
]]
function IGoal:process()
	self.activateIfInactive()
end
--[[
*	终止目标，在一个目标退出之前应该调用该方法整理
*	@need override
]]
function IGoal:terminate()
end
--[[
*	目标进入
*	@need override
]]
function IGoal:enter()
end
--[[
*	目标退出
*	@need override
]]
function IGoal:exit()
end
--[[
*	添加子目标（组合目标需要实现该方法，原子目标可以忽略）
*	@need override
]]
function IGoal:addSubgoal()
end
--如果闲置状态恢复活动状态
function IGoal:activateIfInactive()
	if self.isInactive() then
		self.activate()
	end
end
--如果失败状态恢复活动状态
function IGoal:reactivateIfFailed()
	if self.isFailed() then
		self.m_status = IGoal.inactive
	end
end
--目标是否完成状态
function IGoal:isComplete()
	return self.m_status == IGoal.completed
end
--目标是否激活状态
function IGoal:isActive()
	return self.m_status == IGoal.active
end
--目标是否闲置状态
function IGoal:isInactive()
	return self.m_status == IGoal.inactive
end
--目标是否失败
function IGoal:isFailed()
	return self.m_status == IGoal.failed
end
function IGoal:getType()
	return self.m_type
end
return IGoal