--[[
*	使用示例
--绘制线段          (起点 , 终点 , 半线宽 , 填充颜色)
test:drawSegment(cc.p(100,100),cc.p(400,400),1,cc.c4f(1, 1, 1, 1))

--绘制圆点      (位置 , 圆点半径 , 填充颜色)
test:drawDot(cc.p(300,200),20,cc.c4f(1,1,1,1))

--绘制多边形        (顶点数组 , 顶点个数 , 填充颜色 , 轮廓粗细 , 轮廓颜色)
points = {cc.p(100,100),cc.p(300,100),cc.p(300,300),cc.p(100,200)}
test:drawPolygon(points, 4, cc.c4f(1,0,0,0.5), 0.1, cc.c4f(0,0,1,0))

--绘制三角形         (顶点1′ , 顶点2′ , 顶点3′ , 填充颜色)
test:drawTriangle(cc.p(150,100),cc.p(300,280),cc.p(100,180),cc.c4f(1,1,1,0.5))

--绘制二次贝塞尔图形        (起点 , 控制点 , 终点 , 分段数 , 填充颜色)
test:drawQuadraticBezier(cc.p(100,100),cc.p(200,500),cc.p(400,100),1000,cc.c4f(1,1,1,0.5))

--绘制三次贝塞尔图形    (起点 , 控制点1, 控制点2, 终点 , 分段数 , 填充颜色)
test:drawCubicBezier(cc.p(100,100),cc.p(200,500),cc.p(500,600),cc.p(800,150),1000,cc.c4f(1,1,1,0.5))
]]
local CCDrawNodeExtend = class("CCDrawNodeExtend",function() 
	return cc.DrawNode:create()
end)

function CCDrawNodeExtend.extend(target)
	target = target or cc.DrawNode:create()
    setmetatableex(target,CCDrawNodeExtend)
    return target
end
--[[
*	绘制不规则线框图
*	@param points：坐标点集合
*	@param linewidth:线宽(默认1)
*	@param color: cc.c4f值(默认cc.c4f(1,1,1,1)白色不透明)
*	@param close:是否闭合(默认不闭合)
]]
function CCDrawNodeExtend:drawWireframe(points,linewidth,color,closetype)
	if not points then return end
	local len = #points
	linewidth = linewidth or 1
	linewidth = linewidth/2
	color = color or cc.c4f(1,1,1,1)
	if len < 2 then 
		self:drawDot(points[1],linewidth,color)
		return 
	end
	for i = 2,len do
		self:drawSegment(points[i - 1],points[i],linewidth,color)
	end
	if closetype then
		self:drawSegment(points[len],points[1],linewidth,color)
	end
end

return CCDrawNodeExtend


