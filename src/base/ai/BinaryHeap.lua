--[[
*	堆排序
*	堆顶元素 下标为 0， 所以每个节点的叶子节点 分别为 i*2 + 1,i*2 + 2
]]
local BinaryHeap = {}
BinaryHeap.__index = BinaryHeap
setmetatable(BinaryHeap,BinaryHeap)
--[[
*	构造函数
*	@param list 数据列表
*	@param comparefunc 比较函数
]]
function BinaryHeap.new(list,comparefunc)
	local obj = {}
	setmetatable(obj,BinaryHeap)
	obj:init(list,comparefunc)
	return obj
end
--[[
*	初始化方法
*	@param list 数据列表
*	@param comparefunc 比较函数
]]
function BinaryHeap:init(list,comparefunc)
	self.m_tree = {}
	--数据索引表
	self.m_invTree = {}
	self.m_len = 0
	self.m_compare = comparefunc
	self:m_sort(list)
end
function BinaryHeap:getIndex(index)
	return self.m_tree[index]
end
--[[
*	向二叉数组插入元素
*	##	一般不需要单独调用
*	@param data:元素
*	@return 下标
]]
function BinaryHeap:insert(data)
	self.m_tree[self.m_len] = data
	self.m_invTree[data] = self.m_len
	
	self.m_len = self.m_len + 1
	--m_len == 1 表示根节点
	if self.m_len == 1 then return end
	--向上修正所有节点
	self:m_reorderUpwardsByIndex(self.m_len - 1)
end
function BinaryHeap:isEmpty()
	return self.m_len < 1
end
--[[
*	弹出二叉堆 堆顶数据
*	@return data 数据
]]
function BinaryHeap:pop()
	if self.m_len == 0 then return end
	self.m_len = self.m_len - 1
	local data,modifydata,index = self.m_tree[0]
	if self.m_len ~= 0 then
		
		self.m_tree[0] = self.m_tree[self.m_len]
		self.m_tree[self.m_len] = nil
		self.m_invTree[data] = nil
		--从堆顶节点向下修正所有叶子节点
		self:m_reorderDownwardsByIndex(0)
	end
	return data
end
--向上修正节点
function BinaryHeap:reorderUpwards(data)
	if not self.m_invTree[data] then return end
	self:m_reorderUpwardsByIndex(self.m_invTree[data])
end
--想下修正节点
function BinaryHeap:reorderDownwards(data)
	if not self.m_invTree[data] then return end
	self:m_reorderDownwardsByIndex(self.m_invTree[data])
end
function BinaryHeap:toString()
	local str = ""
	for i = 0,self.m_len - 1 do
		str = string.format("%s , %s",str,self.m_tree[i] or "nil")
	end
	return str
end
--[[
*	private  初始化二叉堆
*	@param list 数据列表
]]
function BinaryHeap:m_sort(list)
	if not list then return end
	for i = 1,#list do
		self:insert(list[i])
	end
end
--[[
*	private 向上修正节点
*	@param index:指定开始位置
]]
function BinaryHeap:m_reorderUpwardsByIndex(index)
	local parentIndex = math.floor((index - 1)/2)
	local m_compare,m_tree = self.m_compare,self.m_tree
	local leaf,parent = m_tree[index],m_tree[parentIndex]
	while parent do
		if not m_compare(leaf,parent) then
			break
		end
		--交换位置
		m_tree[parentIndex] = leaf
		self.m_invTree[leaf] = parentIndex
		m_tree[index] = parent
		self.m_invTree[parent] = index
		--计算新的父节点位置和父对象
		index = parentIndex
		parentIndex = math.floor((index - 1)/2)
		parent = m_tree[parentIndex]
	end
end
--[[
*   private 向下修正节点
*   @param index:指定开始位置
]]
function BinaryHeap:m_reorderDownwardsByIndex(index)
	local leftIndex,rightIndex
	local m_compare,m_tree = self.m_compare,self.m_tree
	local current,left,right = m_tree[index]
	while true do
		leftIndex,rightIndex = index*2 + 1,index*2 + 2
		left,right = m_tree[leftIndex],m_tree[rightIndex]
		--如果有右节点，且右节点和左节点 比较返回true
		if right and m_compare(right,left) then
			if m_compare(current,right) then
				--满足比较函数结束
				break
			end
			--交换
			m_tree[rightIndex] = current
			self.m_invTree[current] = rightIndex
			m_tree[index] = right
			self.m_invTree[right] = index
			
			index = rightIndex
		elseif left and not m_compare(current,left) then
			--交换
			m_tree[leftIndex] = current
			self.m_invTree[current] = leftIndex
			m_tree[index] = left
			self.m_invTree[left] = index
			
			index = leftIndex
		else
			break
		end
	end
end
return BinaryHeap