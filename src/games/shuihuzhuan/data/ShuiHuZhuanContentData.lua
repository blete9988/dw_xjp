--[[--
 * 水浒传数据
 * @author GWJ
 * 
]]

local ShuiHuZhuanContentData = class("ShuiHuZhuanContentData")
local COLUMN_COUNT = 5
local LINE_COUNT = 3
local MAX_TYPE = 9

local element_model = require("src.games.shuihuzhuan.data.ShuiHuZhuan_element_data")
local line_model = require("src.games.shuihuzhuan.data.ShuiHuZhuan_line_data")
-- datas
function ShuiHuZhuanContentData:ctor()
	self.element_datas = {}	--元素集合
	self.line_datas = {}	--连线集合
	self.winMoney = 0 	--赢的具体数值
	self.fullSid = 0	--全屏大奖
	-- for x=1,COLUMN_COUNT do
	-- 	local list = {}
	-- 	for y=1,LINE_COUNT do
	-- 		local element_id = Command.random(MAX_TYPE)
	-- 		-- local element_data = element_model.new(element_id)
	-- 		table.insert(list,element_id)
	-- 		print("xy-------------------",x,y,element_id)
	-- 	end
	-- 	table.insert(self.element_datas,list)
	-- end
	-- --测试
	-- self.element_datas[1][2] = 8
	-- self.element_datas[2][2] = 8
	-- self.element_datas[3][2] = 8
	-- self.element_datas[4][2] = 8
	-- self.element_datas[5][2] = 8

	-- self.element_datas[1][3] = 8
	-- self.element_datas[2][2] = 8
	-- self.element_datas[3][1] = 8
	-- self.element_datas[4][2] = 8
	-- self.element_datas[5][3] = 8

	-- local line_data = line_model.new(1,5,50,1)
	-- table.insert(self.line_datas,line_data)
	-- line_data = line_model.new(4,5,50,1)
	-- table.insert(self.line_datas,line_data)

	-- self.element_datas[1][4] = element_model.new(8)
	-- self.element_datas[2][4] = element_model.new(8)
	-- self.element_datas[4][2] = element_model.new(8)
	-- self.element_datas[5][1] = element_model.new(8)

	-- self.element_datas[1][1] = element_model.new(11)
	-- self.element_datas[2][2] = element_model.new(11)
	-- self.element_datas[3][3] = element_model.new(11)
	-- self.bonus_cloums = {1,2,3}
end

function ShuiHuZhuanContentData:byteRead(data)
	local fullSid = data:readUnsignedByte()
	self.fullSid = fullSid
	if fullSid == 0 then
		for x=1,COLUMN_COUNT do
			local list = {}
			for y=1,LINE_COUNT do
				local element_id = data:readUnsignedByte()
				table.insert(list,element_id)
				print("xy---------------",x,y,element_id)
			end
			table.insert(self.element_datas,list)
		end
		local line_length = data:readUnsignedByte()
		print("line_length---------------------",line_length)
		for i=1,line_length do
			local line_id = data:readUnsignedByte()
			local line_count = data:readUnsignedByte()
			local multple = data:readShort()
			local direction = data:readUnsignedByte()
			print("line_id----------------------",line_id)
			print("multple----------------------",multple)
			print("line_count----------------------",line_count)
			print("direction----------------------",direction)
			local line_data = line_model.new(line_id,line_count,multple,direction)
			table.insert(self.line_datas,line_data)
		end
	else
		for x=1,COLUMN_COUNT do
			local list = {}
			for y=1,LINE_COUNT do
				table.insert(list,fullSid)
			end
			table.insert(self.element_datas,list)
		end
		print("fullsid--------------------------",fullSid)
	end
	self.winMoney = data:readLong()
	local playMoney = data:readLong()
	print("playMoney---------------------------",playMoney)
	print("winMoney---------------------------",self.winMoney)
	Player.setGold(playMoney,true)
end

return ShuiHuZhuanContentData