--[[
*	动画数字显示控件
*	@author lqh
]]
local ScrollNumberComponent = class("ScrollNumberComponent",require("src.base.extend.CCLayerExtend"),function(nmb,size,color) 
	local label = display.newText("",size or Cfg.SIZE,color or Cfg.COLOR)
	label.m_setString = label.setString
	return label
end)

function ScrollNumberComponent.extend(target)
	target.m_setString = target.setString
	setmetatableex(target,ScrollNumberComponent)
	target:ctor()
    return target
end

function ScrollNumberComponent:ctor(nmb,size,color)
	self:super("ctor")
	self.m_formatFunc = string.thousandsformat
	self.m_speed = 1
	self:setString(nmb)
end
function ScrollNumberComponent:setSpeed(value)
	self.m_speed = value or self.m_speed 
end
function ScrollNumberComponent:stopScroll()
	if not self.m_timehandler then return end
	timestop(self.m_timehandler) 
	self.m_timehandler = nil
end
function ScrollNumberComponent:setNmbFormatFunction(func)
	self.m_formatFunc = func
end
--[[
*	设置数字
*	@nmber 数字
*	@noaction 是否不播放动画
]]
function ScrollNumberComponent:setString(nmber,noaction)
	self:stopScroll()
	local value = tonum(nmber)
	if noaction then
		self.m_count = nmber
		self:m_setString(self.m_formatFunc(nmber))
		return
	end
	if not self.m_count then
		--首次直接设置
		self.m_count = value
		self:m_setString(self.m_formatFunc(value))
		return
	end
	--开始，结束值
	local stCot,edCot = self.m_count,value
	--符号
	local symbol = 1
	if stCot > edCot then symbol = -1 end
	
	self.m_count = value
	
	local atm = 0
	local v1,v2 = 0,0
	self.m_timehandler = timeup(function(tm)
		if v1 < 10 then
			stCot = stCot + 1*symbol
			v1 = v1 + 1
		else
			atm = atm + tm
			v1 = v1 + 10
			v2 = math.floor(atm*100*self.m_speed)
			stCot = stCot + 0.1*v1*v2*v2*symbol
		end
		
		if symbol > 0 then
			if stCot >= edCot then
				stCot = edCot
				self:stopScroll()
			end
		elseif stCot <= edCot then
			stCot = edCot
			self:stopScroll()
		end
		self:m_setString(self.m_formatFunc(stCot))
		self.m_count = stCot
	end)
end
function ScrollNumberComponent:onCleanup()
	self:stopScroll()
end
return ScrollNumberComponent