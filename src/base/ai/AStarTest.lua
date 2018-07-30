local AStarTest = class("AStarTest",function() 
	local layout = display.newLayout()
	layout:setContentSize(cc.size(600,600))
	return layout
end)
function AStarTest:ctor()
	local map,cells,temp = {},{}
	
	local function bordersfunc(index)
		local y = math.ceil(index/60)
		local x = index - (y - 1)*60
--		print(index,x,y)
		local ls = {}
		local function insert(t,value)
			if not map[value].ispass then return end
			table.insert(t,value)
		end
		
		if y - 2 > 0 then
--			if x - 1 > 0 then
--				value = (y - 2)*60 + x - 1
--				insert(ls,(y - 2)*60 + x - 1)
--			end
--			if x + 1 <= 60 then
--				insert(ls,(y - 2)*60 + x + 1)
--			end
			insert(ls,(y - 2)*60 + x)
		end
		if x - 1 > 0 then
			insert(ls,(y - 1)*60 + x - 1)
		end
		if x + 1 <= 60 then
			insert(ls,(y - 1)*60 + x + 1)
		end
		if y < 60 then
--			if x - 1 > 0 then
--				insert(ls,y*60 + x - 1)
--			end
--			if x + 1 <= 60 then
--				insert(ls,y*60 + x + 1)
--			end
			insert(ls,y*60 + x)
		end
		return ls
	end
	local function heuristic(a,b)
--		if a.x == b.x then
--			return math.abs(a.y - b.y)
--		elseif a.y == b.y then
--			return math.abs(a.x - b.x)
--		else
--			return math.sqrt(math.pow((a.x - b.x),2) + math.pow((a.y - b.y),2))
--		end
		return math.abs((a.x - b.x))*1.1 + math.abs(a.y - b.y)*1.1
	end
	
	local size,pt,cell = cc.size(8,8),cc.p(0,0)
	local source,target
	local astar
	for i = 1,60 do
		pt.y = (i - 1)*10
		for j = 1,60 do
			temp = {x = j,y = i}
			if (i == 30 and j <= 55) or (j == 24 and i >=4 and i <=30) then
				temp.ispass = false
			else
				temp.ispass = (math.random()*10000 <= 8500)
			end
			table.insert(map,temp)
			cell = display.newLayout()
			cell:setContentSize(size)
			cell:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
			if temp.ispass then
				cell:setBackGroundColor(Color.WHITE)
			else
				cell:setBackGroundColor(Color.RED)
			end
			cell:setTouchEnabled(true)
			cell:addTouchEventListener(function(t,e) 
				if e ~= ccui.TouchEventType.ended then return end
				if not source then
					source = (t.data.y - 1)*60 + t.data.x
					t:setBackGroundColorOpacity(100)
					t:setBackGroundColor(Color.BLUE)
				else
					target = (t.data.y - 1)*60 + t.data.x
					t:setBackGroundColorOpacity(100)
					t:setBackGroundColor(Color.BLUE)
					
					astar:search(source,target)
					local searchs = astar.m_searched_map
					for k,v in pairs(searchs) do
						if k ~= source and k ~= target then
							cells[k]:setBackGroundColorOpacity(100)
							cells[k]:setBackGroundColor(Color.GREY)
						end
					end
					local path = astar:getParthToTarget()
					for m = 1,#path do
						if m ~= 1 and m ~= #path then
							cells[path[m]]:setBackGroundColorOpacity(100)
							cells[path[m]]:setBackGroundColor(Color.GREEN)
						end
					end
				end
			end)
			pt.x = (j - 1)*10
			cell:setPosition(pt)
			self:addChild(cell)
			cell.data = map[#map]
			table.insert(cells,cell)
		end
	end
	astar = require("src.base.AStar").new(map,heuristic,function() return 1 end,bordersfunc)
end
return AStarTest