 --[[
*	开始游戏
*	端口号：1209
]]
local ShuiGuoLaBaPlayConnect = class("ShuiGuoLaBaPlayConnect",BaseConnect)
ShuiGuoLaBaPlayConnect.port = Port.PORT_SHUIGUOLABA
ShuiGuoLaBaPlayConnect.type = 2

function ShuiGuoLaBaPlayConnect:ctor(betdatas,callback)
	self.betdatas = betdatas
	self.callback = callback
end

function ShuiGuoLaBaPlayConnect:writeData(data)
	data:writeByte(#self.betdatas)
	for i=1,#self.betdatas do
		local model = self.betdatas[i]
		data:writeInt(model.money)
		print("sid------------------",model.sid)
		print("money------------------",model.money)
		data:writeByte(model.sid)
	end
end

function ShuiGuoLaBaPlayConnect:readData(data)
	local result = data:readUnsignedByte()
	if result ~= 0 then
		self:showTips(result)
		self.params = false
	else
		local content_data = require("src.games.shuiguolaba.data.ShuiGuoLaBaContentData").new()
		content_data:byteRead(data)
		self.params = content_data
	end
	
end

return ShuiGuoLaBaPlayConnect