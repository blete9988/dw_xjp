display.getFrameCache():addSpriteFrames("res/images/popui.plist")
--[[
*	遮挡loading
*	@author：lqh
]]
local instance
local LoadingMaskControl = class("LoadingMaskControl",require("src.base.extend.CCLayerExtend"),function() 
	local container = display.newLayout(cc.size(D_SIZE.w,D_SIZE.h))
	container:setTouchEnabled(true)
	return container
end)
function LoadingMaskControl:ctor(info,delay,socketid,duration--[[=18]],callback --[[=nil]])
	self:super("ctor")
	self.m_socketid = socketid
	delay = delay or 0
	duration = duration or 18
	if delay > 0 then
		--为真，但是不给值，默认0.9s延迟后显示
		self.handler = timeout(function()
			self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
			self:setBackGroundColor(cc.c3b(0,0,0))
			self:setBackGroundColorOpacity(110) 
			self:displayshow(info,duration - delay,callback)
		end,delay)
	else
		self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		self:setBackGroundColor(cc.c3b(0,0,0))
		self:setBackGroundColorOpacity(110)
		self:displayshow(info,duration,callback)
	end 
end
function LoadingMaskControl:displayshow(info,duration,callback)
	if not info then
		local maskbg = display.newImage("loadingmask_bg.png")
		self:addChild(Coord.ingap(self,maskbg,"CC",0,"CC",0))
		
		local maskfg = display.newImage("loadingmask_gb.png")
		maskfg:setAnchorPoint(cc.p(0, 0))
		maskbg:addChild(Coord.ingap(maskbg,maskfg,"CL",0,"CB",0))
		maskfg:runAction(cc.RepeatForever:create(cc.Sequence:create(
			{
				cc.DelayTime:create(0.03),
				cc.CallFunc:create(function(target) 
					target:setRotation(target:getRotation()%360 + 10)
				end)
			}
		)))
	else
		local upground = display.setS9(display.newImage("popui_001.png"),cc.rect(160,10,20,40))
		
		local text = display.newText(info,32,cc.c3b(0xc7,0xbb,0x73))
		--text:enableOutline(cc.c4b(0xfa,0x49,0x3c,255),2)
		local size = text:getContentSize()
		
		if size.width + 100 > 380 then
			size.width = size.width + 100
		else
			size.width = 380
		end
		size.height = 56
		upground:setContentSize(size)
		
		self:addChild(Coord.ingap(self,upground,"CC",0,"CC",100))
		upground:addChild(Coord.ingap(upground,text,"CC",0,"CC",0))
	end
	if not callback then
		if duration < 0 then duration = 0 end
		
		self:runAction(cc.Sequence:create({
			cc.DelayTime:create(duration),
			cc.CallFunc:create(function()
				--超时,通知进行重连
				mlog("loading已显示超时，将提示断线。")
				ConnectMgr.noticehandler(ST.TYPE_SOCKET_OUTTIME,self.m_socketid)
			end)
		}))
	else
		--自定义超时后回掉处理
		timeout(function()
			LoadingMaskControl.hide()
			callback()
		end,duration)
	end
end
function LoadingMaskControl:onCleanup()
	if self.handler then
		timestop(self.handler)
		self.handler = nil
	end
	instance:stopAllActions()
	instance = nil
end
--[[
*	显示loading蒙版
*	@param info			文本信息
*	@param delay		延迟多少时间显示，默认为false，改参数可以是false和true，如果为true则默认延迟1s，也可以是int指定延迟多久显示
*	@param duration		持续时间，默认值为18s，18s过后还没被关闭则认为连接超时
*	@param callback		如果修改了duration，则可以添加该参数进行自定义处理
]]
function LoadingMaskControl.show(info,delay,socketid,duration--[[=18]],callback --[[=nil]])
	if instance then return end
	instance = LoadingMaskControl.new(info,delay,socketid,duration,callback)
	display.getRunningScene():addLoading(instance)
end
function LoadingMaskControl.hide()
	if not instance then return end
	instance:removeFromParent(true)
	instance = nil
end
return LoadingMaskControl