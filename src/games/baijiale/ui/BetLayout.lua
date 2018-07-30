--[[
*	百家乐 下注层
*	@author：lqh
]]
local BetLayout = class("BetLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
end)

local dsize = cc.size(D_SIZE.w,D_SIZE.h)

function BetLayout:ctor(father)
	self:super("ctor")
	self:setTouchEnabled(true)
	
	--筹码层
	local betlayer = display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
	self:addChild(betlayer)
	self.m_betlayer = betlayer
	
	--桌面层
	local desktoplayout = require("src.games.baijiale.ui.DesktopLayout").new(self,father)
	self:addChild(desktoplayout)
	self.m_desktoplayout = desktoplayout
end

--[[
*	添加筹码
]]
function BetLayout:addBet(value,type,startPoint,delay,isself,realvalue)
	startPoint = startPoint or self:getStartPoint()
	delay = delay or 0
	
	local betsp = display.newSprite(string.format("bet_%s.png",value))
	betsp:setScale(0.5)
	betsp:setPosition(startPoint)
--	betsp:setOpacity(200)
	self.m_betlayer:addChild(betsp)
	
	local pos = self.m_desktoplayout:getRandomBetPos(type)
	betsp:runAction(cc.Sequence:create({
		cc.DelayTime:create(delay),
--		cc.Spawn:create({
--			cc.FadeIn:create(0.3),
--			cc.EaseExponentialOut:create(cc.MoveTo:create(0.3,pos)),
			cc.MoveTo:create(0.3,pos),
--		}),
		cc.CallFunc:create(function(t) 
			if not t then return end
			if isself then
				self.m_desktoplayout:updateMineBetText(type,value)
			else
				if realvalue then
					self.m_desktoplayout:setAllBetText(type,realvalue)
				else
					self.m_desktoplayout:updateAllBetText(type,value)
				end
			end
		end),
	}))
end
--批量添加筹码
function BetLayout:bathAddBet(data)
	for type,value in pairs(data.areaAllGolds) do
		if data.betlist[type] then
			local delay = math.random(0,20) * 0.01
			local list = data.betlist[type]
			local len = #list
			--将每个区域的所有下注分成5份
			local perlen = 5
			if len <= 5 then perlen = 1 end
			
			for i = 1,5 do
				local pos = self:getStartPoint()
				local temp
				for m = 1,perlen do
					temp = list[(i - 1)*perlen + m]
					if temp then
						if m == perlen or not list[(i - 1)*perlen + m + 1] then
							self:addBet(temp,type,pos,delay,false,data.areaAllGolds[type])
						else
							self:addBet(temp,type,pos,delay)
						end
						pos = self:getRandomRoundPos(pos)
					else
						break
					end
				end
				delay = delay + 0.1
			end
		else
			self.m_desktoplayout:setAllBetText(type,value)
		end
	end
end
--批量添加我的投资数据
function BetLayout:bathAddMineBet(data)
	local len = #data
	local delay = 0.5/len
	for i = 1,len do
		self:addBet(data[i].value,data[i].type,data[i].pos,delay*(i - 1),true)
	end
end

--显示结果
function BetLayout:showResult()
	local types = {
		ST.TYPE_GAMEBJL_RESULT_0,
		ST.TYPE_GAMEBJL_RESULT_1,
		ST.TYPE_GAMEBJL_RESULT_2,
		ST.TYPE_GAMEBJL_RESULT_3,
		ST.TYPE_GAMEBJL_RESULT_4,
		ST.TYPE_GAMEBJL_RESULT_5,
		ST.TYPE_GAMEBJL_RESULT_6,
		ST.TYPE_GAMEBJL_RESULT_7	
	}
	
	local resultMgr = require("src.games.baijiale.data.Bjl_GameMgr").getInstance().resultMgr
	local len = #types
	for i = 1,len do
		if resultMgr:judgeResult(types[i]) then
			self.m_desktoplayout:blinkWinArea(types[i])
		end
	end
	
	self:runAction(cc.Sequence:create({
		cc.DelayTime:create(3.5),
		cc.CallFunc:create(function(t) 
			if not t then return end
			CommandCenter:sendEvent(ST.COMMAND_GAMEBJL_DESKTOP_OVER)
		end),
	}))
end
--随机获取指定点周围的点
function BetLayout:getRandomRoundPos(pos)
	local p = cc.p(pos.x,pos.y)
	if p.x < 0 then
		p.x = p.x - math.random(0,50)
	else
		p.x = p.x + math.random(0,50)
	end
	if p.y < 0 then
		p.y = p.y - math.random(0,50)
	else
		p.y = p.y + math.random(0,50)
	end
	return p
end
--获取屏幕外的一个随机点
function BetLayout:getStartPoint()
	local startPoint = cc.p(0,0)
	if math.random(1,100)%2 == 0 then
		--上下出筹码
		startPoint.x = math.random(0,dsize.width)
		if math.random(1,100)%2 == 0 then	
			--上
			startPoint.y = dsize.height + 50 + math.random(0,100)
		else
			--下
			startPoint.y = -50 - math.random(0,100)
		end	
	else
		--左右出筹码
		startPoint.y = math.random(-50,dsize.width + 50)
		if math.random(1,100)%2 == 0 then	
			--左
			startPoint.x = -50 - math.random(0,100)
		else
			--右
			startPoint.x = dsize.width + 50 + math.random(0,100)
		end	
	end
	return startPoint
end
--设置等待提示
function BetLayout:setWaitingTips(bool)
	if bool then
		if self.m_waitingtips then return end
		local layout = display.newMask(nil,150)
		self:addChild(Coord.scgap(layout,"CC",0,"CC",0))
		
		local bg = display.setS9(display.newImage("popui_001.png"),cc.rect(160,10,20,40),cc.size(620,97))
		layout:addChild(Coord.ingap(layout,bg,"CC",0,"CC",100))
		bg:addChild(Coord.ingap(bg,display.newImage("bjl_ui_1066.png"),"CC",0,"CC",0))
		self.m_waitingtips = layout
	else
		if not self.m_waitingtips then return end
		self.m_waitingtips:removeFromParent()
		self.m_waitingtips = nil
	end
end
--清理
function BetLayout:clear()
	--清楚所有筹码显示
	self.m_betlayer:removeAllChildren()
	--清楚下注区域数字显示
	self.m_desktoplayout:clearDesktop()
end
return BetLayout