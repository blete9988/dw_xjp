--[[
*	每日状态
*	@author lqh
]]
local DailyStatus = class("DailyStatus")
function DailyStatus:ctor()
	self.m_status = {}
end
--[[
*	获取每日状态值
*	@param key:key
*	@param default:如果key不存在则返回default(默认为0)
]]
function DailyStatus:getStatus(key,default--[[=0]])
	if not self.m_status[key] then
		return default or 0
	end
	return self.m_status[key]
end
function DailyStatus:setStatus(key,value)
	if key == nil or value == nil then mlog(DEBUG_S,string.format("attamp to set key:%s ,value:%s to DailyStatus",key,value)) return end
	self.m_status[key] = value
	CommandCenter:sendEvent(ST.COMMAND_PLAYER_DAILYSTATUS_UPDATE,key)
end
function DailyStatus:bytesReadUpdate(data)
	local len = data:readShort()
	len = len * 0.5
	local key,value
	for i = 1,len do
		key = data:readShort()
		value = data:readInt()
		self.m_status[key] = value
		--异步派发
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_DAILYSTATUS_UPDATE,key,true,0)
	end
end
function DailyStatus:bytesRead(data)
	self.m_status = {}
	local len = data:readShort()
	len = len * 0.5
	for i = 1,len do
		self.m_status[data:readShort()] = data:readInt()
	end
end

return DailyStatus