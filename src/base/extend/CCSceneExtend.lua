--[[
*	scence 基类
]]
local CCSceneExtend = class("CCSceneExtend", require("src.base.extend.CCNodeExtend"),function() 
	local scene = cc.Scene:create()
	scene.nativeAddChild = scene.addChild
	return scene
end)

--预定义层
local default = {
	VIEW 			= {name = "VIEW",			order = 1	},			--ui层
	WINDOW 			= {name = "WINDOW",			order = 200	},			--window层
	CUSTOM_POP 		= {name = "CUSTOM_POP",		order = 300	},			--自定义弹出层
	POP 			= {name = "POP",			order = 400	},			--通用弹窗层
	TIP 			= {name = "TIP",			order = 500	},			--tip层
	MESSAGE 		= {name = "MESSAGE",		order = 600	},			--提示消息层
	LOADING_MASK 	= {name = "LOADING_MASK",	order = 1000}			--loading遮挡层
}
local mask_order = 10000			--全局遮罩默认层级

function CCSceneExtend.extend(target)
	target.nativeAddChild = target.addChild
    setmetatableex(target,CCSceneExtend)
	target:ctor()
    return target
end
function CCSceneExtend:ctor()
	self:setNodeEventEnabled(true)
	self.m_defaultUILyer = {}
    for k,v in pairs(default) do
    	local layer = cc.Layer:create()
    	layer:setLocalZOrder(v.order)
    	self:nativeAddChild(layer)
    	self.m_defaultUILyer[v.name] = layer
    end
		-- require("src.base.log.logUI").showdebug(self)
end
--@override
function CCSceneExtend:m_nodeEventHandler(event)
	if event == "enter" then
        self:onEnter()
    elseif event == "destory" then
    	self:onDestory()
    elseif event == "enterTransitionFinish" then
        self:onEnterTransitionFinish()
    elseif event == "exitTransitionStart" then
        self:onExitTransitionStart()
    elseif event == "cleanup" then
        self:onCleanup()
    elseif event == "exit" then
        if self.autoCleanupImages_ then
            for imageName, v in pairs(self.autoCleanupImages_) do
                display.removeSpriteFrameByImageName(imageName)
            end
            self.autoCleanupImages_ = nil
        end
        self:onExit()
		
        if Cfg.DEBUG_MEM then
            mlog(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
        end
		collectgarbage("collect")
    end
end
function CCSceneExtend:addChild(child,index)
	if index then
		self.m_defaultUILyer[default.VIEW.name]:addChild(child,index)
	else
		self.m_defaultUILyer[default.VIEW.name]:addChild(child)
	end
end
function CCSceneExtend:hideUI()
	self.m_defaultUILyer[default.VIEW.name]:setVisible(false)
end
function CCSceneExtend:showUI()
	self.m_defaultUILyer[default.VIEW.name]:setVisible(true)
end
function CCSceneExtend:addScreenMask(order,opacity)
	self:removeScreenMask()
	
	local screenmask = display.newMask(cc.size(D_SIZE.width,D_SIZE.height),opacity)
	display.extend("CCLayerExtend",screenmask)
	screenmask:setLocalZOrder(order or mask_order)
	self:nativeAddChild(screenmask)
	self.m_screenmask = screenmask
	return screenmask
end
function CCSceneExtend:removeScreenMask()
	if not self.m_screenmask then return end
	self.m_screenmask:removeFromParent(true) 
	self.m_screenmask = nil
end
function CCSceneExtend:getUIView()
	return self.m_defaultUILyer[default.VIEW.name]
end
--添加window
function CCSceneExtend:addWindow(widnow)
	self.m_defaultUILyer[default.WINDOW.name]:addChild(widnow)
end
--添加弹窗
function CCSceneExtend:addPop(pop)
	self.m_defaultUILyer[default.POP.name]:addChild(pop)
end
--添加自定义层
function CCSceneExtend:addCustom(custom)
	self.m_defaultUILyer[default.CUSTOM_POP.name]:addChild(custom)
end
--添加提示消息
function CCSceneExtend:addMsg(msg)
	self.m_defaultUILyer[default.MESSAGE.name]:addChild(msg)
end
--添加提示消息
function CCSceneExtend:addLoading(loading)
	self.m_defaultUILyer[default.LOADING_MASK.name]:addChild(loading)
end
--添加提示消息
function CCSceneExtend:addTip(tip)
	self.m_defaultUILyer[default.TIP.name]:addChild(tip)
end
return CCSceneExtend

