--[[
*	按钮组管理
*	@author lqh
]]
local ButtonGroupControl = class("ButtonGroupControl",require("src.base.event.EventDispatch"))
function ButtonGroupControl:ctor(list)
	self.m_id = 1
	self.m_buttonlist = {}
	self:addButtonList(list or {})
end
--@private
function ButtonGroupControl:m_addButton(button)
	button.m_id = self.m_id
	self.m_id = self.m_id + 1
	table.insert(self.m_buttonlist,button)
	
	button.m_addTouchEventListener = button.addTouchEventListener
	--@override
	button.addTouchEventListener = function(t,callback)
		t.m_callback = callback
	end
	
	button:m_addTouchEventListener(handler(self,self.m_buttonHandler)) 
end
--@private
function ButtonGroupControl:m_removeButton(button)
	button.addTouchEventListener = button.m_addTouchEventListener
	button.m_addTouchEventListener = nil
	if button.m_callback then
		button:addTouchEventListener(button.m_callback)
		button.m_callback = nil
	end
	
	table.remove(self.m_buttonlist,button.m_id)
	self.m_id = 1
	for i = 1,#self.m_buttonlist do
		self.m_buttonlist[i].m_id = self.m_id
		self.m_id = self.m_id + 1
	end
	button.m_id = nil
end
--@private
function ButtonGroupControl:m_buttonHandler(t,e)
	if not t.m_callback then return end
	t.m_callback(t,e)
end
function ButtonGroupControl:addButton(button)
	self:m_addButton(button)
end
function ButtonGroupControl:addButtonList(list)
	for i = 1,#list do
		self:m_addButton(list[i])
	end
end
function ButtonGroupControl:removeButton(button)
	if not button.m_id then return end
	self:m_removeButton(button)
end
function ButtonGroupControl:removeID(id)
	if not self.m_buttonlist[id] then return end
	self:m_removeButton(self.m_buttonlist[id])
end

function ButtonGroupControl:getButtonList()
	return self.m_buttonlist
end

return ButtonGroupControl