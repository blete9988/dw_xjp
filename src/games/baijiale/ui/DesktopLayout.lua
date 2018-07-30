--[[
*	百家乐 桌面层
*	@author：lqh
]]
local DesktopLayout = class("DesktopLayout",require("src.base.extend.CCLayerExtend"),function() 
	return display.newLayout(cc.size(1112,693))
end)


function DesktopLayout:ctor(father)
	self:super("ctor")
	self:setTouchEnabled(true)
	Coord.scgap(self,"LL",74,"TT",0)
	
	local gameMgr = require("src.games.baijiale.data.Bjl_GameMgr").getInstance()
	self:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		if gameMgr.initstatus == ST.TYPE_GAMEBJL_ON_BET then
			--进入房间正在下注
			display.showMsg(display.trans("##20001"))
			return
		elseif gameMgr.gamestatus == ST.TYPE_GAMEBJL_WAIT then
			-- 现在是下注等待中，禁止下注
			display.showMsg(display.trans("##20002"))
			return
		end
		
		local p = t:getTouchEndPosition()
		--区域选中
		for type,v in pairs(self.m_structs) do
			if v.data:isIntouchArea(p) then
				--低于1000金币提示充值
				if not display.checkGold(1000) then return end
				local betStruct = gameMgr.currentBet
				if betStruct.value then
					--下注请求
					ConnectMgr.connect("src.games.baijiale.connect.Bjl_BetConnect" , betStruct.value,type,function(result) 
						if result ~= 0 then return end
						SoundsManager.playSound("bjl_add_bet")
						father:addBet(betStruct.value,type,betStruct.pos,0,true)
						gameMgr:addBetRecord(type,betStruct.value,betStruct.pos)
					end)
				end
				self:m_blinkBetArea(type)
				return 
			end
		end
	end)
	self:m_init()
end

--闪烁胜利区域
function DesktopLayout:blinkWinArea(type)
	local pic = self.m_structs[type].winpic
	pic:setOpacity(0)
	pic:stopAllActions()
	pic:runAction(
		cc.Repeat:create(cc.Sequence:create({
			cc.FadeTo:create(0.6,255),
			cc.FadeTo:create(0.6,0)
		}),2)
	)
end
--获取指定下注区域内 随机的一个点
function DesktopLayout:getRandomBetPos(type)
	return self.m_structs[type].data:getBetPosition()
end
--更新对应下注区域  所有下注金额
function DesktopLayout:updateAllBetText(type,value)
	local txt = self.m_structs[type].allbetTxt
	txt.value = txt.value + value
	txt:setString(string.thousandsformat(txt.value))
end
function DesktopLayout:setAllBetText(type,value)
	local txt = self.m_structs[type].allbetTxt
	txt.value = value
	txt:setString(string.thousandsformat(value))
end
--更新对应下注区域  我的下注金额
function DesktopLayout:updateMineBetText(type,value)
	local txt = self.m_structs[type].minebetTxt
	txt.value = txt.value + value
	txt:setString(string.thousandsformat(txt.value))
end
--清理桌面
function DesktopLayout:clearDesktop()
	for k,v in pairs(self.m_structs) do
		v.allbetTxt:setString("0")
		v.allbetTxt.value = 0
		v.minebetTxt:setString("")
		v.minebetTxt.value = 0
	end
end
function DesktopLayout:m_init()
	local betareaDatas = require("src.games.baijiale.data.BetAreaData").getAllData()
	
	local datas = {}
	
	local tempdata,struct
	for i = 1,#betareaDatas do
		tempdata = betareaDatas[i]
		tempdata:transCoord(self)
		
		struct = {
			data = tempdata,
			winpic = self:m_createBetMask(tempdata),
			touchpic = self:m_createBetMask(tempdata),
		}
		struct.touchpic:setColor(cc.c3b(1,1,1))
		
		struct.allbetTxt,struct.minebetTxt = self:m_createBetText(tempdata)
		
		datas[tempdata.type] = struct
	end
	
	self.m_structs = datas
end
--创建一个 下注区域的蒙版
function DesktopLayout:m_createBetMask(data)
	local image = display.newImage(data.pic)
	image:setPosition(data.pos)
	image:setOpacity(0)
	if data.scaleX then
		image:setScaleX(data.scaleX )
	end
	if data.scaleY then
		image:setScaleY(data.scaleY )
	end
	self:addChild(image)
	return image
end
--创建下注文字
function DesktopLayout:m_createBetText(data)
	local allbetTxt = display.newText("0",22,Color.GREEN)
	allbetTxt:setAnchorPoint(cc.p(0,0.5))
	allbetTxt:setPosition(data.txtpos)
	allbetTxt.value = 0
	self:addChild(allbetTxt)
	
	local minebetTxt = display.newText("",22,Color.YELLOW)
	minebetTxt:setAnchorPoint(cc.p(0,0.5))
	minebetTxt:setPosition(data.txtpos)
	minebetTxt.value = 0
	self:addChild(Coord.outgap(allbetTxt,minebetTxt,"LL",0,"BT",-10))
	
	return allbetTxt,minebetTxt
end
--闪烁点击区域
function DesktopLayout:m_blinkBetArea(type)
	local pic = self.m_structs[type].touchpic
	pic:setOpacity(0)
	pic:stopAllActions()
	pic:runAction(cc.Repeat:create(cc.Sequence:create({
		cc.FadeTo:create(0.2,255),
		cc.FadeTo:create(0.2,0)
	}),1))
end
function DesktopLayout:onCleanup()
--	self:removeAllEvent()
end
return DesktopLayout