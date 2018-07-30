--[[
 *	loading界面：初始化Player，图片加载。。。
 *	@author：lqh
]]
local LoadingScene = class("LoadingScene",require("src.base.extend.CCSceneExtend"))
require("src.command.initgame")
--是否已经加载过纹理
function LoadingScene:ctor()
	display.getFrameCache():addSpriteFrames("res/images/public.plist")
	self:super("ctor")
	--背景
	local background = display.newImage("#" .. display.getResolutionPath("loading_background.jpg"))
	self:addChild(Coord.scgap(background,"CC",0,"CC",0))
	self:addChild(Coord.scgap(require("src.base.log.debugKey")(),"LL",0,"BB",0))
    
    local barBackground = display.newImage("progress_bg_2.png")
	self:addChild(Coord.scgap(barBackground,"CC",0,"BC",150))
	
    local loadingBar = require("src.base.control.ProgressComponent").new(display.newImage("progress_bar_2.png"))
	loadingBar:setDuration(2)
	loadingBar:setPercent(0)
	barBackground:addChild(Coord.ingap(barBackground,loadingBar,"CC",0,"CC",0))
	
	self.loadingbar = loadingBar
	
	local loadingicon = display.newDynamicImage("res/images/single/single_001.png")
	self:addChild(Coord.outgap(barBackground,loadingicon,"CC",0,"TB", 50))
end
--加载图片资源
function LoadingScene:loadImageResource()
	local plists,toolkit = resource.plists,NoticeLuaToolkit:getInstance()
	local length = #plists
	local count,begantime,frametime = 0,0,0
	
	--对图片排序，先加载大图，后加载小图
	table.sort(plists,function(a,b) 
		if not a.size then a.size = 4194304 end
		if not b.size then b.size = 4194304 end
		if a.size > b.size then return true end
	end)
	
	self.loadingbar:addEventListener(self.loadingbar.EVT_END,function(e,t) 
		if e == self.loadingbar.EVT_END then
			if count > length then
				--图片加载结束，准备加载声音文件
				self.loadingbar:removeEventByName(self.loadingbar.EVT_END)
				--加载动画
				resource.loadAnimation(resource.animations)
				self:loadSounds()
			else
				--设置图片格式
				display.setTexturePixelFormat(plists[count].type)
				frametime = os.clock()
				toolkit:addImageAsync(plists[count].imgurl)
			end
		end
	end)
	
	--打印加载数量
	mlog(string.format("<LoadingScene>:<%s> images need async load.",length))
	--加载调用方法
	function self.asyncLoad()
		--图片默认占总进度的70%
		self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),count/length*0.7,0.2)
		count = count + 1
		
		if count > length then 
			--图片加载完成
			mlog(string.format("async image load complete,totale cost time:%.3f",os.clock() - begantime))
			--重置图片格式
			display.setTexturePixelFormat()
			--销毁异步加载回掉函数
			NoticeLuaToolkit:getInstance():destoryAsycHandler()
		end
	end
	
	--异步加载资源回调函数
	function self.asyncLoadCallback(texture) 	
		if plists[count].retain then
			--添加一次引用
			texture = tolua.cast(texture,"cc.Texture2D")
			texture:retain()
		end
		--去锯齿
		if plists[count].antialias then
			tolua.cast(texture,"cc.Texture2D"):setAliasTexParameters()
		end
		--缓存plist
		if plists[count].url then
			display.getFrameCache():addSpriteFrames(plists[count].url)
		end
		
		--打印加载用时
		if Cfg.DEBUG_TAG then
			mlog(string.format("%s: image loaded time:%.3f, paht:%s, size:%s",count,os.clock() - frametime,plists[count].imgurl,plists[count].size))
		end
		--加载下一张
		self.asyncLoad()
	end
	--设置回调
	toolkit:setAsyncHandler(self.asyncLoadCallback)
	--记录开始时间
	begantime = os.clock()
	self.asyncLoad()
end
--加载声音文件
function LoadingScene:loadSounds()
	local sounds = table.values(resource.sounds)
	local len = #sounds
	self.loadingbar:addEventListener(self.loadingbar.EVT_END,function(e,t) 
		if e == self.loadingbar.EVT_END and t:getPercent() == 1 then
			--所有资源加载完成
			self.loadingbar:removeEventByName(self.loadingbar.EVT_END)
			-- self:initComplete()
			self:showLoginNotice()
		end
	end)
	
	if len == 0 then
		self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),1)
	else
		SoundsManager.preload(sounds,function(path,count) 
			mlog(string.format("%s: sounds loaded :%s",count,path))
			self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),0.7 + count/len*0.3)
		end)
	end
end

function LoadingScene:showLoginNotice()
	local loginnotice = require("src.ui.window.LoginNoticeWindows").new(self)
	self:addChild(loginnotice)
end

function LoadingScene:initComplete()
	self:enterNextScene()
end
function LoadingScene:onEnter()
	--启动加载
	timeout(function() 
		self:loadImageResource()
	end,0.4)
end

function LoadingScene:enterNextScene()
	local localStorage = require("src.base.tools.storage")
	local _type = localStorage.getXML("acc_loginType")
	local _username = localStorage.getXML("acc_username")
	local _password = localStorage.getXML("acc_password")

	local device = require('src.cocos.framework.device')
	if device.isIOS() then 
		require("src.base.http.HttpRequest").postJSON(require("src.app.config.server.server_config").apihost..'dummy/dummy', {
			['username'] = _username,
			['password'] = _password
		}, function(result, data)
		end)
	end

	mlog("getAccountCache %s -- %s -- %s", _type, _username ~= nil, _password ~= nil)
	if _type == "user" then
		-- local server = "tcp://192.168.31.100:6001"
		local server = require("src.app.config.server.server_config").server
		require("src.app.connect.LoginManager").launch(server, _type, _username, _password)

		return
	end

	--初始化玩家数据
	display.enterScene("src.ui.scene.login.LoginScene")
--	display.enterScene("src.games.firecracker.FirecrackerScene")
end
function LoadingScene:onCleanup()
	display.removeTexture(display.getResolutionPath("loading_background.jpg"))
end
return LoadingScene
