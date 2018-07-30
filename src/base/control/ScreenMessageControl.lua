display.getFrameCache():addSpriteFrames("res/images/popui.plist")
--[[
*	屏幕提示信息控件
*	@author：lqh
]]
local instances = {}
local ScreenMessageControl = class("ScreenMessageControl",require("src.base.extend.CCLayerExtend"),function() 
	local container = display.newLayout(cc.size(1,1))
	container:setAnchorPoint(cc.p(0.5, 0.5))
	container:setPosition(cc.p(D_SIZE.hw,D_SIZE.hh + 140))
	return container
end)
function ScreenMessageControl:ctor(message,fontsize)
	self:super("ctor")
	
	local info,size
	local background = display.setS9(display.newImage("popui_001.png"),cc.rect(160,10,20,40))
	if type(message) ~= "userdata" then
		message = tostring(message)
		info = require("src.base.control.label.LabelElement").new(message,fontsize or 28,cc.c3b(0xc7,0xbb,0x73),Cfg.FONT,require("src.app.config.style.cssstyle")["alter"])
		--info:enableOutline(cc.c4b(255,255,255,255),2)
		--info:enableShadow(cc.c4b(0,0,0,255),cc.size(3,-3),0)
		info:setHorType("center")
		info:draw()
		size = info:getContentSize()
		if size.width > 1000 then
			info:setWidth(1000)
			size = info:getContentSize()
		end
		if size.width + 100 > 380 then
			size.width = size.width + 100
		else
			size.width = 380
		end
	else
		info = message
		info:setAnchorPoint(cc.p(0.5, 0.5))
		size = info:getContentSize()
		if size.width + 160 > 380 then
			size.width = size.width + 160
		else
			size.width = 380
		end
	end
	
	if size.height + 16 > 56 then
		size.height = size.height + 16
	else
		size.height = 56
	end
	self.size = size
	background:setContentSize(size)
	
	self:addChild(Coord.ingap(self,background,"CC",0,"CC",0))
	background:addChild(Coord.ingap(background,info,"CC",0,"CC",0))
	
	background:setCascadeOpacityEnabled(true)
	self.background = background
end
function ScreenMessageControl:onEnter()
	self.background:setScale(0.5)
	self.background:setOpacity(0)
	self.background:runAction(cc.Sequence:create({
		cc.Spawn:create({
			cc.Sequence:create({cc.ScaleTo:create(0.1,1.05),cc.ScaleTo:create(0.2,1)}),
			cc.FadeIn:create(0.3)
		}),
		cc.DelayTime:create(1),
		cc.Spawn:create({
			cc.Sequence:create({cc.ScaleTo:create(0.2,1.05),cc.ScaleTo:create(0.1,0.75)}),
			cc.FadeOut:create(0.3)
		}),
--		cc.FadeOut:create(0.3),
		cc.CallFunc:create(function(target) 
			if not target then return end
			target:removeFromParent(true)
		end)
	}))
end
function ScreenMessageControl:onExit()
	table.remove(instances,1)
end
--[[
*	param:message		显示信息
*	param:fontsize		字体大小（可选参数） 默认为32
]]
function ScreenMessageControl.show(message,fontsize--[[=32]])
	local scrollmsg = ScreenMessageControl.new(message,fontsize)
	local size,flag = #instances
	if size > 0 then
		if size > 1 then
			instances[1]:removeFromParent(true)
		end
		local temp = instances[1]
		temp:runAction(cc.MoveTo:create(0.1,cc.p(D_SIZE.w*0.5,D_SIZE.hh + 140 + scrollmsg.size.height*0.5 + temp.size.height*0.5 + 20)))
	end
	table.insert(instances,scrollmsg)
	display.getRunningScene():addMsg(scrollmsg)
end
return ScreenMessageControl