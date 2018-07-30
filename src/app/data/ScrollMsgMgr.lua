--[[
*	跑马灯管理器
*	@author lqh
]]

local ScrollMsgMgr = class("ScrollMsgMgr")

function ScrollMsgMgr:ctor()
	self.msgList = {}
end
--获取跑马灯列表
function ScrollMsgMgr:getMsgList()
	return table.merge({},self.msgList)
end
--移除一条缓存
function ScrollMsgMgr:removeMsg(message)	
	for i = 1,#self.msgList do
		if self.msgList[i] == message then
			table.remove(self.msgList,i)
			break
		end
	end
end
function ScrollMsgMgr:test()
	self.msgList = {}
	for i = 1,100 do
		self.msgList[i] = {
			txt = "<img src='p_ui_level_10.png' imgtype='1'> 我是大哥在<span color='ec845c'>王尼玛捕鱼</span>中，一炮击杀大白鲨赢得 <span name='main_font_nmb_3.png' width='21' height='31' startchar='0' path='res/fonts/'>1000</span><img src='p_ui_1083.png' imgtype='1'>",
			type = 1,
		}
	end
end
--清除
function ScrollMsgMgr:clear()
	self.msgList = {}
end
--详细序列化
function ScrollMsgMgr:bytesRead(data)
	local len = data:readByte()
	local list = {}
	local tempobj,temptxt
	for i = 1,len do
		temptxt = data:readString()
		local _,splitEndIndex = temptxt:find("&")
		tempobj = {
			txt = temptxt:sub(splitEndIndex + 1),
			type = tonum(temptxt:sub(1,splitEndIndex - 1))
		}
		table.insert(self.msgList,tempobj)
		list[i] = tempobj
	end
	CommandCenter:sendEvent(ST.COMMAND_GAME_SCROLL_MSG,list)
	return self
end

return ScrollMsgMgr