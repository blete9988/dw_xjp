local display = {}

local director= cc.Director:getInstance()
local textureCache = director:getTextureCache()
local spriteFrameCache = cc.SpriteFrameCache:getInstance()
local animationCache = cc.AnimationCache:getInstance()
local fileUtils = cc.FileUtils:getInstance()
--设置是否显示帧率
director:setDisplayStats(Cfg.FPS_SHOW_STATUS)

--虚拟键盘返回键状态
display.KeyboardReturnType = {
    DEFAULT = 0, 			--当前键盘默认返回键
    DONE = 1,				--为Done字样
    SEND = 2,				--为发送字样
    SEARCH = 3,				--为搜索字样
    GO = 4					--为go字样
}
--虚拟键盘类型
display.InputMode = {
    ANY = 0,				--支持输入任何字符，包括换行符
    EMAIL_ADDRESS = 1,		--email
    NUMERIC = 2,			--只能输入一个整数值
    PHONE_NUMBER = 3,		--只能输入数字
    URL = 4,				--url
    DECIMAL = 5,			--小数
    SINGLE_LINE = 6,		--任何字符，换行符除外
}

--玩家金币检查
function display.checkGold(value,txt)
	if Player.gold < value then
		if txt then
			txt = txt .. "\n \n" .. display.trans("##30025")
		else
			txt = display.trans("##30025")
		end
		display.showPop({info = txt,htype = "left",callback = function(flag) 
			if flag == ST.TYPE_POP_OK then
				display.showWindow("src.ui.window.MartWindows")
			end
		end})
		return false
	end
	return true
end

function display.wrapScene(scene, transition, time, more)
    local key = string.upper(tostring(transition))

    if key == "RANDOM" then
        local keys = table.keys(display.SCENE_TRANSITIONS)
        key = keys[math.random(1, #keys)]
    end

    if display.SCENE_TRANSITIONS[key] then
        local t = display.SCENE_TRANSITIONS[key]
        local cls = t[1]
        time = time or 0.2
        more = more or t[2]
        if more ~= nil then
            scene = cls:create(time, scene, more)
        else
            scene = cls:create(time, scene)
        end
    else
        error(string.format("display.wrapScene() - invalid transition %s", tostring(transition)))
    end
    return scene
end

function display.replaceScene(newScene, transition, time, more)
    if director:getRunningScene() then
        if transition then
            newScene = display.wrapScene(newScene, transition, time, more)
        end
        director:replaceScene(newScene)
    else
        director:runWithScene(newScene)
    end
end
function display.enterScene(sceneName, args, transition, time, more)
	mlog(string.format("<display>:enter new secene , secene name is \" %s \"",sceneName))
    local sceneClass = require(sceneName)
    local scene = sceneClass.new(unpack(totable(args)))
    if Gbv.WindowMgr then WindowMgr.closeAllWindow() end
    display.replaceScene(scene, transition, time, more)
end
--截屏，并保持到本地
function display.screenShot(name,callback)
	cc.utils:captureScreen(function(result,filepath) 
		mlog(string.format("<display>:截屏回掉触发， result = %s , filepath = %s",result,filepath))
		if callback then callback(result,filepath) end
	end,name)
end
function display.showWindow(name,...)
	WindowMgr.showWindow(name,...)
end
--获取当前Scene
function display.getRunningScene()
    return director:getRunningScene()
end
--获取diretor
function display.getDirector()
	return director
end
--获取frame缓存
function display.getFrameCache()
	return spriteFrameCache
end
--获取texture缓存
function display.getTextureCache()
	return textureCache
end
--获取一个缓存的spriteframe
function display.getSpriteFrame(frameName)
	return spriteFrameCache:getSpriteFrame(frameName)
end
--获取一个缓存的纹理
function display.getTexture(path)
	return textureCache:getTextureForKey(path)
end
--创建Scene
function display.newScene()
    return display.extend("CCSceneExtend",cc.Scene:create())
end

function display.newFrames(pattern, begin, length, isReversed)
    local frames,step,last = {},1,begin + length - 1
    if isReversed then
        last, begin = begin, last
        step = -1
    end
    local frameName,frame
    for index = begin, last, step do
        frameName = string.format(pattern, index)
        frame = spriteFrameCache:getSpriteFrame(frameName)
        if not frame then
            error(string.format("display.newFrames() - invalid frame name %s", tostring(frameName)), 0)
        end
        table.insert(frames,frame)
    end
    return frames
end
local function newAnimation(frames, time)
    local count = #frames
    assert(count > 0, "display.newAnimation() - invalid frames")
    time = time or 1.0 / count
    return cc.Animation:createWithSpriteFrames(frames, time),
           cc.Sprite:createWithSpriteFrame(frames[1])
end
--[[
*	创建动画
*	@param 
*		2个参数：frames, time
*		4个参数：pattern, begin, length, time
*		5个参数：pattern, begin, length, isReversed, time
]]
function display.newAnimation(...)
    local params = {...}
    local c = #params
    if c == 2 then
        return newAnimation(params[1], params[2])
    elseif c == 4 then
        local frames = display.newFrames(params[1], params[2], params[3])
        return newAnimation(frames, params[4])
    elseif c == 5 then
        local frames = display.newFrames(params[1], params[2], params[3], params[4])
        return newAnimation(frames, params[5])
    else
        error("display.newAnimation() - invalid parameters")
    end
end
--缓存动画
function display.addAnimationCache(animation,name)
    animationCache:addAnimation(animation, name)
end
--获取缓存的动画
function display.getAnimationCache(name)
    return animationCache:getAnimation(name)
end
--移除动画缓存
function display.removeAnimationCache(name)
    animationCache:removeAnimation(name)
end
--移除未使用的纹理和frame缓存
function display.removeUnusedSpriteFrames()
    spriteFrameCache:removeUnusedSpriteFrames()
    textureCache:removeUnusedTextures()
end
--设置纹理加载格式
function display.setTexturePixelFormat(format)
	cc.Texture2D:setDefaultAlphaPixelFormat(format or cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
end
function display.getFullPath(path)
	return fileUtils:fullPathForFilename(path)
end
--[[
*	纹理加载
*	@imageFilename：纹理路径
*	@callback：回掉方法（异步）
]]
function display.loadImage(imageFilename, callback)
    if not callback then
        return textureCache:addImage(imageFilename)
    else
        textureCache:addImageAsync(imageFilename, callback)
    end
end
--加载资源plist
function display.loadSpriteFrames(dataFilename, imageFilename, callback)
    if not callback then
        spriteFrameCache:addSpriteFrames(dataFilename, imageFilename)
    else
        spriteFrameCache:addSpriteFramesAsync(dataFilename, imageFilename, callback)
    end
end
--移除纹理缓存
function display.removeTexture(imageFilename)
    textureCache:removeTextureForKey(imageFilename)
end
--移除纹理和plist缓存
function display.removeSpriteFrames(plistFilename, imageFilename)
    spriteFrameCache:removeSpriteFramesFromFile(plistFilename)
    display.removeTexture(imageFilename)
end
function display.c3b2c4b(color,alpha)
	return cc.c4b(color.r,color.g,color.b,alpha or 255)
end
-- ----------------------------------------------------UI----------------------------------------------------------------------
local extendcls = {
	CCNodeExtend = require("src.base.extend.CCNodeExtend"),
	CCLayerExtend = require("src.base.extend.CCLayerExtend"),
	CCSceneExtend = require("src.base.extend.CCSceneExtend"),
	CCSpriteExtend = require("src.base.extend.CCSpriteExtend"),
	UIWidgetExtend = require("src.base.extend.UIWidgetExtend"),
	UILayoutExtend = require("src.base.extend.UILayoutExtend"),
	CCDrawNodeExtend = require("src.base.extend.CCDrawNodeExtend"),
}
function display.extend(cls,obj)
	return extendcls[cls].extend(obj)
end
function display.newLayer()
    return cc.Layer:create()
end
function display.newNode()
	return cc.Node:create()
end

function display.newSpriteTexture(pTexture)
	return cc.Sprite:createWithTexture(pTexture)
end
function display.newSpriteFrameName(framename)
	return cc.Sprite:createWithSpriteFrameName(framename)
end
function display.newColorLayer(color)
    return cc.LayerColor:create(color or cc.c3b(0xff,0xff,0xff))
end
function display.newLayout(size)
	local layout = ccui.Layout:create()
	if size then layout:setContentSize(size) end
    return layout
end
function display.debugLayout(layout,color,opacity)
	layout:setBackGroundColor(color or cc.c3b(255,0,0))
	layout:setBackGroundColorOpacity(opacity or 125)
	layout:setBackGroundColorType(1)
	return layout
end
--自动回收纹理图片
function display.newDynamicImage(path)
	return require("src.base.control.DynamicImage").new(path)
end
--骨骼动画
function display.newSpine(skelet,tex,scale)
	return sp.SkeletonAnimation:create(skelet,tex,scale or 1)
end
--粒子动画
function display.newParticle(path)
	return cc.ParticleSystemQuad:create(path)
end
function display.newSprite(pszFileName)
	if pszFileName~=nil then
		if type(pszFileName) == "string" then
			if pszFileName:sub(1,1) == "#" then
				return cc.Sprite:create(pszFileName:sub(2))
			else
				return cc.Sprite:createWithSpriteFrameName(pszFileName)
			end
		else
			return cc.Sprite:createWithSpriteFrame(pszFileName)
		end
	end
	return cc.Sprite:create()
end
--[[
*	图片
*	@param：path 图片路径  加#表示从全路径读取图片
]]
function display.newImage(path)
	if not path then
		return ccui.ImageView:create()
	end
	if path:sub(1,1) == "#" then
		return ccui.ImageView:create(path:sub(2),0)
	else
		return ccui.ImageView:create(path,1)
	end
end
--[[
*	设置普通显示对象9宫格
*	@param target 目标
*	@param rect 9宫格区域
*	@param size 大小
]]
function display.setS9(target,rect,size)
	target:setScale9Enabled(true)
	target:setCapInsets(rect)
	if size then
		target:setContentSize(size)
	end
	return target
end
--[[
*	设置显示对象背景9宫格
*	@param target 目标
*	@param rect 9宫格区域
*	@param size 大小
]]
function display.setBgS9(target,rect,size)
	target:setBackGroundImageScale9Enabled(true)
	target:setBackGroundImageCapInsets(rect)
	if size then
		target:setContentSize(size)
	end
	return target
end
--[[
*	黑色遮罩
*	@param：size 遮罩尺寸（默认为全屏）
*	@param：opacity 透明度（默认为100）
*	@param: color 颜色（默认黑色）
]]
function display.newMask(size,opacity,color)
	local layout = display.newLayout(size or cc.size(D_SIZE.w,D_SIZE.h))
	layout:setTouchEnabled(true)
	layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	layout:setBackGroundColor(color or Color.BLACK)
	layout:setBackGroundColorOpacity(opacity or 100)
	return layout
end
--显示一个全屏遮罩
function display.showScreenMask(order,opacity)
	return display.getRunningScene():addScreenMask(order,opacity)
end
--移除全屏遮罩
function display.hideScreenMask()
	display.getRunningScene():removeScreenMask()
end
--[[
*	输入文本
*	@size 尺寸
*	@normalitem 普通状态皮肤
*	@fontsize 字体大小
*	@fontcolor 字体颜色
*	@fontname 字体
*	@placeholderStr 占位符
*	@placeholderColor 占位符颜色
*	@maxlen 显示最大长度默认(100)
*	@type 格式 默认 (cc.KEYBOARD_RETURNTYPE_DONE)
]]
function display.newInputText(size,normalitem,fontsize,fontcolor,fontname,placeholderStr,placeholderColor,maxlen,type,textureType)
	-- local inputtext = ccui.EditBox:create(size or cc.size(200,40), normalitem or ccui.Scale9Sprite:create(),ccui.Scale9Sprite:create(),ccui.Scale9Sprite:create())
	-- local inputtext = ccui.EditBox:create(size or cc.size(200,40), normalitem or "", textureType or ccui.TextureResType.localType)

	local inputtext = nil

	if normalitem == nil then
		inputtext = ccui.EditBox:create(size or cc.size(200,40),  ccui.Scale9Sprite:create())
	else
		inputtext = ccui.EditBox:create(size or cc.size(200,40), normalitem or "", textureType or ccui.TextureResType.localType)
	end

	inputtext:setFontSize(fontsize or Cfg.SIZE)
    inputtext:setFontColor(fontcolor or Cfg.COLOR)
	inputtext:setFontName(fontname or Cfg.FONT)
	inputtext:setPlaceholderFontSize(fontsize or Cfg.SIZE)
    inputtext:setPlaceHolder(placeholderStr or "")
    inputtext:setPlaceholderFontColor(placeholderColor or Color.GREY)
    inputtext:setMaxLength(maxlen or 100)
    inputtext:setReturnType(type or cc.KEYBOARD_RETURNTYPE_DONE)
    inputtext:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	inputtext:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_ALL_CHARACTERS)
    return inputtext
end
--[[
*	普通文本
*	@param：text 文本
*	@param：size 字体大小（默认为全局文字大小大小）
*	@param：color 字体颜色（默认为全局文字颜色）
*	@param: name 字体
]]
function display.newText(text,size,color,name)
    local label = ccui.Text:create(text,Cfg.FONT,size or 24)
	label:setColor(color or Cfg.COLOR)
	if name then
		label:setFontName(name)
	end
	return label
end

function display.newNumberText(value,size,color,name)
    local label = ccui.Text:create("",Cfg.FONT,size or 24)
	label:setColor(color or Cfg.COLOR)
	require("src.command.NumberEffect").extend(label)
	if value then
		label:setFormatNumber(value)
	end
	if name then
		label:setFontName(name)
	end
	return label
end

--[[
*	富文本
*	@param：text 文本
*	@param：size 字体大小（默认为全局文字大小大小）
*	@param: name 字体
*	@param：color 字体颜色（默认为全局文字颜色）
*	@param：style css样式表
]]
function display.newRichText(text,size,color,name,style)
	local label = require("src.base.control.label.LabelElement").new(text,size,color,name,style)
	return label
end
--[[
*	可滚动富文本
*	@param：text 文本
*	@param：fontsize 字体大小（默认为全局文字大小大小）
*	@param：fontcolor 字体颜色（默认为全局文字颜色）
*	@param: fontname 字体
*	@param：style css样式表
*	@param：size 滚动区域
]]
function display.newTextArea(text,fontsize,fontcolor,fontname,style,size)
	local label = require("src.base.control.label.LabelArea").new(text,fontsize,fontcolor,fontname,style,size)
	return label
end

--[[
*	扩展按钮点击音效
*	所有扩展的按钮预留 属性 _m_pressSound 
]]
function display.extendButtonToSound(tagetBtn,soundname)
	tagetBtn._m_addTouchEventListener = tagetBtn.addTouchEventListener
	tagetBtn._m_pressSound = soundname or "main_sound_click"
	
    function tagetBtn:addTouchEventListener(callback)
    	self._m_callback = callback
    end
    tagetBtn:_m_addTouchEventListener(function(t,e) 
    	if e == ccui.TouchEventType.began then 
    		if tagetBtn._m_pressSound ~= "nosound" then
    			SoundsManager.playSound(t._m_pressSound)
    		end
		end
		if t._m_callback then
			t._m_callback(t,e)
		end
    end)
end
--[[
*	按钮
*	@param：normalpath 正常皮肤路径
*	@param：selectpath 点击皮肤路径
*	@param：disablepath 禁用皮肤路径
*	@param：type 默认为（1）plist 图片
]]
function display.newButton(normalpath,selectpath,disablepath,type)
	local resType = 0

	if type == 1 or type == nil then
		resType = 1
	end

	local btn=ccui.Button:create(normalpath,selectpath,disablepath,resType)
--	btn:setPressedActionEnabled(true)
    btn:setTouchEnabled(true)
    display.extendButtonToSound(btn)
    return btn
end
--[[
*	文本按钮
*	@param：normalpath 正常皮肤路径
*	@param：selectpath 点击皮肤路径
*	@param：disablepath 禁用皮肤路径
*	@param：type 默认为（1）plist 图片
*	@param：text 文本
*	@param：fontsize 字体大小（默认为全局文字大小大小）
*	@param：fontcolor 字体颜色（默认为全局文字颜色）
]]
function display.newTextButton(normalpath,selectpath,disablepath,type,text,fontsize,fontcolor)
	local btn = display.newButton(normalpath,selectpath,disablepath,type or 1)
--	btn:setPressedActionEnabled(true)
	btn:setTitleFontName(Cfg.FONT)
	btn:setTitleText(text)
	btn:setTitleFontSize(fontsize or Cfg.SIZE)
	btn:setTitleColor(fontcolor or Cfg.COLOR)
	
	display.extendButtonToSound(btn)
    
	return btn
end
--[[
*	滚动列表
*	@param：direction 滚动方向（默认垂直滚动）
*	@param：gravity 对齐方式（默认垂直居中对齐）
*	@param：interval 元素间隔（默认0）
*	@param：bounce 是否回弹（默认false）
]]
function display.newListView(direction,gravity,interval,bounce)
	local listview = ccui.ListView:create()
	listview:setScrollBarEnabled(false)
	listview:setDirection(direction or ccui.ScrollViewDir.vertical)
	listview:setGravity(gravity or ccui.ListViewGravity.centerHorizontal)
	listview:setItemsMargin(interval or 0)
	if bounce then
		listview:setBounceEnabled(true)
	end
	listview:setTouchEnabled(true)
	return listview
end
--[[
*	滚动层
*	@param：direction 滚动方向（默认所有方向）
*	@param：bounce 是否回弹（默认false）
]]
function display.newScrollView(direction,bounce)
	local scrollview = ccui.ScrollView:create()
	scrollview:setScrollBarEnabled(false)
	scrollview:setDirection(direction or ccui.ScrollViewDir.both)
	if bounce then
		scrollview:setBounceEnabled(true)
	end
	scrollview:setTouchEnabled(true)
	return scrollview
end
--翻页层
function display.newPageView()
	local pageview = ccui.PageView:create()
	pageview:setTouchEnabled(true)
	return pageview
end
--[[
*	选中框
*	@param：backGround 背景
*	@param：backGroundSelected 背景点击状态
*	@param：cross 前景
*	@param：backGroundDisabled 背景禁用状态
*	@param：frontCrossDisabled 前景禁用状态
*	@param：type （默认为 1）
]]
function display.newCheckBox(backGround,backGroundSelected,cross,backGroundDisabled,frontCrossDisabled,type)
	backGroundDisabled = backGroundDisabled or ""
	frontCrossDisabled = frontCrossDisabled or ""
	local checkBox = ccui.CheckBox:create(backGround,backGroundSelected,cross,backGroundDisabled,frontCrossDisabled,type or 1)
	checkBox:setTouchEnabled(true)
	return checkBox
end
--[[
*	进度条，如果不穿任何参数将会给一个默认进度条
*	@param:p1 进度条皮肤
]]
function display.newProgress(p1)
	return require("src.base.control.ProgressComponent").new(p1)
end
--[[
*	滑动槽
]]
function display.newRichSlider()
	
end
--[[
*	显示 通用提示框
*	@param：info 为table对象，可识别参数如下
*	{
 		info:			显示信息（可以是纯文字，也可以是一个layout）
 		title：			标题文字（默认为“提 示”）
 		vtype：			（只有当info为纯文字时，才有效，垂直对齐方式<默认居中>）
 		htype：			（只有当info为纯文字时，才有效，水平对齐方式<默认居中>）
 		color：			字体颜色（默认为全局字体颜色，棕色）
 		leader：			行间距（默认为3）
 		size：			字体大小（默认为全局字体大小，26）
 		callback：		回调函数
 		priority：		优先级（默认为10，值越小，优先级越高，优先级高的弹窗会覆盖比当前优先级低的弹窗）
 		confirmtext：	确认按钮文字(无文字则使用图标)
 		canceltext：		取消按钮文字(无文字则使用图标)
 		mask：			（默认为flase）该参数为true实现触摸任何区域提示框关闭
 		nottouchclose:	是否不启用 点击空白区域关闭提示框（默认为false启用）
 		flag：			标记参数（默认为ST.TYPE_POP_FLAG_1<可选ST.TYPE_POP_FLAG_1,ST.TYPE_POP_FLAG_2>；FLAG_1：显示两个按钮；FLAG_2：只显示一个按钮；）
	}
]]
function display.showPop(info)
	require("src.base.control.PopControl").show(info)
end

function display.closePop()
	require("src.base.control.PopControl").hide()
end
--[[
*	显示loading蒙版
*	@param info			文本信息
*	@param delay		延迟多少时间显示，默认为0
*	@param socketid		默认为主socket
*	@param duration		持续时间，默认值为18s，18s过后还没被关闭则认为连接超时
*	@param callback		如果修改了duration，则可以添加该参数进行自定义处理
]]
function display.showLoading(info,delay,socketid--[[=nil]],duration--[[=18]],callback --[[=nil]])
	require("src.base.control.LoadingMaskControl").show(info,delay,socketid,duration,callback)
end
--关闭 loading 条
function display.closeLoading()
	require("src.base.control.LoadingMaskControl").hide()
end
--[[
*	显示 提示信息
*	param:message		显示信息
*	param:fontsize		字体大小（可选参数） 默认为32
]]
function display.showMsg(message,fontsize--[[=32]])
	require("src.base.control.ScreenMessageControl").show(message,fontsize)
end
--获取多分辨率图片路径
function display.getResolutionPath(path)
	if D_SIZE.is9_16 then
		return "res/images/resolution/9_16/" .. path
	else
		return "res/images/resolution/3_4/" .. path
	end
end

local languageTransTool = require("src.base.tools.languagetrs")
--[[
*	加载语言包
*	@param localCode 语言标记(列：中国简体(sc)，英文（en）),默认加载系统地区对应语言
*	@param path 语言路径前缀
]]
function display.loadLanguage(localCode,front_path)
	front_path = front_path or "src.command.language.language"
	localCode = localCode or require("src.base.tools.versionMgr").getLocalCode()
	local path = string.format("%s_%s",front_path,localCode)
	mlog(DEBUG_W,string.format("load local language file path : %s",path))
	languageTransTool.setLanguage(reload(path))
end
--获取语言包语言
function display.trans(id,...)
	return languageTransTool.transform(id,...)
end

display.SCENE_TRANSITIONS = {
    CROSSFADE       = {cc.TransitionCrossFade},
    FADE            = {cc.TransitionFade, cc.c3b(0, 0, 0)},
    FADEBL          = {cc.TransitionFadeBL},
    FADEDOWN        = {cc.TransitionFadeDown},
    FADETR          = {cc.TransitionFadeTR},
    FADEUP          = {cc.TransitionFadeUp},
    FLIPANGULAR     = {cc.TransitionFlipAngular, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    FLIPX           = {cc.TransitionFlipX, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    FLIPY           = {cc.TransitionFlipY, cc.TRANSITION_ORIENTATION_UP_OVER},
    JUMPZOOM        = {cc.TransitionJumpZoom},
    MOVEINB         = {cc.TransitionMoveInB},
    MOVEINL         = {cc.TransitionMoveInL},
    MOVEINR         = {cc.TransitionMoveInR},
    MOVEINT         = {cc.TransitionMoveInT},
    PAGETURN        = {cc.TransitionPageTurn, false},
    ROTOZOOM        = {cc.TransitionRotoZoom},
    SHRINKGROW      = {cc.TransitionShrinkGrow},
    SLIDEINB        = {cc.TransitionSlideInB},
    SLIDEINL        = {cc.TransitionSlideInL},
    SLIDEINR        = {cc.TransitionSlideInR},
    SLIDEINT        = {cc.TransitionSlideInT},
    SPLITCOLS       = {cc.TransitionSplitCols},
    SPLITROWS       = {cc.TransitionSplitRows},
    TURNOFFTILES    = {cc.TransitionTurnOffTiles},
    ZOOMFLIPANGULAR = {cc.TransitionZoomFlipAngular},
    ZOOMFLIPX       = {cc.TransitionZoomFlipX, cc.TRANSITION_ORIENTATION_LEFT_OVER},
    ZOOMFLIPY       = {cc.TransitionZoomFlipY, cc.TRANSITION_ORIENTATION_UP_OVER},
}

setmetatable(display,{
	__index = {},
	__newindex = function(t,k,v)
		error(string.format("<display> attempt to read undeclared variable <%s>",k))
	end
})

Gbv.display = display

return display