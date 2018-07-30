--[[
*	A*算法
*	决定A*算法的速率和准确度完全依赖于 heuristic 估价函数
*	应该根据应用场景的实际情况设计估价函数
*	估价函数的调用会传入3个参数 (当前点，起点，终点)
*
*#########说明##########
*	如果h(n)是0，则只有g(n)起作用，此时A* 算法演变成Dijkstra算法，就能保证找到最短路径，但是效率最低。
*	如果h(n)总是比从n移动到目标的代价小（或相等），那么A* 保证能找到一条最短路径。h(n)越小，A* 需要扩展的点越多，运行速度越慢。
*	如果h(n)正好等于从n移动到目标的代价，那么A* 将只遵循最佳路径而不会扩展到其他任何结点，能够运行地很快。尽管这不可能在所有情况下发生，
*		但你仍可以在某些特殊情况下让h(n)正好等于实际代价值。只要所给的信息完善，A* 将运行得很完美。
*	如果h(n)比从n移动到目标的代价高，则A* 不能保证找到一条最短路径，但它可以运行得更快。
*	如果h(n)比g(n)大很多，则只有h(n)起作用，同时A* 算法演变成贪婪最佳优先搜索算法（Greedy Best-First-Search），但是不能保证找到最短路径。
*
*	@author lqh
]]
local AStar = class("AStar")
--[[
*	构造函数
*	@param map 地图数据列表（一维数组）
*	@param hnfunc 启发函数
*	@param gnfunc 穿越代价获取函数
*	@param bordersfunc 获取临边方法
*	@param sourceIndex 开始点下标，可为空
*	@param targetIndex 结束点下标，可为空
]]
function AStar:ctor(map,hnfunc,gnfunc,bordersfunc,sourceIndex,targetIndex)
	self.m_map = map
	self.m_heuristic = hnfunc
	self.m_cost = gnfunc
	self.m_bordersfunc = bordersfunc
	self:search(sourceIndex,targetIndex)
end
--修改启发函数
function AStar:setHeuristic(hnfunc)
	self.m_heuristic = hnfunc
end
function AStar:getHeuristic()
	return self.m_heuristic
end
--修改代价获取函数
function AStar:setCostFunc(func)
	self.m_cost = func
end
--[[
*	搜索路径
*	@param sourceIndex 开始点下标
*	@param targetIndex 结束点下标
]]
function AStar:search(sourceIndex,targetIndex)
	if not sourceIndex or not targetIndex then return end
	self.isfind = false
	self.m_sourceIndex = sourceIndex
	self.m_targetIndex = targetIndex
	local target,source = self.m_map[targetIndex],self.m_map[sourceIndex]
	--最短路径树
	self.m_shortestPathTree = {}
	--已搜索列表
	local searched_map = {}
	--最小二叉堆
	local mintree = require("src.base.ai.BinaryHeap").new(
		nil,
		function(a,b) 
			if a.f <= b.f then return true end 
		end
	)
	--初始化第一个
	searched_map[sourceIndex] = {
		f = 0,
		g = 0,
		from = sourceIndex,			--路径起始点
		to = sourceIndex			--路径到达点（一般为该点本身）
	}
	mintree:insert(searched_map[sourceIndex])
	
	local data,temp,g,h
	while not mintree:isEmpty() do
		data = mintree:pop()
		--添加到最短路径树
		self.m_shortestPathTree[data.to] = data.from
		if data.to == targetIndex then 
			self.isfind = true
			self.m_searched_map = searched_map
			return self.isfind
		end
		--遍历该点可到达点的下标集合
		for k,v in pairs(self.m_bordersfunc(self.m_map[data.to])) do
			temp = self.m_map[v]
			--启发函数计算该点到目标点开销
			h = self.m_heuristic(temp,target,source)
			--源到该点的真实开销
			g = data.g + self.m_cost(temp,data.to)
			--如果该点未搜索
			if not searched_map[v] then
				
				searched_map[v] = {
					f = g + h,
					g = g,
					from = data.to,
					to = v
				}
				mintree:insert(searched_map[v])
			--如果该点的原有g大于现在的g，且未加入最短路径树
			elseif g < searched_map[v].g and not self.m_shortestPathTree[v] then
				searched_map[v].g = g
				searched_map[v].f = g + h
				searched_map[v].from = data.to
				--向上修正二叉堆
				mintree:reorderUpwards(searched_map[v])
			end
		end
	end
	self.m_searched_map = searched_map
end
--获取路径
function AStar:getParthToTarget()
	local nd = self.m_targetIndex
	local pathlist = {}
	while self.isfind do
		table.insert(pathlist,nd)
		if nd == self.m_sourceIndex then break end
		nd = self.m_shortestPathTree[nd]
	end
	return pathlist
end
return AStar