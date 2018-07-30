--[[
*	组合目标基类，继承至目标原子接口
*	@author lqh
]]
local GoalCompositeBase = class("GoalCompositeBase",require("src.base.ai.goal.IGoal"))
--子目标栈
GoalCompositeBase.m_subgoals = nil
function GoalCompositeBase:ctor(type)
	self:super("ctor",type)
	self.m_subgoals = {}
end
function GoalCompositeBase:activate()
	self:super("activate")
	self.removeAllSubgoals()
end
--移除所有子目标
function GoalCompositeBase:removeAllSubgoals()
	for i = 1,#self.m_subgoals do
		self.m_subgoals[i]:terminate()
	end
	self.m_subgoals = {}
end
--添加子目标，子目标总是添加到栈头，所以后添加的子目标总是被优先执行
function GoalCompositeBase:addSubgoal(g)
	table.insert(self.m_subgoals,1,g)
end
--执行子目标处理方法
function GoalCompositeBase:processSubgoals()
	while #self.m_subgoals > 0 do
		local goal = self.m_subgoals[1]
		--如果当前目标（栈顶目标）已经完成或者失败，则移除该目标
		if goal:isComplete() or goal:isFailed() then
			goal:terminate()
			--出栈
			table.remove(self.m_subgoals,1)
		else
			break
		end
	end
	if #self.m_subgoals > 0 then
		local status = self.m_subgoals[i]:process()
		if status == self.completed and #self.m_subgoals > 1 then
			--如果当前目标已经完成，并且不是最后一个目标，则返回组合目标处于活动状态
			return self.active
		end
		return status
	else
		return self.completed
	end
end
return GoalCompositeBase