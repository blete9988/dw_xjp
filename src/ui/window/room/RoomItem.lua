--[[
*	赢分榜 层
*	@author：lqh
]]
local RoomItem = class("RoomItem",function() 
	local layout = display.newLayout(cc.size(290,415))
	layout:setAnchorPoint( cc.p(0.5,0.5) )
	layout:setTouchEnabled(true)
	return layout
end)

function RoomItem:ctor(room)
	local icon = display.newDynamicImage(room:getPic())
	self:addChild(Coord.ingap(self,icon,"CC",0,"BB",5))
	display.extendButtonToSound(self)
	
	local numbTxt,fullFlagImg
	if room.maxNmb > 0 then
		numbTxt = cc.Label:createWithCharMap(display.getTexture("res/fonts/main_font_nmb_1.png"),20,26,string.byte("0"))
		numbTxt:setAnchorPoint( cc.p(0,0.5) )
		numbTxt:setScale(0.85)
		numbTxt:setString(string.format("%s:%s",room.curNmb,room.maxNmb))
		self:addChild(Coord.ingap(self,numbTxt,"CL",10,"BB",46))
		-- if room.curNmb >= room.maxNmb then
		-- 	fullFlagImg = display.newImage("p_ui_1067.png")
		-- 	self:addChild(Coord.ingap(self,fullFlagImg,"RR",-15,"TT",-58))
		-- end
		numbTxt:setVisible(false)
	end

	local jackpot = display.newDynamicImage(room:getJackPot())
	if(jackpot)then
		jackpot:setScale(0.5)
		self:addChild(Coord.ingap(self,jackpot,"LL",-50,"BB",110))
		local init_num = 1000000 * math.random(1,100)
		local  jack_num = cc.Label:createWithCharMap(display.getTexture("res/fonts/main_font_nmb_1.png"),20,26,string.byte("0"))
		jack_num:setAnchorPoint( cc.p(0,0.5) )
		jack_num:setScale(0.85)
		jack_num:setString(init_num)
		
		self:addChild(Coord.ingap(self,jack_num,"LL",110,"BB",120))
		local jz_num = 88888
		jack_num:runAction(cc.RepeatForever:create(cc.Sequence:create(
			{
				cc.DelayTime:create(0.03),
				cc.CallFunc:create(function(target) 
					init_num = init_num + jz_num
					if(init_num >= 100000000)then
						init_num = 1000000
					end
					jack_num:setString(init_num)
				end)
			}
		)))

	end
	
	self:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then 
			self:setScale(1.03)
		elseif e == ccui.TouchEventType.canceled then 
			self:setScale(1)
		elseif e == ccui.TouchEventType.ended then 
			self:setScale(1)
			if room:testEntry() then
				ConnectMgr.connect("gamehall.EntryRoomConnect" , room,function(result) 
					if result ~= 0 then return end
					--退出当前windows
					WindowMgr.getRunningWindow():executQuit()
					--进入资源加载
					display.showWindow("src.ui.window.LoadingWindows",room)
				end)
				--WindowMgr.getRunningWindow():executQuit()
				--display.showWindow("src.ui.window.LoadingWindows",room)
			end
		end		
	end)
end

function RoomItem:onCleanup()
end

return RoomItem