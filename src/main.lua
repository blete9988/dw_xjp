
cc.FileUtils:getInstance():setPopupNotify(false)

local __g = _G
--全局变量代理工具,所有全局变量都应使用Gba.key = value 的形式定义
if not __g.Gbv then __g.Gbv = {} end
setmetatable(__g, {
	__index = function(_,name)
		return rawget(Gbv,name)
	end,
    __newindex = function(_, name, value)
    	rawset(Gbv,name,value)
    end
})

require "src.config"
require "src.cocos.init"
require "src.base.autoResolution"
require "src.base.init"

--设置是否允许加入全局变量
if Cfg.CC_DISABLE_GLOBAL then
    setmetatable(__g, {
    	__index = function(_,name)
    		if not Gbv[name] then mlog(DEBUG_S,string.format("<_G>:尝试读取未定义的全局变量  <%s>",name)) end
    		return Gbv[name]
    	end,
        __newindex = function(_, name, value)
            error(string.format("<_G>:请使用这种格式 \" Gbv.%s = value \" 定义全局变量", name), 0)
        end
    })
end
Gbv.CRef = CoordinateReference

local function main()
	local size = cc.Director:getInstance():getOpenGLView():getFrameSize()
	mlog(DEBUG_W,string.format("design resolution is : width %s , height %s;framesize is width: %s , height: %s",D_SIZE.w,D_SIZE.h,size.width,size.height))
	collectgarbage("collect")
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	display.enterScene("src.ui.scene.login.StartScene")
end

xpcall(main, __G__TRACKBACK__)