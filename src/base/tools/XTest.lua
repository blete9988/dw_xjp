--[[
*	碰撞测试
*	所有方法中用到的 polygon(多边形) 形参，都表示组成多边形的点的顺序列表
]]
local XTest = {__index = {}}

local calculatePolygonProjectionRange,axisSeperatePolygons

--[[
*	任意多边形与点相交判断
*	采用 射线法
*	@param polygon 	多边形(任意多边形无限制)
*	@param dot 		点
]]
function XTest.pXd(polygon,dot)
	local len,count = #polygon,0
	local p1,p2 = nil,polygon[len]
	
	for i = 1,len do
		p1 = polygon[i]
		 --非       p1p2 在同一水平线上	或者  	交点在p1p2延长线上 
		if not ((p1.y == p2.y) or (dot.y < math.min(p1.y,p2.y) or dot.y >= math.max(p1.y,p2.y))) then
			--交点的 X 坐标
			local x = (dot.y-p1.y)*(p2.x-p1.x)/(p2.y-p1.y)+p1.x
			if x > dot.x then 		--向右水平方向发射射线
				count = count + 1
			end
		end
		p2 = p1
	end
	return count%2 == 1
end
--[[
*	凸多边形与凸多边形 相交判断，效率高
*	采用 分离轴碰撞检测，该方法只适用于凸多边形的碰撞检测，凹多边形可以分成几个凸多边形计算。
*	任意一条分离轴检测成功即可证明多边形不碰撞，所以效率较高。只有当所有边的轴线都不分离两个凸多边形才证明相交
*	如果是圆与多边形，则圆只需要得到圆心到多边形最近点的线段，然后与多边形计算
*	@paran polygon1 	多边形1(凸多边形)
*	@paran polygon2 	多边形2(凸多边形)
]]
function XTest.pXp(polygon1,polygon2)
	local len1 = #polygon1
	local p1,p2 = polygon1[len1]
	--分离轴（也是边的法线）
	local separatingAxis = cc.p(0,0)
	
	for i = 1,len1 do	
		p2 = polygon1[i]
		--计算每条边的法线
		separatingAxis.x = -(p2.y - p1.y)
		separatingAxis.y = p2.x - p1.x
		if axisSeperatePolygons(separatingAxis,polygon1,polygon2) then
			return false
		end
		p1 = p2
	end
	return true
end
--[[
*	任意多边形之间的 相交判断，基于边界相交的碰撞检测
*	采用 向量叉乘特性
*	@paran polygon1 	多边形1
*	@paran polygon2 	多边形2
]]
function XTest.pXp0(polygon1,polygon2)
	local len1,len2 = #polygon1,#polygon2
	local lap,lbp
	lap = polygon1[len1]
	for i = 1,len1 do
		lbp = polygon2[len2]
		for j = 1,len2 do
			if XTest.lXl(lap,polygon1[i],lbp,polygon2[j]) then
				return true
			end
			lbp = polygon2[j]
		end
		lap = polygon1[i]
	end
	return false
end
--[[
*	点到直线的距离，并非线段，请区分直线和线段
*	@paran point	点
*	@param linestar	射线起点
*	@param line		射线（必须为单位向量）	
]]
function XTest.pTradial(point,linestar,line)
	--射线的法线
	local nline = cc.p(-line.y,line.x)
	--射线的起点与目标点 的连接 线段
	local newline = cc.p(point.x - linestar.x,point.y - linestar.y)
	--数量积 表示 newline 在 法线上的投影*法线的长度(1) ， 即是点到直线的距离
	local distance =  nline.x * newline.x + nline.y * newline.y
	return distance
end
--[[
*	线段相交测试
*	采用向量的叉乘特性进行判断
*	@param lap1,lap2 	线段a的两个端点
*	@param lbp1,lbp2	线段b的两个端点
]]
function XTest.lXl(lap1,lap2,lbp1,lbp2)
	local lax,lay = lap1.x - lap2.x , lap1.y - lap2.y 
	local lbx,lby = lbp1.x - lbp2.x , lbp1.y - lbp2.y 
	
	if (lax*(lbp1.y - lap1.y) - lay*(lbp1.x - lap1.x))*(lax*(lbp2.y - lap1.y) - lay*(lbp2.x - lap1.x)) > 0 then return false end
	if (lbx*(lap1.y - lbp1.y) - lby*(lap1.x - lbp1.x))*(lbx*(lap2.y - lbp1.y) - lby*(lap2.x - lbp1.x)) > 0 then return false end
	return true
end

--[[
*	@private static 
*	计算多边形在任意一条线上的投影范围
*	采用点乘，所以返回的范围结果是乘上了 |line| 的长度
*	@param line 	线
*	@param polygon 	任意多边形
]]
function calculatePolygonProjectionRange(line,polygon)
	local min = line.x*polygon[1].x + line.y*polygon[1].y
	local max = min
	local L
	
	for i = 2,#polygon do
		L = line.x*polygon[i].x + line.y*polygon[i].y
		if L < min then
			min = L
		elseif L > max then
			max = L
		end
	end
	return min,max
end
--[[
*	@private static 
*	测试轴线是否可以分离两个多边形
*	@param axis		轴线
*	@param polygon1	多边形1(凸多边形)
*	@param polygon2	多边形2(凸多边形)
]]
function axisSeperatePolygons(axis,polygon1,polygon2)
	local min1,max1 = calculatePolygonProjectionRange(axis,polygon1)
	local min2,max2 = calculatePolygonProjectionRange(axis,polygon2)
	if max1 > max2 then
		if min1 > max2 then return true end
	else
		if min2 > max1 then return true end
	end
	return false 
end
return XTest