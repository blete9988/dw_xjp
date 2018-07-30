--[[--
 * 鞭炮数据
 * @author GWJ
 * 
]]

local FirecrackerContentData = class("FirecrackerContentData")

local COLUMN_COUNT=5
local LINE_COUNT=3
local MAX_TYPE=13
function FirecrackerContentData:ctor()
	self.bonus_cloums = {}	--出现免费将元素的坐标
	self.normal_win_array = {}	--非大奖的坐标
	self.windatas = {}
	self.isbig = false
	self.isFull = false
	self.totalFreeWinMoney = 0
end

function FirecrackerContentData:simulateGameData(datas)
	self.windatas = datas 	--中奖信息
	local variable = false	--是否使用过通用元素
	local ishaveTop = false
	for c=1,COLUMN_COUNT do
		self.resultdata[c]={}
		for l=1,LINE_COUNT do
			table.insert(self.resultdata[c],-1)
		end
	end
	local isGoddess = false
	--变化的SID
	local chageSid = -1
	local chageIndex = 0
	--先把得奖的放进去
	for a=1,#datas do
		local data = datas[a]
		if data.sid ~= 13 then
			for b=1,data.number do
				local resutlinfo = self.resultdata[b]
				local baseIndex = {}
				for c=1,#resutlinfo do
					if resutlinfo[c]<0 then
						table.insert(baseIndex,c)
					end
				end
				if not variable and Command.probability(5) then	--可以随机一个通用元素
					local ranomY = baseIndex[Command.random(#baseIndex)]
					resutlinfo[ranomY] = 12
					variable = true
					chageSid = data.sid
					chageIndex = b
					table.insert(self.normal_win_array,{b,ranomY})
				else
					local ranomY = baseIndex[Command.random(#baseIndex)]
					resutlinfo[ranomY] = data.sid
					table.insert(self.normal_win_array,{b,ranomY})
				end
			end
		else  	--大奖不用按照顺序放
			ishaveTop = true
			self.isbig = true
			local temp=Command.getRandomNumber(COLUMN_COUNT)
			for b=1,data.number do
				local resutlinfo=self.resultdata[temp[b]]
				local baseIndex={}
				for c=1,#resutlinfo do
					if resutlinfo[c]<0 then
						table.insert(baseIndex,c)
					end
				end
				resutlinfo[baseIndex[Command.random(#baseIndex)]] = data.sid
			end
		end
	end

	local function randomElement(excludeDatas)
		local basedatas={}
		for i=1,MAX_TYPE do
			local ishave=false
			if i==12 then	--通用元素和大奖不能随机
				ishave=true
			elseif i==13 then
				ishave=true
			else
				for k,v in pairs(excludeDatas) do
					if k==i then 
						ishave=true
						break
					end
				end
			end
			if not ishave then
				table.insert(basedatas,i)
			end
		end
		local result = nil
		if not ishaveTop and Command.probability(3) then
			result = 13
			ishaveTop = true
		else
			result = basedatas[Command.random(#basedatas)]
		end
		return result
	end

	--填充其他元素
	for a=1,#self.resultdata do
		local resutlinfo=self.resultdata[a]
		local exclude={}	--排除的元素集合
		if chageSid>0 then
			-- if a==chageIndex+1 or a==chageIndex-1 then
				exclude[chageSid]=true
			-- end
		end
		if a>1 then	--左边出现一个的元素排除
			for d=a-1,a do
				local ry=self.resultdata[d]
				for e=1,#ry do
					if ry[e]==10 or ry[e]==11 then
						exclude[ry[e]]=true
					end
				end
			end
		end

		if a>2 then		--左边连续出现两个的元素排除
			local countList={0,0,0,0,0,0,0,0,0,0,0,0,0}	--保存的数量
			for d=a-2,a do
				local ry=self.resultdata[d]
				for e=1,#ry do
					if ry[e]>0 then
						countList[ry[e]]=countList[ry[e]]+1
					end
				end
			end
			for f=1,#countList do 
				if countList[f]>=2 then
					exclude[f]=true
				end
			end
		end

		for b=1,#resutlinfo do
			if resutlinfo[b]<0 then
				for c=1,#resutlinfo do		--把同列的排除
					if resutlinfo[c]>0 then
						exclude[resutlinfo[c]]=true
					end
				end
				resutlinfo[b]=randomElement(exclude)
			end
		end
	end
	self:initBonusCloums()
end

function FirecrackerContentData:initBonusCloums()
	for x = 1,COLUMN_COUNT do
		local bounus_y = 0
		for y = 1,LINE_COUNT do
			if self.resultdata[x][y] == 13 and bounus_y == 0 then
				bounus_y = y
			end
			print("xy-------------------------------------",x,y,self.resultdata[x][y])
		end
		if bounus_y > 0 then
			table.insert(self.bonus_cloums,{x,bounus_y})
		end
	end
end

function FirecrackerContentData:getHasBonusByCloum(cloum)
	local count = 0
	for i=1,#self.bonus_cloums do
		if self.bonus_cloums[i][1] < cloum then
			count = count + 1
		end
	end
	return count
end

function FirecrackerContentData:byteRead(data)
	print("FirecrackerContentData byteRead---------------------------------------------")
	self.resultdata={}
	self.isFull = data:readBoolean()
	print("self.isFull-----------------------------",self.isFull)
	if not self.isFull then
		local playmoney = data:readLong()
		Player.setGold(playmoney,true)
		print("playmoney------------------",playmoney)
		self.winMoney = data:readLong()
		print("winMoney-------------------",self.winMoney)
		self.freeNum = data:readShort()
		print("freeNum-------------------",self.freeNum)
		local resultList = {}
		local length = data:readUnsignedByte()
		print("length-------------------",length)
		for i=1,length do
			local resultdata = {}
			resultdata.sid = data:readShort()	--元素SID
			print("resultdata.sid-----------"..resultdata.sid)
			resultdata.number = data:readByte()	--中奖数量
			print("resultdata.number-----------"..resultdata.number)
			table.insert(resultList,resultdata)
		end
		--测试
		-- local resultdata = {}
		-- resultdata.sid = 13
		-- resultdata.number = 3
		-- resultList[1] = resultdata
		-- table.insert(resultList,resultdata)

		self:simulateGameData(resultList)
		self.multiples = data:readUnsignedByte()
		self.totalFreeWinMoney = data:readLong()
	else
		local fullSid = data:readShort()
		print("fullSid-------------------------",fullSid)
		for c=1,COLUMN_COUNT do
			self.resultdata[c]={}
			for l=1,LINE_COUNT do
				table.insert(self.resultdata[c],fullSid)
			end
		end
		local playmoney = data:readLong()
		Player.setGold(playmoney,true)
		self.winMoney = data:readLong()
		self.freeNum = data:readShort()
	end	
end

return FirecrackerContentData