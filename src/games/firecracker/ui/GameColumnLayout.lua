--[[
 *	游戏一列
 *	@author gwj
]]
local GameColumnLayout = class("GameColumnLayout",function() return display.extend("CCLayerExtend",display.newLayout()) end,require("src.base.event.EventDispatch"))

--项总数
local ITEM_COUNT=0
local base_height = 0
local base_width = 0
local bottomPy = 0
local topPy = 0
local MOVE_SPEED = 50
local bottomPy = 0
local topPy = 0
local soundController = require("src.games.firecracker.data.FirecrackerSoundController").getInstance()
-- maxcount元素总类数量
function GameColumnLayout:ctor(maxcount,index)
	ITEM_COUNT=maxcount
	self.stop = false           --是否停止
	self.index = index         --当前列的索引
	self.runtime = 0           --旋转运行的时间
	self.speed = 0       --加速的时间
	self.items = {}            --项容器
	self.fist_items = {}	--拳头容器集合
	--遮罩
	local holesClipper= cc.ClippingNode:create()
	--显示切割后剩余部分
	holesClipper:setInverted(false)
	holesClipper:setAlphaThreshold(0.05)

	local m_pHolesStencil= cc.Node:create()
	m_pHolesStencil:retain()
	holesClipper:setStencil(m_pHolesStencil)
	self:addChild(holesClipper)

	--切割图片
	local holeStencil = cc.Sprite:create("game/firecracker/firecracker_mask_1.png")
	holeStencil:setAnchorPoint(cc.p(0,0))
	m_pHolesStencil:addChild(holeStencil)
	self:setContentSize(holeStencil:getContentSize())

	local action_layout = class("actionlayout",function() return display.extend("CCLayerExtend",display.newLayout()) end).new()
	self:addChild(action_layout)
	self.action_layout = action_layout

	local item_length = 6
	base_height = holeStencil:getContentSize().height / 3
	base_width = holeStencil:getContentSize().width
	bottomPy = 0 - base_height/2
	topPy = base_height * (item_length - 1) - base_height/2

	--获取当前队列数据
	self.sequence = Command.getRandomNumber(ITEM_COUNT)
	local index = -1
	--创建7个元素,底部隐藏一个,上方隐藏2个,转动的时候上方为结果数据
	local size = self:getContentSize()
	for i=1,item_length do
		local item = require("src.games.firecracker.ui.GameImage").new(self.sequence[i])
		item.index = index
		item:setPosition(cc.p(size.width/2,item.index * base_height + base_height * 0.5))
		holesClipper:addChild(item)
		table.insert(self.items,item)
		index = index + 1
	end

	self:setTouchEnabled(true)
	self:addTouchEventListener(
		function (sender,eventType)
			if eventType==ccui.TouchEventType.ended then
				self:over()
			end
		end)
	self:scheduleUpdateWithPriorityLua(function()
		self:turn()
	end,0.01)
end

function GameColumnLayout:play(datas,runtime)
	self.speed = 2
	self.nowTime = 0
	self.stop = false
	self.element_datas = datas
	self.isStart = true
	self.isSpecial = false
	self:timeOver()
	print("runtime-------------------------",runtime)
	if runtime > 0 then
		self.isManual = false
		self.runtime_action = self.action_layout:performWithDelay(function()
			self.runtime_action = nil
			self:over()
		end,runtime)
	else
		self.isManual = true
	end
end

function GameColumnLayout:showAll()
	for i=1,#self.items do
		self.items[i]:setVisible(true)
	end
end


function GameColumnLayout:hideByIndex(index)
	self.items[index+1]:setVisible(false)
end

function GameColumnLayout:timeOver()
	if self.runtime_action then
		self.action_layout:stopAction(self.runtime_action)
		self.runtime_action = nil
	end
end

--中途停止
function GameColumnLayout:stopAtOnceStop()
	-- local delay=Command.random(3)
	-- self.action_layout:performWithDelay(function()
	-- 	self:over()
	-- end, delay/10)
	self:over()
end

--结束
function GameColumnLayout:over()
	self:timeOver()
	self.stop = true
end

function GameColumnLayout:setSpecial(stopTime)
	-- SoundsManager.playSound("FS_maybeBlow")
	self:timeOver()
	self.isSpecial = true
	self:playFrame()
	self.runtime_action = self.action_layout:performWithDelay(function()
		self.runtime_action = nil
		self:over()
	end,stopTime)
end

function GameColumnLayout:specialRun()

end

function GameColumnLayout:turn()
	if not self.isStart then return end
	self.nowTime = self.nowTime+1
	if self.nowTime ~= self.speed then return end
	self.nowTime = 0
	-- if self.isSpecial then
	-- 	self:specialRun()
	-- 	return
	-- end
	if self.stop then
		self.isStart = false
		soundController:playTurnOver()
		local length = #self.items
		local temp = 0
		for i=1,length do
			local item = self.items[i]
			local py = item.index * base_height + base_height * 0.5
			item:setPositionY(py - 20)
			-- item:runAction(cc.MoveTo:create(0.2,cc.p(item:getPositionX(),py)))
			item:runAction(cc.Sequence:create({cc.MoveTo:create(0.2,cc.p(item:getPositionX(),py)),
				cc.CallFunc:create(function()
					temp = temp + 1
					if temp == #self.items then
						self:sendStopEvent()
					end
				end)}))
			if i > 1 and i < 5 then
				local data = self.element_datas[i - 1]
				self.items[i]:setdata(data)
			end
		end
		-- self:sendStopEvent()
	else
		for i=1,#self.items do
			local item=self.items[i]
			item:setPositionY(item:getPositionY() - base_height/2)
			if item:getPositionY() == (bottomPy - base_height)  then
				item:setPositionY(topPy)
			end
		end
	end
end

function GameColumnLayout:playFrame()
	self:removeFrame()
	SoundsManager.playSound("firecracker_fly")
	local effect = cc.Sprite:create()
	effect:setPosition(cc.p(self:getPositionX() + 95,self:getPositionY() + 240))
	effect:runAction(resource.getAnimateByKey("frame_st",true))
	self:getParent():addChild(effect,3)
	self.effect = effect
end

function GameColumnLayout:removeFrame()
	if self.effect then
		SoundsManager.stopAudio("firecracker_fly")
		self.effect:getParent():removeChild(self.effect,true)
		self.effect=nil
	end
end

function GameColumnLayout:sendStopEvent()
	self:removeFrame()
	self:dispatchEvent("LIST_GAME_STOP",self.index)
end

--元素改变类型
function GameColumnLayout:changeGametype(oldtype,newtype)
	for i=2,4 do
		local item=self.items[i]
		if item:getType() == oldtype then
			item:changeGametype(newtype)
			break
		end
	end
end

--根据类型获得索引
function GameColumnLayout:getIndexByType(etype)
	for i=2,4 do
		if self.items[i].data.sid == etype then
			return i-1
		end
	end
	return 0
end

--根据索引获得类型
function GameColumnLayout:getTypeByIndex(index)
	return self.items[index+1].data.sid
end

function GameColumnLayout:onEnter()
end

function GameColumnLayout:onExit()
end

return GameColumnLayout



