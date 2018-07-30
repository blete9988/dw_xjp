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