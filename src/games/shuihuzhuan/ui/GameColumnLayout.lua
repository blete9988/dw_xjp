--[[
 *	游戏一列
 *	@author gwj
]]
local GameColumnLayout = class("GameColumnLayout",function() return display.extend("CCLayerExtend",display.newLayout(cc.size(200,504))) end,require("src.base.event.EventDispatch"))

--项总数
local ITEM_COUNT = 3
local ELEMENT_COUNT = 9 
function GameColumnLayout:ctor(index)
	self.stop=true           --是否停止
	self.isstopnow=false     --是否立即停止
	self.items={}            --项容器
	self.index = index
	local py_array = {77,240,405}
	--获取当前队列数据
	self.sequence=Command.getRandomNumber(ELEMENT_COUNT)
	--创建3个元素
	for i=1,ITEM_COUNT do
		local item=require("src.games.shuihuzhuan.ui.GameImage").new(self.sequence[i])
		local size=self:getContentSize()
		item:setPosition(cc.p(size.width/2,py_array[i]))
		self:addChild(item)
		table.insert(self.items,item)
	end

	self:setTouchEnabled(true)
	self:addTouchEventListener(
		function (sender,eventType)
			if eventType==ccui.TouchEventType.ended then
				self:over()
			end
		end)
end

function GameColumnLayout:hideAll()
	for i=1,#self.items do
		self.items[i]:setGray()
	end
end

function GameColumnLayout:itemNormalByIndex(index)
	self.items[index]:setNormal()
end

function GameColumnLayout:play(overtime,result)
	self.stop = false
	self.result = result
	for i=1,#self.items do
		self.items[i]:trun()
	end
	self.overaction = self:performWithDelay(function()
		self.overaction = nil
		self:over()
	end,overtime)
end

function GameColumnLayout:playPrizeByIndex(index)
	self.items[index]:playAni()
end

--根据类型获得索引
function GameColumnLayout:getIndexByType(etype)
	for i=1,#self.items do
		if self.items[i]:getData().sid == etype then
			return i
		end
	end
	return 0
end

--根据索引播放特效
function GameColumnLayout:playAnimationByIndex(index)
	self.items[index]:playAni()
end



function GameColumnLayout:hideByIndex(index)
	self.items[index]:setVisible(false)
end

--立即停止
function GameColumnLayout:over()
	if self.stop then return end
	self.stop = true
	for i=1,#self.items do
		self.items[i]:stopTrun()
		self.items[i]:updateData(self.result[i])
	end
	if self.overaction then
		self:stopAction(self.overaction)
		self.overaction = nil
	end
	self:dispatchEvent("LIST_GAME_STOP",self.index)
end

function GameColumnLayout:stopElementAni()
	for i=1,#self.items do
		self.items[i]:stopTrun()
	end
end

function GameColumnLayout:setNormalAll()
	for i=1,#self.items do
		self.items[i]:setNormal()
	end
end

function GameColumnLayout:onEnter()
end

function GameColumnLayout:onExit()
end

return GameColumnLayout
