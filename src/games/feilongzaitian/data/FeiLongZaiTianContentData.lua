--[[--
 * 飞龙在天数据
 * @author GWJ
 * 
]]

local FeiLongZaiTianContentData = class("FeiLongZaiTianContentData")
local COLUMN_COUNT = 5
local LINE_COUNT = 4
local MAX_TYPE = 11

local element_model = require("src.games.feilongzaitian.data.FeiLongZaiTian_element_data")
local line_model = require("src.games.feilongzaitian.data.FeiLongZaiTian_line_data")
-- datas
function FeiLongZaiTianContentData:ctor(isfree)
	self.element_datas = {}	--元素集合
	self.line_datas = {}	--连线集合
	self.bonus_cloums = {}	--出现免费将元素的行数
	self.isBlowAction = false --是否有打爆动作
	self.isfree = isfree      --是否免费状态
	self.dragon_ball = 0	  --龙珠数量
	self.winMoney = 0 			--赢的具体数值
	self.winallMultipe = 0			--赢的总倍数
	self.isHasFree = false		--是否有免费
	self.freeMaxCount = 0		--总的免费次数
	self.surplusFreeCount = 0	--剩余免费次数
	self.addFreeCount = 0		--增加的免费次数
	self.useFreeCount = 0 		--已经使用的免费次数
end

function FeiLongZaiTianContentData:byteRead(data)
	for x=1,5 do
		local list = {}
		local bounus_y = 0
		for y=1,4 do
			local element_id = data:readUnsignedByte()
			local element_data = element_model.new(element_id)
			table.insert(list,element_data)
			print("xy---------------",x,y,element_id)
			if element_id == 11 and bounus_y == 0 then
				bounus_y = y
			end
		end
		if bounus_y > 0 then
			table.insert(self.bonus_cloums,{x,bounus_y})
		end
		table.insert(self.element_datas,list)
	end
	local line_length = data:readUnsignedByte()
	print("line_length---------------------",line_length)
	for i=1,line_length do
		local line_id = data:readUnsignedByte()
		local line_count = data:readUnsignedByte()
		local multple = data:readShort()
		print("line_id----------------------",line_id)
		print("multple----------------------",multple)
		print("line_count----------------------",line_count)
		local line_data = line_model.new(line_id,line_count,multple)
		table.insert(self.line_datas,line_data)
		self.winallMultipe = self.winallMultipe + multple
	end
	self.isHasFree = data:readBoolean()			--是否有免费
	print("isHasFree---------------------",self.isHasFree)
	self.addFreeCount = data:readUnsignedByte()	--这次添加免费次数
	self.surplusFreeCount = data:readUnsignedByte()	--还有多少次免费次数
	self.useFreeCount = data:readUnsignedByte()	--已经使用的免费次数
	self.dragon_ball = data:readUnsignedByte()	--龙珠数量
	print("self.dragon_ball-----------------",self.dragon_ball)
	self.winMoney	= data:readLong()
	self.playMoney = data:readLong()
	self.totalFreeWinMoney = data:readLong()
	print("totalFreeWinMoney----------------------",self.totalFreeWinMoney)
	Player.setGold(self.playMoney,true)
end

function FeiLongZaiTianContentData:getHasBonusByCloum(cloum)
	local count = 0
	for i=1,#self.bonus_cloums do
		if self.bonus_cloums[i][1] < cloum then
			count = count + 1
		end
	end
	return count
end

function FeiLongZaiTianContentData:getSoundName()
	local soundName = nil
	for i=1,#self.line_datas do
		local line_data = self.line_datas[i]
		for x=1,line_data.count do
			local element_id = self.element_datas[x][line_data.locations[x]]:getId()
			if element_id == 9 or element_id == 10 or element_id == 12 then
				soundName = "flzt_scoring_01"
			end
		end
	end
	if not soundName then
		soundName = "flzt_scoring_02"
	end
	return soundName
end


function FeiLongZaiTianContentData:getMayBeLineColumn()
	local maybeLine_array = {}
	local line_config = require("src.games.feilongzaitian.data.FeiLongZaiTian_line_config")
	for i=1,#line_config do
		local locations = line_config[i].locations
		if self.element_datas[1][locations[1]]:getId() == 12 or self.element_datas[2][locations[2]]:getId() == 12 or self.element_datas[1][locations[1]]:getId() == self.element_datas[2][locations[2]]:getId() then
			table.insert(maybeLine_array,line_config[i])
		end
	end
	return maybeLine_array
end

return FeiLongZaiTianContentData