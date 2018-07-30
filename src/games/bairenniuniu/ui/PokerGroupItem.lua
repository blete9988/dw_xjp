--[[
*	手牌组 item
*	@author：lqh
]]
local PokerGroupItem = class("PokerGroupItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(195,100))
end)

function PokerGroupItem:ctor()
	self:super("ctor")
	
	self.m_pokerItems = {}
	self.index = 0
	
	local pos = cc.p(42.5,50)
	local item
	for i = 1,5 do
		item = require("src.games.bairenniuniu.ui.PokerItem").new()
		item:setPosition(pos)
		self:addChild(item)
		self.m_pokerItems[i] = item
		pos.x = pos.x + 25
	end
	
	local typePic = display.newImage()
	self:addChild(Coord.ingap(self,typePic,"CC",0,"CC",-30))
	self.m_typePic = typePic
end
--设置数据
function PokerGroupItem:setData(data)
	self.m_data = data
	local pokers = data:getPokers()
	
	for i = 1,#self.m_pokerItems do
		self.m_pokerItems[i]:setPoker(pokers[i])
	end
end
--获取扑克的世界坐标
function PokerGroupItem:getPokerWorldPos(index)
	local p = self:convertToWorldSpace(cc.p(self.m_pokerItems[index]:getPosition()))
	return p
end
--显示一张牌
function PokerGroupItem:showPoker()
	self.index = self.index + 1
	self.m_pokerItems[self.index]:show(self.index == 5)
end
--看最后一张牌
function PokerGroupItem:seeLastPoker(callback)
	self.m_pokerItems[self.index]:seePoker(function() 
		self:splitPoker()
		if callback then callback() end
	end)
end
--显示扑克牌组合
function PokerGroupItem:splitPoker()
	local groups = self.m_data:getGroupSplit()
	
	local pokerItems = self.m_pokerItems
	local lesslen = 0
	for i = 1,5 do
		if groups[i] == 0 then
			lesslen = lesslen + 1
		end
	end
	if lesslen <= 1 then
		--5:0 ,4:1组合，全部向下移动
		for i = 1,5 do
			if groups[i] > 0 then
				pokerItems[i]:setPositionY(pokerItems[i]:getPositionY() - 30)
			end
		end
	else
		--3:2 组合
		if self.m_data.groupType == 3 then
			--没牛横向移动
			for i = 4,5 do
				pokerItems[i]:setPositionX(pokerItems[i]:getPositionX() + 25)
			end
		else
			--有牛向下移动
			for i = 1,5 do
				if groups[i] == 0 then
					pokerItems[i]:setPositionY(pokerItems[i]:getPositionY() - 30)
				end
			end
		end
	end
end
--显示牌型
function PokerGroupItem:showGroupType()
	self.m_typePic:setVisible(true)
	self.m_typePic:loadTexture(self.m_data:getTypePic(),1)
	self.m_typePic:setOpacity(80)
	self.m_typePic:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.1),
			cc.ScaleTo:create(0.1,1.5)
		}),
		cc.ScaleTo:create(0.2,0.8),
		cc.ScaleTo:create(0.05,1)
	}))
end
function PokerGroupItem:clear()
	self.index = 0
	self.m_typePic:stopAllActions()
	self.m_typePic:setVisible(false)
	local pos = cc.p(42.5,50)
	for i = 1,#self.m_pokerItems do
		self.m_pokerItems[i]:clear()
		self.m_pokerItems[i]:setPosition(pos)
		pos.x = pos.x + 25
	end
end

function PokerGroupItem:onCleanup()
end
return PokerGroupItem