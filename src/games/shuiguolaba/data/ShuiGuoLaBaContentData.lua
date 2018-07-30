--[[--
 * 水果拉吧数据
 * @author GWJ
 * 
]]

local ShuiGuoLaBaContentData = class("ShuiGuoLaBaContentData")

-- datas
function ShuiGuoLaBaContentData:ctor()
	self.specialId = 0	--特殊奖ID
end

function ShuiGuoLaBaContentData:byteRead(data)
	self.result_indexs = {}
	local length = data:readUnsignedByte()
	for i=1,length do
		local result_index = data:readUnsignedByte() + 1
		table.insert(self.result_indexs,result_index)
		print("result_index-------------------------",result_index)
	end
	-- self.result_indexs = {3,4,5,6,7,8,9,10}	--开火车
	-- self.result_indexs = {3,4,9,14,19}	--大四喜
	-- self.result_indexs = {3,16,10,5}	--小三元
	-- self.result_indexs = {3,2,18,11}	--大三元

	local isXiaoSan = data:readBoolean()
	local isDaSan = data:readBoolean()
	local isDaSi = data:readBoolean()
	if length == 8 then
		self.specialId = 4
	elseif isDaSi then
		self.specialId = 2
	elseif isDaSan then
		self.specialId = 3
	elseif isXiaoSan then
		self.specialId = 5
	else
		self.specialId = 0
	end
	-- self.specialId = 5
	print("self.specialId-----------------------",self.specialId)
	self.winMoney = data:readLong()
	print("winMoney---------------------------",self.winMoney)
	local playerMoney = data:readLong()
	print("playerMoney---------------------------",playerMoney)
	Player.setGold(playerMoney,true)
	print("playerGold---------------------------",Player.gold)
end

return ShuiGuoLaBaContentData