--[[
*	通用ui Window
*	@author：lqh
]]
local BaseUIWindows = class("BaseUIWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(1086,685))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",0)
	return layer
end)
BaseUIWindows.hide_forward = false
function BaseUIWindows:ctor(background,title,noClose)
	self:super("ctor")
	--模糊背景
	if WindowMgr.getWindowCount() == 0 then
--		local blurebg = display.newDynamicImage()
--		self:addChild(blurebg)
--		display.screenShot("temp_screenshot.png",function(result,path)
--			pcall(function() 
--				if result ~= true or not self.windowPath then return end
--				blurebg:loadTexture(path)
--				blurebg:setOpacity(0)
--				Coord.fixSize(blurebg,D_SIZE.w,D_SIZE.h)
--				Coord.ingap(self, blurebg,"CC",0,"CC",0,true)
--				require("src.base.tools.openglTools").setBlur(blurebg)
--				blurebg:runAction(cc.FadeIn:create(0.3))
--			end)
--		end)
	end
	--半透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),60),"CC",0,"CC",0))
	
	
	self:addChild(Coord.ingap(self,background,"CC",0,"CC",0))
	self:addChild(Coord.ingap(self,display.newImage(title),"CC",0,"TT",-20))
	if(not noClose)then
		local closebtn = display.newButton("p_btn_1013.png","p_btn_1013.png")
		closebtn._m_pressSound = "nosound"
		closebtn:setPressedActionEnabled(true)
		self:addChild(Coord.ingap(self,closebtn,"RR",-10,"TT",-22))
		closebtn:addTouchEventListener(function(t,e) 
			if e ~= ccui.TouchEventType.ended then return end
			self:executQuit()
		end)
	end
end
--@override
function BaseUIWindows:onCleanup()
	self:super("onCleanup")
end

return BaseUIWindows