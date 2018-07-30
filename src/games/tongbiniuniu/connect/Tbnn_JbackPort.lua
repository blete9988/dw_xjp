--[[
*	通比牛牛推送端口
* 
*	@author：lqh
]]
local Tbnn_JbackPort = {}
function Tbnn_JbackPort.extend(data)
	local player = Player
	local gamemgr = require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance()
	
	local handler = function(data)
		local tp = data:readUnsignedShort()
		mlog(string.format("<Tbnn_JbackPort> receive JBack message , type = %s",tp))
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
			--彩金池更新
			gamemgr:updateAwardPool(data)
		elseif tp == 9 then
			--被踢出房间
			local index = data:readByte()
			local id = data:readInt()
			mlog(string.format("有玩家长时间未准备被系统踢出， 座位号 %s, id %s, 我的id %s",index,id,Player.id))
			if id == Player.id then
				display.showMsg(display.trans("##20006"))
				WindowMgr.closeAllWindow()
			else
				gamemgr:kickPlayer(index,id)
			end
		end
	end
	return handler
end
return Tbnn_JbackPort
