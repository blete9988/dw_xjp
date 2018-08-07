--[[
*	通用推送端口
* 
*	@author：lqh
]]
local JbackPort = {}
function JbackPort.extend(data)
	local player = Player
	local handler = function(data)
		local tp = data:readUnsignedShort()
		mlog(string.format("<JbackPort> receive JBack message , type = %s",tp))
		if tp == 1000 then
			--金币更新
			player.moneyBytesRead(data)
		elseif tp == 1004 then
			--每日状态更新
			player.dailyStatus:bytesReadUpdate(data)
		elseif tp == 1007 then
			--持久状态更新
			player.status:bytesReadUpdate(data)
		elseif tp == 2000 then
			--跑马灯
			player.msgMgr:bytesRead(data)
		elseif tp == 1001 then
			--跑马灯
			-- player.msgMgr:bytesRead(data)
			display.showMsg("账号异常登录！")
		end
	end
	return handler
end
return JbackPort
