--[[--
 * 一拳超人数据
 * @author GWJ
 * 
]]

local FistsupermanContentData = class("FistsupermanContentData")
local COLUMN_COUNT = 5
local LINE_COUNT = 4
local MAX_TYPE = 11

local element_model = require("src.games.fistsuperman.data.Fistsuperman_element_data")
local line_model = require("src.games.fistsuperman.data.Fistsuperman_line_data")
-- datas
function FistsupermanContentData:ctor(isfree)
	self.element_datas = {}	--元素集合
	self.line_datas = {}	--连线集合
	self.maybeBlowCloums = {}	--可能出现拳头的列数
	self.bonus_cloums = {}	--出现免费将元素的行数
	self.isBlowAction = false --是否有打爆动作
	self.isfree = isfree      --是否免费状态
	self.freeMultiple = 0	  --免费的额外倍数
	self.winMoney = 0 			--赢的具体数值
	self.winallMultipe = 0			--赢的总倍数
	self.isHasFree = false		--是否有免费
	self.freeMaxCount = 0		--总的免费次数
	self.surplusFreeCount = 0	--剩余免费次数
	self.addFreeCount = 0		--增加的免费次数
	self.useFreeCount = 0 		--已经使用的免费次数
	self.mostLineMultiple = 0	--得奖线条最大倍数
	-- for i=1,5 do
	-- 	local list = {}
	-- 	for b=1,4 do
	-- 		local element_data = element_model.new(Command.random(12))
	-- 		table.insert(list,element_data)
	-- 	end
	-- 	table.insert(self.element_datas,list)
	-- end
	-- --测试
	-- self.element_datas[1][3] = element_model.new(6)
	-- self.element_datas[2][3] = element_model.new(6)
	-- self.element_datas[3][3] = element_model.new(7)
	-- self.element_datas[4][3] = element_model.new(9)
	-- self.element_datas[5][3] = element_model.new(12)

	-- self.element_datas[1][4] = element_model.new(8)
	-- self.element_datas[2][4] = element_model.new(8)
	-- self.element_datas[4][2] = element_model.new(8)
	-- self.element_datas[5][1] = element_model.new(8)

	-- self.element_datas[1][1] = element_model.new(11)
	-- self.element_datas[2][2] = element_model.new(11)
	-- self.element_datas[3][3] = element_model.new(11)
	-- self.bonus_cloums = {1,2,3}
end

function FistsupermanContentData:blowLineAnalysis()
	-- local winLineCount = Command.random(3)
	-- winLineCount = 2
	-- for i=1,winLineCount do
		-- local line_data = line_model.new(Command.random(50),math.random(3,5),Command.random(300))
		-- local line_data = nil
		-- if i == 1 then
		-- 	line_data = line_model.new(1,5,300)
		-- else
		-- 	line_data = line_model.new(7,5,200)
		-- end
		-- table.insert(self.line_datas,line_data)
		for i=1,#self.line_datas do
		local line_data = self.line_datas[i]
		if not self.isfree then
			--普通状态下,打爆情况需要最后一列是拳头
			if self.element_datas[COLUMN_COUNT][line_data.locations[COLUMN_COUNT]].isblow then
				local ismonster = true
				for b=1,#line_data.locations do
					if not self.element_datas[b][line_data.locations[b]].ismonster then
						ismonster = false
						break
					end
				end
				if ismonster then
					self.isBlowAction = true
					for b=1,#line_data.locations do
						self.element_datas[b][line_data.locations[b]]:setBlowState(true)
					end
					line_data:setBlowState(true)
				end
			end
		else
			--免费状态下,打爆情况需要第三列是拳头
			if self.element_datas[3][line_data.locations[3]].isblow then
				local ismonster = 0
				for b=1,#line_data.locations do
					if self.element_datas[b][line_data.locations[b]].ismonster then
						ismonster = ismonster + 1
					else
						if b < 4 then
							ismonster = 0
							break
						end
					end
				end
				if ismonster >= 3 then
					self.isBlowAction = true
					for b=1,ismonster do
						self.element_datas[b][line_data.locations[b]]:setBlowState(true)
					end
					line_data:setBlowState(true)
				end
			end
		end
	end
end

function FistsupermanContentData:maybeBlowLineColumn()
	local line_config = require("src.games.fistsuperman.data.Fistsuperman_line_config")
	for i=1,#line_config do
		local locations = line_config[i].locations
		local length = #locations - 1   --前4个
		local isMayBeBlow = true
		for b=1,length do
			if not self.element_datas[b][locations[b]].ismonster then
				isMayBeBlow = false
				break
			end
		end
		if isMayBeBlow then
			table.insert(self.maybeBlowCloums,locations[#locations])
		end
	end
end

function FistsupermanContentData:byteRead(data)
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

	--测试
	-- self.element_datas[1][1] = element_model.new(7)
	-- self.element_datas[2][1] = element_model.new(8)
	-- self.element_datas[3][2] = element_model.new(12)
	-- self.element_datas[4][3] = element_model.new(1)
	-- self.element_datas[5][4] = element_model.new(2)

	local line_length = data:readUnsignedByte()
	print("line_length---------------------",line_length)
	for i=1,line_length do
		local line_id = data:readUnsignedByte()
		local line_count = data:readUnsignedByte()
		local multple = data:readShort()
		if multple > self.mostLineMultiple then
			self.mostLineMultiple = multple
		end
		print("line_id----------------------",line_id)
		print("multple----------------------",multple)
		print("line_count----------------------",line_count)
		local line_data = line_model.new(line_id,line_count,multple)
		table.insert(self.line_datas,line_data)
		self.winallMultipe = self.winallMultipe + multple
	end
		-- 测试
		-- local line_id = 8
		-- local line_count = 3
		-- local multple = 10
		-- local line_data = line_model.new(line_id,line_count,multple)
		-- table.insert(self.line_datas,line_data)

	self.isHasFree = data:readBoolean()			--是否有免费
	print("isHasFree---------------------",self.isHasFree)
	self.addFreeCount = data:readUnsignedByte()	--这次添加免费次数
	self.surplusFreeCount = data:readUnsignedByte()	--还有多少次免费次数
	self.useFreeCount = data:readUnsignedByte()	--已经使用的免费次数
	self.freeMultiple = data:readUnsignedByte()
	self.winMoney	= data:readLong()
	self.playMoney = data:readLong()
	self.totalFreeWinMoney = data:readLong()
	print("totalFreeWinMoney----------------------",self.totalFreeWinMoney)
	Player.setGold(self.playMoney,true)
	print("self.playMoney------------------------",self.playMoney)
	self:blowLineAnalysis()
	if not self.isfree then
		self:maybeBlowLineColumn()
	end
end

function FistsupermanContentData:getHasBonusByCloum(cloum)
	local count = 0
	for i=1,#self.bonus_cloums do
		if self.bonus_cloums[i][1] < cloum then
			count = count + 1
		end
	end
	return count
end

function FistsupermanContentData:getMayBeLineColumn()
	local maybeLine_array = {}
	local line_config = require("src.games.fistsuperman.data.Fistsuperman_line_config")
	for i=1,#line_config do
		local locations = line_config[i].locations
		if self.element_datas[1][locations[1]]:getId() == 10 or self.element_datas[2][locations[2]]:getId() == 10 or self.element_datas[1][locations[1]]:getId() == self.element_datas[2][locations[2]]:getId() then
			table.insert(maybeLine_array,line_config[i])
		end
	end
	return maybeLine_array
end

return FistsupermanContentData