--[[
*	房间 类
*	@author lqh
]]

local RoomData = class("RoomData")
-- 属性定义
RoomData.index 			= 0			--房间号
RoomData.curNmb 		= 0			--房间当前人数
RoomData.maxNmb 		= 0			--房间最大人数
RoomData.per_bets 		= 0			--房间每次下注额
RoomData.lowest_bets 	= 0			--进入房间最低赌注


function RoomData:ctor(game)
	self.game = game
	self.goldLimit = 0
end

--获取房间显示图片
function RoomData:getPic()
	return string.format("game/%s/icon/icon_room_%s.png",self.game.key,self.index)
end


--获取jackpot
function RoomData:getJackPot()
	return string.format("game/%s/icon/ui_ccjj_dt_jackpot.png",self.game.key)
end


--进入检测
function RoomData:testEntry()
	if not display.checkGold(self.goldLimit) then
		--现金不足无法进入
		mlog("无法进入该房间，因为您的现金低于房间最低要求！！！")
		return false
	else
		--可以进入
		return true
	end
end
function RoomData:bytesRead(data)
	self.id = data:readShort()			--房间id
	self.gameid = data:readShort()		--游戏id
	data:readByte()						--房间类型(游戏所属组类型)
	self.index = data:readByte()		--房间index
	self.goldLimit = data:readInt()		--进入房间最低持有金额
	self.minBets = data:readInt()		--最小底注
	self.maxNmb = data:readShort()		--最大人数限制
	self.curNmb = data:readShort()		--当前人数
	return self
end
--断线重来你后序列化
function RoomData:reloginBytesRead(data)
	self:bytesRead(data)
	self.game = Player.gameMgr:getGame(self.gameid)
	return self
end

return RoomData