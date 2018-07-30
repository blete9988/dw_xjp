--[[
*	坐标定位
*		outgap 		处于同一个父级下的显示对象(target,focus)，并定位focus
*
*		difgap		target和focus可以处于任意坐标系，并定位focus
*
*		ingap		target是focus的父级，并定位focus
*
*		difscgap	target是focus的父级，并在全屏范围中定位focus
*
*		scgap		在全屏范围内定位focus，不论focus处于哪个父级下
*	@author lqh
]]
local Coord = {}
local CalculateOutGap,CalculateInGap,CalculateScGap
--[[
*	focus相对于target 外部的任意对齐方法（target和focus处于同一坐标系内）
*	@param target		相对目标对象
*	@param focus		当前选择对象
*	@param h_op			横向操作符(C,L,R)任意组合,CC,CL,CR,LC,LL,LR,RC,RL,RR
*	@param hgap			横向间隔
*	@param v_op			纵向操作符(C,B,T)任意组合,CC,CB,CT,BC,BB,BT,TC,TB,TT
*	@param vgap			纵向间隔
*	@param isscale		是否计算缩放(默认false不计算)
]]
function Coord.outgap(target,focus,h_op,hgap,v_op,vgap,isscale--[[=false]])
	local anr 		= target:getAnchorPoint()
	local size 		= target:getContentSize()
	local px,py 	= target:getPosition()
	local f_anr 	= focus:getAnchorPoint()
	local f_size 	= focus:getContentSize()
	
	if isscale then
		size.width		= size.width * target:getScaleX()
		size.height		= size.height * target:getScaleY()
		
		f_size.width	= f_size.width * focus:getScaleX()
		f_size.height	= f_size.height * focus:getScaleY()
	end
	
	local pos = CalculateOutGap(anr,size,px,py,f_anr,f_size,h_op,hgap,v_op,vgap,"Coord.outgap")
	
	focus:setPosition(pos)
	return focus
end
--[[
*	focus相对于target 内部的任意对齐方法（focus处于target坐标系内）
*	@param target		相对目标对象
*	@param focus		当前选择对象
*	@param h_op			横向操作符(C,L,R)任意组合,CC,CL,CR,LC,LL,LR,RC,RL,RR
*	@param hgap			横向间隔,绝对值小于1，表示百分比
*	@param v_op			纵向操作符(C,B,T)任意组合,CC,CB,CT,BC,BB,BT,TC,TB,TT
*	@param vgap			纵向间隔,绝对值小于1，表示百分比
*	@param isscale		是否计算缩放(默认false不计算)
]]
function Coord.ingap(target,focus,h_op,hgap,v_op,vgap,isscale--[[=false]])
	local size 		= target:getContentSize()
	local f_anr 	= focus:getAnchorPoint()
	local f_size 	= focus:getContentSize()
	
	if isscale then
		f_size.width	= f_size.width * focus:getScaleX()
		f_size.height	= f_size.height * focus:getScaleY()
	end
	
	local pos = CalculateInGap(size,f_anr,f_size,h_op,hgap,v_op,vgap,"Coord.ingap")
	
	focus:setPosition(pos)
	return focus
end
local scsize = cc.size(D_SIZE.w,D_SIZE.h)
--[[
*	focus相对于屏幕  的齐任意对齐方法
*	@param focus		当前选择对象
*	@param h_op			横向操作符(C,L,R)任意组合,CC,CL,CR,LC,LL,LR,RC,RL,RR
*	@param hgap			横向间隔,绝对值小于1，表示百分比
*	@param v_op			纵向操作符(C,B,T)任意组合,CC,CB,CT,BC,BB,BT,TC,TB,TT
*	@param vgap			纵向间隔,绝对值小于1，表示百分比
*	@param isscale		是否计算缩放(默认false不计算)
]]
function Coord.scgap(focus,h_op,hgap,v_op,vgap,isscale--[[=false]])
	local size 		= scsize
	local f_anr 	= focus:getAnchorPoint()
	local f_size 	= focus:getContentSize()
	
	if isscale then
		f_size.width	= f_size.width * focus:getScaleX()
		f_size.height	= f_size.height * focus:getScaleY()
	end
	
	local pos = CalculateScGap(size,f_anr,f_size,h_op,hgap,v_op,vgap,"Coord.scgap")
	
	focus:setPosition(pos)
	return focus
end
--[[
*	focus在focusParent中，相对于世界坐标对齐
*	@param focusParent		当前选择对象的父对象
*	@param focus			当前选择对象
*	@param h_op				横向操作符(C,L,R)任意组合,CC,CL,CR,LC,LL,LR,RC,RL,RR
*	@param hgap				横向间隔
*	@param v_op				纵向操作符(C,B,T)任意组合,CC,CB,CT,BC,BB,BT,TC,TB,TT
*	@param vgap				纵向间隔
*	@param isscale			是否计算缩放(默认false不计算)
]]
function Coord.difscgap(focusParent,focus,h_op,hgap,v_op,vgap,isscale--[[=false]])
	local size 		= scsize
	local f_anr 	= focus:getAnchorPoint()
	local f_size 	= focus:getContentSize()
	
	if isscale then
		f_size.width	= f_size.width * focus:getScaleX()
		f_size.height	= f_size.height * focus:getScaleY()
	end
	
	local pos = CalculateScGap(size,f_anr,f_size,h_op,hgap,v_op,vgap,"Coord.difscgap")
	
	focus:setPosition(focusParent:convertToNodeSpace(pos))
	
	return focus
end
--[[
*	focus相对于target 外部的对齐（target和focus可以处于任意不同坐标系）
*	@param target			相对目标对象(必须已加入坐标系)
*	@param focus			当前选择对象
*	@param focusCoordTarget	<默认不填就是在世界坐标下>focus所在坐标系对象(必须已加入坐标系)	
*	@param h_op				横向操作符(C,L,R)任意组合,CC,CL,CR,LC,LL,LR,RC,RL,RR
*	@param hgap				横向间隔
*	@param v_op				纵向操作符(C,B,T)任意组合,CC,CB,CT,BC,BB,BT,TC,TB,TT
*	@param vgap				纵向间隔
*	@param isscale			是否计算缩放(默认false不计算)
]]
function Coord.difgap(target,focus,focusCoordTarget,h_op,hgap,v_op,vgap,isscale--[[=false]])
	local anr 		= target:getAnchorPoint()
	local size 		= target:getContentSize()
	local pos 		= target:getParent():convertToWorldSpace(cc.p(target:getPosition()))
	local px,py 	= pos.x,pos.y
	
	local f_anr 	= focus:getAnchorPoint()
	local f_size 	= focus:getContentSize()
	
	if isscale then
		size.width		= size.width * target:getScaleX()
		size.height		= size.height * target:getScaleY()
		
		f_size.width	= f_size.width * focus:getScaleX()
		f_size.height	= f_size.height * focus:getScaleY()
	end
	
	pos = CalculateOutGap(anr,size,px,py,f_anr,f_size,h_op,hgap,v_op,vgap,"Coord.difgap")
	
	if focusCoordTarget then
		focus:setPosition(focusCoordTarget:convertToNodeSpace(pos))
	else
		focus:setPosition(pos)
	end
	return focus
end

--[[
*	转换坐标系，将current坐标系中的pos坐标转换到target坐标系中
*	@param current		当前pos所在坐标系
*	@param target		目标坐标系
*	@param pos			当前在 current 中的坐标
*	@param obj			显示对象，可选
]]
function Coord.transSpace(current,target,pos,obj)
	pos = current:convertToWorldSpace(pos)
	pos = target:convertToNodeSpace(pos)
	if obj then obj:setPosition(pos) end
	return pos
end
--固定到指定尺寸
function Coord.fixSize(target,width--[[ =nill]],height--[[ =nill]])
	local size = target:getContentSize()
	if width then
		target:setScaleX(width/size.width)
	else
		target:setScaleX(1)
	end
	if height then
		target:setScaleY(height/size.height)
	else
		target:setScaleY(1)
	end
	return target
end
--等比缩放
function Coord.fixSizeUniform(target,width,height)
	local size = target:getContentSize()
	local scale = width/size.width
	if size.height * scale <= height then
		target:setScale(scale)
	else
		scale = height/size.height
		target:setScale(scale)
	end
	return target
end

--外部坐标计算方法
function CalculateOutGap(anr,size,px,py,f_anr,f_size,h_op,hgap,v_op,vgap,funcname)
	local pos = cc.p(0,0)
	--计算横向
	local opchar_t = h_op:sub(1,1)
	local opchar_f = h_op:sub(2,2)
	if opchar_t == "C" then
		pos.x = px + (0.5 - anr.x) * size.width
	elseif opchar_t == "L" then
		pos.x = px + -anr.x * size.width
	elseif opchar_t == "R" then
		pos.x = px + (1 - anr.x) * size.width
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_t))
	end
	pos.x = pos.x + hgap
	if opchar_f == "C" then
		pos.x = pos.x + (f_anr.x - 0.5) * f_size.width
	elseif opchar_f == "L" then
		pos.x = pos.x + f_anr.x * f_size.width
	elseif opchar_f == "R" then
		pos.x = pos.x + (f_anr.x - 1) * f_size.width
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_f))
	end
	--计算纵向
	opchar_t = v_op:sub(1,1)
	opchar_f = v_op:sub(2,2)
	if opchar_t == "C" then
		pos.y = py + (0.5 - anr.y) * size.height
	elseif opchar_t == "B" then
		pos.y = py + -anr.y * size.height
	elseif opchar_t == "T" then
		pos.y = py + (1 - anr.y) * size.height
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_t))
	end
	pos.y = pos.y + vgap
	if opchar_f == "C" then
		pos.y = pos.y + (f_anr.y - 0.5) * f_size.height
	elseif opchar_f == "B" then
		pos.y = pos.y + f_anr.y * f_size.height
	elseif opchar_f == "T" then
		pos.y = pos.y + (f_anr.y - 1) * f_size.height
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_f))
	end
	
	return pos
end

--内部坐标计算方法
function CalculateInGap(size,f_anr,f_size,h_op,hgap,v_op,vgap,funcname)
	local pos = cc.p(0,0)
	--计算横向
	local opchar_t = h_op:sub(1,1)
	local opchar_f = h_op:sub(2,2)
	if opchar_t == "C" then
		pos.x = size.width * 0.5
	elseif opchar_t == "L" then
		pos.x = 0
	elseif opchar_t == "R" then
		pos.x = size.width
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_t))
	end
	
	if hgap > -1 and hgap < 1 then
		pos.x = pos.x + hgap*size.width
	else
		pos.x = pos.x + hgap
	end
	
	if opchar_f == "C" then
		pos.x = pos.x + (f_anr.x - 0.5) * f_size.width
	elseif opchar_f == "L" then
		pos.x = pos.x + f_anr.x * f_size.width
	elseif opchar_f == "R" then
		pos.x = pos.x + (f_anr.x - 1) * f_size.width
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_f))
	end
	
	--计算纵向
	opchar_t = v_op:sub(1,1)
	opchar_f = v_op:sub(2,2)
	if opchar_t == "C" then
		pos.y = size.height * 0.5
	elseif opchar_t == "B" then
		pos.y = 0
	elseif opchar_t == "T" then
		pos.y = size.height
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_t))
	end
	
	if vgap > -1 and vgap < 1 then
		pos.y = pos.y + vgap*size.height
	else
		pos.y = pos.y + vgap
	end
	
	if opchar_f == "C" then
		pos.y = pos.y + (f_anr.y - 0.5) * f_size.height
	elseif opchar_f == "B" then
		pos.y = pos.y + f_anr.y * f_size.height
	elseif opchar_f == "T" then
		pos.y = pos.y + (f_anr.y - 1) * f_size.height
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_f))
	end
	
	return pos
end

--全屏计算方法
function CalculateScGap(size,f_anr,f_size,h_op,hgap,v_op,vgap,funcname)
	local pos = cc.p(0,0)
	--计算横向
	local opchar_t = h_op:sub(1,1)
	local opchar_f = h_op:sub(2,2)
	if opchar_t == "C" then
		pos.x = size.width * 0.5
	elseif opchar_t == "L" then
		pos.x = 0
	elseif opchar_t == "R" then
		pos.x = size.width
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_t))
	end
	
	if hgap > -1 and hgap < 1 then
		pos.x = pos.x + hgap*size.width
	else
		pos.x = pos.x + hgap
	end
	
	if opchar_f == "C" then
		pos.x = pos.x + (f_anr.x - 0.5) * f_size.width
	elseif opchar_f == "L" then
		pos.x = pos.x + f_anr.x * f_size.width
	elseif opchar_f == "R" then
		pos.x = pos.x + (f_anr.x - 1) * f_size.width
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_f))
	end
	
	--计算纵向
	opchar_t = v_op:sub(1,1)
	opchar_f = v_op:sub(2,2)
	if opchar_t == "C" then
		pos.y = size.height * 0.5
	elseif opchar_t == "B" then
		pos.y = 0
	elseif opchar_t == "T" then
		pos.y = size.height
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_t))
	end
	
	if vgap > -1 and vgap < 1 then
		pos.y = pos.y + vgap*size.height
	else
		pos.y = pos.y + vgap
	end
	
	if opchar_f == "C" then
		pos.y = pos.y + (f_anr.y - 0.5) * f_size.height
	elseif opchar_f == "B" then
		pos.y = pos.y + f_anr.y * f_size.height
	elseif opchar_f == "T" then
		pos.y = pos.y + (f_anr.y - 1) * f_size.height
	else
		error(string.format("\\* %s *\\ operate character is error!! ---> %s",funcname,opchar_f))
	end
	
	return pos
end

Gbv.Coord = Coord

return Coord