--[[
*	抢庄牛牛推送端口
* 
*	@author：lqh
]]
local Qznn_JbackPort = {}
function Qznn_JbackPort.extend(data)
	local player = Player
	local gamemgr = require("src.games.qiangzhuangniuniu.data.Qznn_GameMgr").getInstance()
	
	local handler = function(data)
		local tp = data:readUnsignedShort()
		mlog(string.format("<Qznn_JbackPort> receive JBack message , type = %s",tp))
		if tp == 1 then
			--有玩家加入房间
			gamemgr:playerEntryRoom(data)
		elseif tp == 2 then
			--玩家准备状态
			gamemgr:playerReadyStatusUpdate(data)
		elseif tp == 3 then
			--收到结果
			gamemgr:resultBytesRead(data)
		elseif tp == 4 then
			--发牌
			gamemgr:beganBytesRead(data)
		elseif tp == 6 then
			--有玩家退出
			gamemgr:playerLeaveRoom(data)
		elseif tp == 7 then
			--摊牌
			gamemgr:playerShowdown(data)
		elseif tp == 8 then
			--开始抢庄
			gamemgr:beganGetMasterBytesRead(data)
		elseif tp == 9 then
			--抢庄
			gamemgr:masterTimesBytesRead(data)
		elseif tp == 10 then
			--开始加倍
			gamemgr:beganAddTimesBytesRead(data)
		elseif tp == 11 then
			--加倍
			gamemgr:addTimesBytesRead(data)
		elseif tp == 12  or tp ==13 then
			--被踢出房间
			local index = data:readByte()
			local id = data:readInt()
			mlog(string.format("有玩家长时间未准备被系统踢出， 座位号 %s, id %s, 我的id %s",index,id,Player.id))
			if id == Player.id then
				display.showMsg(display.trans("##20006"))
				WindowMgr.closeAllWindow()
				gamemgr:removeQznn()
			else
				gamemgr:kickPlayer(index,id)
			end
		end
	end
	return handler
end
return Qznn_JbackPort
