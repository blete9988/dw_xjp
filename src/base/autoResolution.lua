--[[
*	auto resolution 
]]
local director = cc.Director:getInstance()
local view = director:getOpenGLView()

--win32 not opengl view then it will create opengl view
local function createOpenglView() 
	if view then return end
	--default win32 opengl view width,height
    local width,height = 765,1360
    if D_SIZE then
    	--if D_SIZE win32 framesize will set design size
    	width = D_SIZE.width or width
    	height = D_SIZE.height or height
    end
    view = cc.GLViewImpl:createWithRect("src.cocos2d-Lua", cc.rect(0, 0, width, height))
    director:setOpenGLView(view)
end
createOpenglView()
if require("src.cocos.framework.device").platform == "windows" then
	--platform is windows
    view:setFrameZoomFactor(D_SIZE.zoomFactor)
end

local framesize = view:getFrameSize()
local function checkResolution(config)
	--design resolution must be number and > 0
	assert(
		config.width and config.width and type(config.width) == "number" and type(config.height) == "number" and config.width > 0 and config.height > 0,
		"##################### error design resolution size #####################"
	)
	--default scale is EXACT_FIT
	config.autoscale = config.autoscale or "EXACT_FIT"
    config.autoscale = string.upper(config.autoscale)
end
local ruleDesignWidth,releDesignHeight
--设置设计分辨率
local function setDesignResolution(config, framesize)
    if config.autoscale == "FILL_ALL" then
        view:setDesignResolutionSize(framesize.width, framesize.height, cc.ResolutionPolicy.FILL_ALL)
    else
        local scaleX, scaleY = framesize.width / config.width, framesize.height / config.height
        local width, height = framesize.width, framesize.height
        if config.autoscale == "FIXED_WIDTH" then
            width = framesize.width / scaleX
            height = framesize.height / scaleX
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
            
            config.width,config.height = width,height
            printInfo(string.format("design resolution changed to width : %s , height : %s",width,height))
            
        elseif config.autoscale == "FIXED_HEIGHT" then
            width = framesize.width / scaleY
            height = framesize.height / scaleY
            view:setDesignResolutionSize(width, height, cc.ResolutionPolicy.NO_BORDER)
            
            config.width,config.height = width,height
            printInfo(string.format("design resolution changed to width : %s , height : %s",width,height))
            
        elseif config.autoscale == "EXACT_FIT" then
        	--全屏拉伸，默认定义两个拉升比列 16:9(1360:765),4:3(1360:900)
    		local frameRatio = width/height
    		local design_width,design_height
        	if width > height then
        		local ratio16_9,ratio4_3 = 16/9,4/3
        		if math.abs(frameRatio - ratio16_9) <= math.abs(frameRatio - ratio4_3) then
        			design_width,design_height = 1360,765
        		else
        			design_width,design_height = 1360,900
        		end
        	else
        		local ratio9_16,ratio3_4 = 9/16,3/4
        		if math.abs(frameRatio - ratio9_16) <= math.abs(frameRatio - ratio3_4) then
        			design_width,design_height = 765,1360
        		else
        			design_width,design_height = 900,1360
        		end
        	end
        	if design_height == 900 then
        		--修改逻辑 4：3 采用黑边
        		design_height = 765
        		view:setDesignResolutionSize(design_width, design_height, cc.ResolutionPolicy.SHOW_ALL)
        	else
           		view:setDesignResolutionSize(design_width, design_height, cc.ResolutionPolicy.EXACT_FIT)
            end
        	ruleDesignWidth,releDesignHeight = design_width, design_height
            
        	config.width,config.height = design_width,design_height
            printInfo(string.format("design resolution changed to width : %s , height : %s",design_width,design_height))
        elseif config.autoscale == "NO_BORDER" then
        	--等比拉伸无黑边，超出的边将会被裁剪掉一部分
            view:setDesignResolutionSize(config.width, config.height, cc.ResolutionPolicy.NO_BORDER)
        elseif config.autoscale == "SHOW_ALL" then
        	--等比拉伸有黑边
            view:setDesignResolutionSize(config.width, config.height, cc.ResolutionPolicy.SHOW_ALL)
        else
            printError(string.format("display - invalid r.autoscale \"%s\"", r.autoscale))
        end
    end
end

--执行屏幕适配
local function executeAutoScreen(configs)
	if not configs or type(configs) ~= "table" then return end

    checkResolution(configs)
    
    if type(configs.customExecute) == "function" then
        local c = configs.customExecute(framesize)
        for k, v in pairs(c or {}) do
            configs[k] = v
        end
        checkResolution(configs)
    end

    setDesignResolution(configs, framesize)
end

executeAutoScreen(D_SIZE)

--[[
*	重定义D_SIZE为常量
*	并添加一些常用方法
]]
local dsize_mt = {
	width = ruleDesignWidth,
	height = releDesignHeight,
	w = ruleDesignWidth,
	h = releDesignHeight,
	hw = ruleDesignWidth*0.5,
	hh = releDesignHeight*0.5,
	fix = 900 - releDesignHeight,
	is9_16 = releDesignHeight == 765
}

--尺寸					使用 D_SIZE.size() 
function dsize_mt.size()
	return cc.size(dsize_mt.w,dsize_mt.h)
end
--中心点					使用 D_SIZE.center()
function dsize_mt.center()
	return cc.p(dsize_mt.hw,dsize_mt.hh) 
end
--顶边偏移				使用 D_SIZE.top(offset)
function dsize_mt.top(offset)
	return dsize_mt.h - offset
end
--右边偏移 				使用 D_SIZE.right(offset)
function dsize_mt.right(offset)
	return dsize_mt.w - offset
end
--返回高对应比列的值		使用 D_SIZE.perheight(percent)/D_SIZE.ph(percent)
function dsize_mt.perheight(percent)
	return dsize_mt.h*percent/100
end
dsize_mt.ph = dsize_mt.perheight
 --返回宽对应比列的值		使用 D_SIZE.perwidth(percent)/D_SIZE.pw(percent)
function dsize_mt.perwidth(percent)
	return dsize_mt.w*percent/100
end
dsize_mt.pw = dsize_mt.perwidth

D_SIZE = {}			--重置D_SIZE,不可更改或者添加D_SIZE参数,只能使用
setmetatable(D_SIZE,{
	__index = dsize_mt,
	__newindex = function(t,k,v)
		if dsize_mt[k] then
			mlog(DEBUG_W,string.format("<D_SIZE>:can not change D_SIZE property(%s) value!",k))
			return
		end
		error(string.format("<D_SIZE> attempt to read undeclared variable <%s>",k))
  	end,
  	__metatable = "You cannot get the protect metatable"
})
