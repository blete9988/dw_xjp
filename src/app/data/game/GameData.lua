--[[
*	游戏 类
*	@author lqh
]]

local GameData = class("GameData", BaseConfig)
GameData.samplepath_ = "src.app.config.game_define_config"

function GameData:ctor(sid)
	self:super("ctor",sid)
	self:m_init()
	
	--开发用，默认所有游戏开启
	self:updateStatus(ST.TYPE_GAME_OPEN)
end
function GameData:m_init()
	self.m_rooms = {}
	--测试数据
	for i = 1,4 do
		self.m_rooms[i] = require("src.app.data.game.RoomData").new(self)
		self.m_rooms[i].index = i - 1
		
		self.m_rooms[i].maxNmb = math.random(100,1000)
		self.m_rooms[i].curNmb = math.ceil(self.m_rooms[i].maxNmb * math.random())
	end
end
--获取所有房间
function GameData:getRooms()
	return table.merge({},self.m_rooms)
end
--更新游戏状态
function GameData:updateStatus(value)
	self.m_openstatus = value
end
--是否开放
function GameData:isopen()
	return self.m_openstatus == ST.TYPE_GAME_OPEN
end
function GameData:setDownLoadURL(str)
	self.url = str
end
--是否已下载
function GameData:isdownload()
	if require("src.cocos.framework.device").isWindows() then
		-- return true
		local values = string.splitNumber(require("src.base.tools.storage").getXML("gamedownload_type"))
		mlog("开始遍历:values")
		for k,v in pairs(values) do
			mlog(v,":sid======")
			if v == self.sid then return true end
		end
		return false
	else
		local values = string.splitNumber(require("src.base.tools.storage").getXML("gamedownload_type"))
		for k,v in pairs(values) do
			if v == self.sid then return true end
		end
		return false
		-- return true
	end
end

function GameData:bytesRead(data)
	self.m_rooms = {}
	local len = data:readByte()
	for i = 1,len do
		self.m_rooms[i] = require("src.app.data.game.RoomData").new(self):bytesRead(data)
	end
	
	self.existUrl = data:readBoolean()
	print("gamedata self.existUrl = ",self.existUrl)
	if self.existUrl then
		self.ipaddress = data:readString()
		mlog(string.format("<GameData>:游戏服务器地址为 %s",self.ipaddress))
		self.ipaddress = "tcp://" .. self.ipaddress
	else
		self.ipaddress = "tcp://192.168.1.112:6101"
	end
		
	return self
end

return GameData