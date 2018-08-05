--[[
*	手牌组 item
*	@author：lqh
]]
local PokerGroupItem = class("PokerGroupItem",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(350,200))
end)

local poker_count = 3

function PokerGroupItem:ctor()
	self:super("ctor")
	self:setAnchorPoint( cc.p(0.5,0.5) )
	self.m_pokerItems = {}
	--是否是自己
	self.m_isself = true
	self.isshowdown = false
	self.index = 0
	
	local pos = cc.p(72,100)
	local item
	for i = 1,poker_count do
		item = require("src.games.sangong.ui.PokerItem").new()
		item:setPosition(pos)
		self:addChild(item)
		self.m_pokerItems[i] = item
		pos.x = pos.x + 50
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
function PokerGroupItem:setNotself()
	self.m_isself = false
	self:setScale(0.55)
	self.m_typePic:setScale(1.82)
end
--初始化牌
function PokerGroupItem:initPoker(pokergroup)
	if pokergroup then
		mlog("显示牌型。。。")
		self.m_data = pokergroup
		local pokers = pokergroup:getPokers()
		for i = 1,#self.m_pokerItems do
			self.m_pokerItems[i]:showFace(pokers[i])
		end
		self:splitPoker()
		self.m_typePic:setVisible(true)
		self.m_typePic:loadTexture(pokergroup:getTypePic(),1)
	else
		--无数据还未摊牌
		for i = 1,#self.m_pokerItems do
			self.m_pokerItems[i]:show()
		end
	end
end
--获取扑克的世界坐标
function PokerGroupItem:getPokerWorldPos(index)
	
	local p = self:convertToWorldSpace(cc.p(self.m_pokerItems[index]:getPosition()))
	return p
end
--获得一张牌
function PokerGroupItem:addPoker()
	self.index = self.index + 1
	self.m_pokerItems[self.index]:show(self.m_isself)
	if self.index >= 5 and self.isshowdown then
		self:showdown(self.m_data)
	end
end
--摊牌
function PokerGroupItem:showdown(data)
	self.m_data = data
	--牌未发完，服务器推送机器人开牌，容错处理
	local poker_count = 3
	if self.index < poker_count then
		self.isshowdown = true
		return
	end
	local pokers = data:getPokers()
	
	for i = 1,#self.m_pokerItems do
		self.m_pokerItems[i]:showFace(pokers[i])
	end
	self:splitPoker()
	self:showGroupType()
end
--显示扑克牌组合
function PokerGroupItem:splitPoker()
	local groups = self.m_data:getGroupSplit()
	
	local pokerItems = self.m_pokerItems
	local lesslen = 0

	local proker_count = 3
	for i = 1,proker_count do
		if groups[i] == 0 then
			lesslen = lesslen + 1
		end
	end
	if lesslen <= 1 then
		--5:0 ,4:1组合，全部向下移动
		-- for i = 1,proker_count do
		-- 	if groups[i] > 0 then
		-- 		pokerItems[i]:setPositionY(pokerItems[i]:getPositionY() - 30)
		-- 	end
		-- end
	else
		--3:2 组合
		if self.m_data.groupType == 3 then
			--没牛横向移动
			-- for i = 4,5 do
			-- 	pokerItems[i]:setPositionX(pokerItems[i]:getPositionX() + 25)
			-- end
		else
			--有牛向下移动
			-- for i = 1,5 do
			-- 	if groups[i] == 0 then
			-- 		pokerItems[i]:setPositionY(pokerItems[i]:getPositionY() - 30)
			-- 	end
			-- end
		end
	end
end
--显示牌型
function PokerGroupItem:showGroupType()
	mlog("显示牌型。。。")
	self.m_typePic:setVisible(true)
	local scale = self.m_typePic:getScale()
	self.m_typePic:loadTexture(self.m_data:getTypePic(),1)
	self.m_typePic:setOpacity(80)
	self.m_typePic:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.FadeIn:create(0.1),
			cc.ScaleTo:create(0.1,scale*1.5)
		}),
		cc.ScaleTo:create(0.2,scale*0.8),
		cc.ScaleTo:create(0.05,scale)
	}))
	SoundsManager.playSound(self.m_data:getTypeSound())
	if self.m_data.groupType > 4 then
		SoundsManager.playSound("qznn_niujiao")
	end
end
function PokerGroupItem:clear()
	self.index = 0
	self.isshowdown = false
	self.m_typePic:setVisible(false)
	
	local pos = cc.p(72,100)
	for i = 1,#self.m_pokerItems do
		self.m_pokerItems[i]:clear()
		self.m_pokerItems[i]:setPosition(pos)
		pos.x = pos.x + 50
	end
end

function PokerGroupItem:onCleanup()
end
return PokerGroupItem