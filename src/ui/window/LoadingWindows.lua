--[[
*	资源loading Window
*	@author：lqh
]]
local LoadingWindows = class("LoadingWindows",BaseWindow)
function LoadingWindows:ctor(roomdata)
	self:super("ctor")

	if Cfg.DEBUG_TAG then
		mlog(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
		mlog(string.format("↑↑↑↑↑↑%s↑↑↑↑↑↑加载前纹理缓存资源\n---------------------------------------------------------\n",roomdata.game.name))
	end
	
	local bg = display.newDynamicImage(string.format("game/%s/game_loading_bg.png",roomdata.game.key))
	bg:setScale(1.61)
	self:addChild(Coord.scgap(bg,"CC",0,"CC",0,true))

	local barBackground = display.setS9(display.newImage("progress_bg_3.png"),cc.rect(20,15,60,5),cc.size(700,35))
	self:addChild(Coord.scgap(barBackground,"CC",0,"BB",80))

	local loadingBar = require("src.base.control.ProgressComponent").new(
		display.setS9(display.newImage("progress_bar_3.png"),cc.rect(20,10,60,5),cc.size(690,25))
	)
	loadingBar:setDuration(4)
	loadingBar:setPercent(0)
	barBackground:addChild(Coord.ingap(barBackground,loadingBar,"CC",0,"CC",0))
	
	self.loadingbar = loadingBar
	
	local progressTxt = display.newText(display.trans("##2048",0),36)
	self:addChild(Coord.outgap(barBackground,progressTxt ,"CC",0,"BT",-5))
	
	loadingBar:addEventListener(self.loadingbar.EVT_CHANGE,function(e,t)
		progressTxt:setString(display.trans("##2048",math.floor(t:getPercent() * 100)))
	end)
	
	self.m_roomdata = roomdata
	timeout(self.onInitNet,0.2,self)
end
function LoadingWindows:onInitNet()
	local res = require(self.m_roomdata.game.resourcecfg)
	
	local function handleComplete(e,t)
		if e == self.loadingbar.EVT_END and t:getPercent() == 0.1 then
			self:onImageLoading()
		end
	end
	
	self.loadingbar:addEventListener(self.loadingbar.EVT_END,handleComplete)
	if res.initNet then
		res.initNet(self.m_roomdata.game.ipaddress,function(socketID)
			if socketID <= 0 then
				self.loadingbar:removeEventListener(self.loadingbar.EVT_END,handleComplete)
			
				display.showMsg(string.format("连接\"%s\"游戏服务器失败！",self.m_roomdata.game.name))
				self:executQuit()
			else
				self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),0.1)
			end
		end)
	else
		self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),0.1)
	end
end
function LoadingWindows:onImageLoading()
	local res = require(self.m_roomdata.game.resourcecfg)
	local plists = res.plists
	local length = #plists
	local count = 1

	--对图片排序，先加载大图，后加载小图
	table.sort(plists,function(a,b)
		if not a.size then a.size = 4194304 end
		if not b.size then b.size = 4194304 end
		if a.size > b.size then return true end
	end)

	local function loadTextureCallback(texture)
		texture = tolua.cast(texture,"cc.Texture2D")
		if plists[count].retain then
			--添加一次引用
			texture:retain()
		end
		--去锯齿
		if plists[count].antialias then
			texture:setAliasTexParameters()
		end
		--缓存plist
		if plists[count].url then
			display.getFrameCache():addSpriteFrames(plists[count].url)
		end
		--图片默认占总进度的70%
		self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),0.1 + count/length*0.7,0.2)
		count = count + 1

		if count > length then
			--重置图片格式
			display.setTexturePixelFormat()
		end
	end
	self.loadingbar:addEventListener(self.loadingbar.EVT_END,function(e,t)
		if e == self.loadingbar.EVT_END then
			if count > length then
				--图片加载结束，准备加载声音文件
				self.loadingbar:removeEventByName(self.loadingbar.EVT_END)
				--加载动画
				resource.loadAnimation(res.animations)
				self:onSoundLoading()
			else
				--设置图片格式
				display.setTexturePixelFormat(plists[count].type or cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
				display.loadImage(plists[count].imgurl, loadTextureCallback)
			end
		end
	end)
	--设置图片格式
	display.setTexturePixelFormat(plists[count].type)
	display.loadImage(plists[count].imgurl, loadTextureCallback)
end
--音乐加载
function LoadingWindows:onSoundLoading()
	local res = require(self.m_roomdata.game.resourcecfg)
	res.gamekey = self.m_roomdata.game.key
	local sounds = res.sounds
	local len = #sounds
	local count = 0

	self.loadingbar:addEventListener(self.loadingbar.EVT_END,function(e,t)
		if e == self.loadingbar.EVT_END and count >= len then
			--所以资源加载完成
			self.loadingbar:removeEventByName(self.loadingbar.EVT_END)
			self:initGame()
		end
	end)

	if len == 0 then
		self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),1)
	else
		SoundsManager.preload(sounds,function(path,ct)
			count = ct
			self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),0.8 + count/len*0.1)
		end,res.gamekey)
	end
end
--初始化游戏
function LoadingWindows:initGame()
	local res = require(self.m_roomdata.game.resourcecfg)
	
	local function handleComplete(e,t)
		if e == self.loadingbar.EVT_END and t:getPercent() == 1 then
			self:loadComplete()
		end
	end
	
	self.loadingbar:addEventListener(self.loadingbar.EVT_END,handleComplete)
	if res.initGame then
		res.initGame(self.m_roomdata,function(succ)
			if succ == true then
				self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),1)
			else
				self.loadingbar:removeEventListener(self.loadingbar.EVT_END,handleComplete)
			
				display.showMsg(string.format("登录\"%s\"游戏服务器失败！",self.m_roomdata.game.name))
				self:executQuit()
			end
		end)
	else
		self.loadingbar:setPercentFrom(self.loadingbar:getPercent(),1)
	end
end
--加载完成
function LoadingWindows:loadComplete()
	local room = self.m_roomdata
	self:executQuit()
	if Cfg.DEBUG_TAG then
		mlog(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
		mlog(string.format("↑↑↑↑↑↑%s↑↑↑↑↑↑加载完成后纹理缓存资源，涨了多少内存心里没点B数吗？\n---------------------------------------------------------\n",room.game.name))
	end
		
	display.enterScene(room.game.path,{room})
end
--@override
function LoadingWindows:onCleanup()
	self:super("onCleanup")
end

return LoadingWindows
