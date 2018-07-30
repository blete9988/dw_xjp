--[[
*	百人牛牛推送端口
* 
*	@author：lqh
]]
local Brnn_JbackPort = {}
function Brnn_JbackPort.extend(data)
	local player = Player
	local gamemgr = require("src.games.bairenniuniu.data.Brnn_GameMgr").getInstance()
	
	local handler = function(data)
		local tp = data:readUnsignedShort()
		mlog(string.format("<Brnn_JbackPort> receive JBack message , type = %s",tp))
		if tp == 1 then
			--下注开始
			gamemgr:beganBytesRead(data)
		elseif tp == 2 then
			--下注推送
			gamemgr:betBytesRead(data)
		elseif tp == 3 then
			--结果
			gamemgr:resultBytesRead(data)
		elseif tp == 4 then
			--上庄申请人数变化
			gamemgr:applyNumberBytesRead(data)
		elseif tp == 5 then
			--庄家更新
			gamemgr:masterUpdateBytesRead(data)
		elseif tp == 6 then
			gamemgr:desktopPlayersBytesRead(data)
		end
	end
	return handler
end
return Brnn_JbackPort
