--[[
*	排行榜 window
*	@author：lqh
]]
local RoomWindows = class("RoomWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(1248,530))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",0)
	return layer
end)
RoomWindows.hide_forward = false

--RoomWindows ctor
function RoomWindows:ctor(gamedata)
	self:super("ctor")
	--模糊背景
	local blurebg = display.newDynamicImage()
	self:addChild(blurebg)
	--半透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),60),"CC",0,"CC",0))
--	display.screenShot("temp_screenshot.png",function(result,path)
--		pcall(function() 
--			if result ~= true or not self.windowPath then return end
--			blurebg:loadTexture(path)
--			blurebg:setOpacity(0)
--			Coord.fixSize(blurebg,D_SIZE.w,D_SIZE.h)
--			Coord.ingap(self, blurebg,"CC",0,"CC",0,true)
--			require("src.base.tools.openglTools").setBlur(blurebg)
--			blurebg:runAction(cc.FadeIn:create(0.3))
--		end)
--	end)
	
	self:addChild(Coord.ingap(
		self,
		display.setS9(
			display.newDynamicImage("res/images/single/single_windowbg_03.png")
			,cc.rect(140,90,950,90),cc.size(1248,530)
		),
		"CC",0,"CC",0))
		
	self:addChild(Coord.ingap(self,display.newDynamicImage(string.format("game/%s/icon/icon_title.png",gamedata.key)),"CC",-9,"TC",10))
	
	local closebtn = display.newButton("p_btn_1013.png","p_btn_1013.png")
	closebtn._m_pressSound = "nosound"
	closebtn:setPressedActionEnabled(true)
	self:addChild(Coord.ingap(self,closebtn,"RC",-10,"TC",-15))
	closebtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:executQuit()
		Player.setGameSid(0)
	end)
	self:m_init(gamedata)
end
function RoomWindows:m_init(gamedata)
	local pageview = ccui.PageView:create()
	pageview:setContentSize( cc.size(1200,415) )
	pageview:setTouchEnabled(true)
	pageview:setDirection(2)
	self:addChild(Coord.ingap(self,pageview,"CC",0,"BB",55))
--	display.debugLayout(pageview)
	
	local rooms = gamedata:getRooms()
	local len = #rooms
	if len > 4 then
		--左提示箭头		
		local leftarrow = display.newImage("p_ui_1056.png")
		self:addChild(Coord.outgap(pageview,leftarrow,"LR",-30,"CC",0))
		--右提示箭头
		local rightarrow = display.newImage("p_ui_1056.png")
		self:addChild(Coord.outgap(pageview,rightarrow,"RL",30,"CC",0))
		rightarrow:setRotation(180)
	end
	
	for i = 1,len,4 do
		local page = display.newLayout(cc.size(1110,415))
		local p = cc.p( 8 + 290*0.5,415*0.5)
		for k = 0,3 do
			if not rooms[i + k] then break end
			local item = require("src.ui.window.room.RoomItem").new(rooms[i + k])
			item:setPosition(p)
			page:addChild(item)
			p.x = p.x + 290 + 8
		end
		pageview:addPage(page)
	end
end

return RoomWindows