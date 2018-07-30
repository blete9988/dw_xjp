--[[
*	单选按钮组
*	派发 "select" 选中事件
*	@author lqh
]]
local RadioButtonControl = class("RadioButtonControl",require("src.base.control.ButtonGroupControl"))

-- ----------------------event 事件-------------------------------------
RadioButtonControl.EVT_SELECT = "evt_select"	--按钮选中事件

function RadioButtonControl:ctor(list)
	self:super("ctor",list)
	self.m_current = nil
end
--@private override
function RadioButtonControl:m_removeButton(button)
	self:super("m_removeButton",button)
	if self.m_current == button then
		self.m_current:setTouchEnabled(true)
		self.m_current:setBrightStyle(ccui.BrightStyle.normal)
		self.m_current = nil
	end
end
--@private override
function RadioButtonControl:m_buttonHandler(t,e)
	if e == ccui.TouchEventType.ended then
		self:m_setCurrentButton(t)
	end
	
	self:super("m_buttonHandler",t,e)
end
--@private
function RadioButtonControl:m_setCurrentButton(button)
	if self.m_current then
		self.m_current:setTouchEnabled(true)
		self.m_current:setBrightStyle(ccui.BrightStyle.normal)
	end
	
	button:setTouchEnabled(false)
	button:setBrightStyle(ccui.BrightStyle.highlight)
	
	self.m_current = button	
	
	self:dispatchEvent(RadioButtonControl.EVT_SELECT,button)
end
function RadioButtonControl:cleanCurrentButton()
	if self.m_current then
		self.m_current:setTouchEnabled(true)
		self.m_current:setBrightStyle(ccui.BrightStyle.normal)
		self.m_current = nil
	end
end
function RadioButtonControl:setCurrentButton(button)
	if not button.m_id or self.m_current == button then return end
	self:m_setCurrentButton(button)
end
function RadioButtonControl:setCurrentID(id)
	if not self.m_buttonlist[id] or self.m_current.m_id == id then return end
	self:m_setCurrentButton(self.m_buttonlist[id])
end
function RadioButtonControl:getCurrentButton()
	return self.m_current
end
return RadioButtonControl