--[[
*	聊天发送
*	端口号：5000
]]
local ChatConnect = class("ChatConnect",BaseConnect)
ChatConnect.port = Port.PORT_FIGHT_INIT
ChatConnect.type = 20
ChatConnect.notShowLoading = true
--过滤特殊字符串  用 string.gsub(self._world,"[%%]","#&1") 把%百分号反解出来
local function filterCharacter(str)
	local position,b,e = 1
	str = string.gsub(str,"[%%]","#&1")
	b,e = string.find(str,"<.+>",position)
	if e then
		local tempstr,value = string.gsub(string.sub(str,b+1,e-1),"[=,/,\\]","")
		if value > 0 then
			local temp
			temp = string.sub(str,1,b) 
			temp = temp .. tempstr 
			temp = temp .. string.sub(str,e)
			str = temp
		end
	end
	str = string.gsub(str,"\n","")
	return str
end

function ChatConnect:ctor(text)
	self.text = filterCharacter(text)
end
function ChatConnect:writeData(data)
	data:writeString(self.text)
end
function ChatConnect:readData(data)
	local result = data:readByte()
	if result ~= 0 then
		self:showTips(result)
	end
end

return ChatConnect