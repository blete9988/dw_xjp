--[[
*	通比牛牛 摊牌请求
*	端口号：1209
]]
local Tbnn_ShowdownConnect = class("Tbnn_ShowdownConnect",BaseConnect)
Tbnn_ShowdownConnect.port = Port.PORT_TBNN
Tbnn_ShowdownConnect.type = 4

function Tbnn_ShowdownConnect:ctor(callback)
	self.callback = callback
end
function Tbnn_ShowdownConnect:writeData(data)
	
end

function Tbnn_ShowdownConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
	else
--		require("src.games.tongbiniuniu.data.Tbnn_GameMgr").getInstance():getMineInfo():setShowdownStatus(ST.TYPE_GAMETBNN_SHOWDOWN)
	end
	self.params = result
end

return Tbnn_ShowdownConnect