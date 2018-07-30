--[[
*	玩家数据单列数据对象
*	受保护的数据对象，可以直接访问 Player的属性值，但是不能通过属性名称直接更改 属性值，只能通过方法更改玩家属性的值
*	## 列：
*		可以通过Player.diamond 获得钻石数量，但是不能通过 Player.diamond = 10 改变钻石数量
*	如果需要改变属性值，应该添加方法，通过方法内部改变属性的值
]]



--成员属性定义在这里面，可以直接引用，但不能直接修改
local ply = {
	--持久status
	status = require("src.app.data.status.Status").new(),
	--每日状态 status
	dailyStatus = require("src.app.data.status.DailyStatus").new(),
	--游戏管理
	gameMgr = require("src.app.data.game.GameMgr").new(),
	--跑马灯管理器
	msgMgr = require("src.app.data.ScrollMsgMgr").new(),
	--email管理
	emailMgr = require("src.app.data.EmailMgr").new(),
	version = "",
	username = "",
	name = "请叫我大哥",
	--头像编号
	headIndex = 1,
	--头像地址
	headpath = "res/images/icons/head/head_icon_1.png",
	id = 0,
	--加密id
	secretID = "",
	gold = 0,
	bank = 0,
	--vip等级
	level = 0,
	--访问令牌
	token = nil,
	is_agent = 0,
	open_gametype = 0,  --打开游戏类型
	open_gamesid  = 0   --打开哪一个游戏
}
function ply.setSecretID(str)
	mlog(string.format("<Player>:收到玩家加密id ， id 为  %s",str))
	ply.secretID = str
end

function ply.setGameTYpe(str)
	ply.open_gametype = str
end

function ply.setGameSid(str)
	ply.open_gamesid = str
end

--设置金币变化
function ply.updateGold(value)
	if value == 0 then return end
	ply.gold = ply.gold + value
	CommandCenter:sendEvent(ST.COMMAND_PLAYER_GOLD_UPDATE,ply.gold,true)
end
--设置金币
function ply.setGold(value,noevent)
	if value == ply.gold then return end
	ply.gold = value
	if not noevent then
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_GOLD_UPDATE,ply.gold,true)
	end
end
--金币更新
function ply.moneyBytesRead(data)
	ply.setGold(data:readLong())
	ply.bank = data:readLong()
end

--修改头像
function ply.setHead(headIndex,noevent)
	ply.headIndex = headIndex
	ply.headpath = string.format("res/images/icons/head/head_icon_%s.png",ply.headIndex)
	if not noevent then
		CommandCenter:sendEvent(ST.COMMAND_PLAYER_HEAD_UPDATE)
	end
end
--修改名字
function ply.setName(name)
	ply.name = name
	CommandCenter:sendEvent(ST.COMMAND_PLAYER_NAME_UPDATE)
end
--获取所在的房间数据并清除
function ply.getAndClearRoom()
	local room = ply.room
	ply.room = nil
	return room
end
function ply.m_reset()
	ply.msgMgr:clear()
	ply.emailMgr:clear()
	ply.gameMgr:init()
	ply.room = nil
end
--player反序列化
function ply.bytesRead(data)
	ply.m_reset()
	
	data:readInt()		--服务器时间
	
	ply.version = data:readString()
	mlog(string.format("version = %s",ply.version))
	
	ply.username = data:readString()
	mlog(string.format("Player.username = %s",ply.username))
	
	ply.id = data:readInt()
	mlog(string.format("Player.id = %s",ply.id))
	
	ply.name = data:readString()
	mlog(string.format("Player.name = %s",ply.name))
	
	ply.setHead(data:readByte(),true)
	
	ply.gold = data:readLong()
	mlog(string.format("Player.gold = %s",ply.gold))
	
	ply.bank = data:readLong()
	mlog(string.format("Player.bank = %s",ply.bank))
	
	ply.status:bytesRead(data)
	ply.dailyStatus:bytesRead(data)
	
	local roomID = data:readShort()
	if roomID > 0  then
		--表示在游戏房间中
		ply.room = require("src.app.data.game.RoomData").new():reloginBytesRead(data)
		mlog(string.format("<Player>:您任然在游戏房间中，游戏名< %s >， 房间 ID = %s",ply.room.game.name,ply.room.id))
	end
	
	ply.token = data:readString()

	mlog(string.format("登录令牌 %s",ply.token))

	ply.is_agent = data:readByte()

	mlog(string.format("是否是代理 %s",ply.is_agent))

	CommandCenter:sendEvent(ST.COMMAND_PLAYER_LOGIN)
	mlog("Player bytesRead complete!!!!!")
end

Gbv.Player = {}
setmetatable(Player,{
	__index = function(t,k) 
		if not ply[k] then error(string.format("<Player>:attempt to read undeclared variable, key = <%s>",k)) end
		return ply[k]
	end,
	__newindex = function(t,k,v)
		if ply[k] then
			error(string.format("<Player>:can not change Player property(%s) value!",k))
			return
		end
		error(string.format("<Player> attempt to write new variable ,key = <%s>",k))
	end,
	__metatable = "You cannot get the protect metatable"
})
return Player