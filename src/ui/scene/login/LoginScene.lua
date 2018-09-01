--[[
*	登陆界面
]]
local LoginScene = class("LoginScene",require("src.base.extend.CCSceneExtend"))

local doLogin = function(self, loginType, username, password)
	--保存账号密码
	local storage = require("src.base.tools.storage")
	storage.saveXML('acc_loginType', loginType)
	storage.saveXML('acc_username', username)
	storage.saveXML('acc_password', password)

	-- local server = "tcp://192.168.31.100:6001"
	local server = require("src.app.config.server.server_config").server
	require("src.app.connect.LoginManager").launch(server, loginType, username, password)
end

-- local initRegView = function(self)
-- 	local node = display.newNode()
-- 	node:setAnchorPoint(cc.p(0.5,0.5))
-- 	-- node:setPosition(cc.p(D_SIZE.hw, D_SIZE.hh))

-- 	self.regView = node

-- 	local username = display.newInputText(
-- 		cc.size(600, 80), "login_ui_placeholder.png",
-- 		40, cc.c3b(255,255,255), nil, "请输入账号", cc.c3b(240,240,240), nil, nil, ccui.TextureResType.plistType
-- 	)
-- 	node:addChild(Coord.scgap(username,"CC",0,"CC",120))
	
-- 	local password = display.newInputText(
-- 		cc.size(600, 80), "login_ui_placeholder.png",
-- 		40, cc.c3b(255,255,255), nil, "请输入密码", cc.c3b(240,240,240), nil, nil, ccui.TextureResType.plistType
-- 	)
-- 	node:addChild(Coord.scgap(password,"CC",0,"CC",20))

-- 	local confirm = display.newInputText(
-- 		cc.size(600, 80), "login_ui_placeholder.png",
-- 		40, cc.c3b(255,255,255), nil, "请再次输入密码", cc.c3b(240,240,240), nil, nil, ccui.TextureResType.plistType
-- 	)
-- 	node:addChild(Coord.scgap(confirm,"CC",0,"CC",-80))

-- 	local loginBtn = display.newButton('popui_btn_001.png','popui_btn_001.png','popui_btn_001.png')
-- 	loginBtn:setTouchEnabled(true)
-- 	loginBtn:addTouchEventListener(function(t, e)
-- 		if e ~= ccui.TouchEventType.ended then return end

-- 		if self.sending then return end
-- 		--登陆按钮
-- 		local _username = username:getText()
-- 		local _password = password:getText()
-- 		local _confirm = confirm:getText()

-- 		if _username == "" then
-- 			display.showMsg("请输入账号")
-- 			return
-- 		end

-- 		if _password == "" then
-- 			display.showMsg("请输入密码")
-- 		end

-- 		if _username == "" or _password == "" then
-- 			return
-- 		end

-- 		if _password ~= _confirm then
-- 			display.showMsg("两次输入密码不一致")
-- 			return
-- 		end
		
-- 		self.sending = true

-- 		mlog(DEBUG_E, require("src.app.config.server.server_config").apihost)

-- 		require("src.base.http.HttpRequest").postJSON(require("src.app.config.server.server_config").apihost..'auth/register', {
-- 			['username'] = _username,
-- 			['password'] = _password
-- 		}, function(result, data)
-- 			self.sending = false

-- 			if data == nil then
-- 				display.showMsg("注册失败")
-- 			end

-- 			if data["errno"] ~= 0 then
-- 				display.showMsg(data["errmsg"] or "注册失败")
-- 			end

-- 			display.showMsg("注册成功")

-- 			--注册成功，直接进入登陆流程
-- 			--进入登陆流程
-- 			doLogin(self, "user", _username, _password)
-- 		end)
-- 	end)
-- 	loginBtn:setAnchorPoint(cc.p(0.5,0.5))
-- 	loginBtn:addChild(Coord.ingap(loginBtn, display.newText("登陆",30), "CC", 0, "CC", 0))
-- 	loginBtn:setPosition(cc.p(D_SIZE.hw - 100, 160))
-- 	node:addChild(loginBtn)

-- 	local regBtn = display.newButton('popui_btn_001.png','popui_btn_001.png','popui_btn_001.png')
-- 	regBtn:setTouchEnabled(true)
-- 	regBtn:addTouchEventListener(function(t, e)
-- 		if e ~= ccui.TouchEventType.ended then return end

-- 		self.regView:setVisible(false)
-- 		self.loginView:setVisible(true)
-- 	end)
-- 	regBtn:setAnchorPoint(cc.p(0.5,0.5))
-- 	regBtn:addChild(Coord.ingap(regBtn, display.newText("返回",30), "CC", 0, "CC", 0))
-- 	regBtn:setPosition(cc.p(D_SIZE.hw + 100, 160))
-- 	node:addChild(regBtn)

-- 	self.regView = node
-- end

-- local initLoginView = function(self)
-- 	local node = display.newNode()
-- 	node:setAnchorPoint(cc.p(0.5,0.5))
-- 	-- node:setPosition(cc.p(D_SIZE.hw, D_SIZE.hh))

-- 	local username = display.newInputText(
-- 		cc.size(600, 80), "login_ui_placeholder.png",
-- 		40, cc.c3b(255,255,255), nil, "请输入账号", cc.c3b(240,240,240), nil, nil, ccui.TextureResType.plistType
-- 	)
-- 	node:addChild(Coord.scgap(username,"CC",0,"CC",120))
	
-- 	local password = display.newInputText(
-- 		cc.size(600, 80), "login_ui_placeholder.png",
-- 		40, cc.c3b(255,255,255), nil, "请输入密码", cc.c3b(240,240,240), nil, nil, ccui.TextureResType.plistType
-- 	)
-- 	node:addChild(Coord.scgap(password,"CC",0,"CC",20))

-- 	local loginBtn = display.newButton('popui_btn_001.png','popui_btn_001.png','popui_btn_001.png')
-- 	loginBtn:setTouchEnabled(true)
-- 	loginBtn:addTouchEventListener(function(t, e)
-- 		if e ~= ccui.TouchEventType.ended then return end

-- 		local _username = username:getText()
-- 		local _password = password:getText()

-- 		if _username == "" then
-- 			display.showMsg("请输入账号")
-- 		end

-- 		if _password == "" then
-- 			display.showMsg("请输入密码")
-- 		end

-- 		doLogin(self, "user", _username, _password)
-- 	end)
-- 	loginBtn:setAnchorPoint(cc.p(0.5,0.5))
-- 	loginBtn:addChild(Coord.ingap(loginBtn, display.newText("登陆",30), "CC", 0, "CC", 0))
-- 	loginBtn:setPosition(cc.p(D_SIZE.hw - 100, 230))
-- 	node:addChild(loginBtn)

-- 	local regBtn = display.newButton('popui_btn_001.png','popui_btn_001.png','popui_btn_001.png')
-- 	regBtn:setTouchEnabled(true)

-- 	regBtn:addTouchEventListener(function(t, e)
-- 		if e ~= ccui.TouchEventType.ended then return end

-- 		if self.regView == nil then
-- 			initRegView(self)

-- 			self:addChild(self.regView)
-- 		end
-- 		self.loginView:setVisible(false)
-- 		self.regView:setVisible(true)
-- 	end)
-- 	regBtn:setAnchorPoint(cc.p(0.5,0.5))
-- 	regBtn:addChild(Coord.ingap(regBtn, display.newText("注册",30), "CC", 0, "CC", 0))
-- 	regBtn:setPosition(cc.p(D_SIZE.hw + 100, 230))
-- 	node:addChild(regBtn)

-- 	local localStorage = require("src.base.tools.storage")
-- 	local _type = localStorage.getCustom("account", "type")
-- 	local _username = localStorage.getCustom("account", "username")
-- 	local _password = localStorage.getCustom("account", "password")
-- 	mlog("getAccountCache", _type, _username, _password)
-- 	if _type ~= nil and type == "user" then
-- 		username:setText(_username)
-- 		password:setText(_password)
-- 	end

-- 	self.loginView = node
-- end

local initRegView = function(self)
	local node = display.newNode()

	local loginFrameBG = display.newImage("#res/images/login/scale9/ui_772_tk_di1.png")
	display.setS9(loginFrameBG, cc.rect(28, 32, 90, 546), cc.size(D_SIZE.hw, D_SIZE.hh * 3 / 4))
	loginFrameBG:setPosition(cc.p(D_SIZE.hw, D_SIZE.hh))
	node:addChild(loginFrameBG)

	local usernameLabel = display.newText(display.trans("##20043"), 30, cc.c3b(12, 49, 144))
	local passwordLabel = display.newText(display.trans("##20044"), 30, cc.c3b(12, 49, 144))
	local confirmLabel = display.newText(display.trans("##20045"), 30, cc.c3b(12, 49, 144))
	loginFrameBG:addChild(usernameLabel)
	loginFrameBG:addChild(passwordLabel)
	loginFrameBG:addChild(confirmLabel)

	local p = cc.p(45, loginFrameBG:getContentSize().height - 60)
	usernameLabel:setAnchorPoint(cc.p(0, 0.5))
	usernameLabel:setPosition(p)
	
	passwordLabel:setAnchorPoint(cc.p(0, 0.5))
	passwordLabel:setPosition(cc.p(p.x, p.y - 75))

	confirmLabel:setAnchorPoint(cc.p(0, 0.5))
	confirmLabel:setPosition(cc.p(p.x, p.y - 150))

	local loginFrameBGSize = loginFrameBG:getContentSize()

	local username = display.newInputText(
		cc.size(loginFrameBGSize.width - p.x * 4 - confirmLabel:getContentSize().width, 50), "res/images/login/ui_772_grxx_ghtxdi.png",
		25, cc.c3b(255,255,255), nil, display.trans("##20046"), cc.c3b(76,175,232), nil, nil, ccui.TextureResType.localType
	)
	local password = display.newInputText(
		cc.size(loginFrameBGSize.width - p.x * 4 - confirmLabel:getContentSize().width, 50), "res/images/login/ui_772_grxx_ghtxdi.png",
		25, cc.c3b(255,255,255), nil, display.trans("##20047"), cc.c3b(76,175,232), nil, nil, ccui.TextureResType.localType
	)
	local confirm = display.newInputText(
		cc.size(loginFrameBGSize.width - p.x * 4 - confirmLabel:getContentSize().width, 50), "res/images/login/ui_772_grxx_ghtxdi.png",
		25, cc.c3b(255,255,255), nil, display.trans("##20048"), cc.c3b(76,175,232), nil, nil, ccui.TextureResType.localType
	)

	password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)
	confirm:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)

	username:setAnchorPoint(cc.p(0, 0.5))
	password:setAnchorPoint(cc.p(0, 0.5))
	confirm:setAnchorPoint(cc.p(0, 0.5))

	loginFrameBG:addChild(username)
	loginFrameBG:addChild(password)
	loginFrameBG:addChild(confirm)

	username:setPosition(cc.p(p.x + confirmLabel:getContentSize().width + 15, p.y))
	password:setPosition(cc.p(p.x + confirmLabel:getContentSize().width + 15, p.y - 75))
	confirm:setPosition(cc.p(p.x + confirmLabel:getContentSize().width + 15, p.y - 150))

	local loginBtn = display.newButton('res/images/login/ui_772_dl_an_di2.png','res/images/login/ui_772_dl_an_di2.png','res/images/login/ui_772_dl_an_di2.png', 0)
	loginBtn:setTouchEnabled(true)
	loginBtn:addTouchEventListener(function(t, e)
		if e ~= ccui.TouchEventType.ended then return end

		if self.sending then return end

		local _username = username:getText()
		local _password = password:getText()
		local _confirm = confirm:getText()

		if _username == "" then
			display.showMsg(display.trans("##20046"))
			return
		end

		if _password == "" then
			display.showMsg(display.trans("##20047"))
			return
		end

		if _confirm ~= _password then
			display.showMsg(display.trans("##20049"))
			return
		end

		self.sending = true

		mlog(DEBUG_E, require("src.app.config.server.server_config").apihost)

		require("src.base.http.HttpRequest").postJSON(require("src.app.config.server.server_config").apihost..'auth/register', {
			['username'] = _username,
			['password'] = _password
		}, function(result, data)
			self.sending = false

			if data == nil then
				display.showMsg(display.trans("##50100"))
				return
			end

			if data["errno"] ~= 0 then
				display.showMsg(data["errmsg"] or display.trans("##50100"))
				return
			end

			display.showMsg(display.trans("##20050"))

			--注册成功，直接进入登陆流程
			--进入登陆流程
			doLogin(self, "user", _username, _password)
		end)
	end)
	loginBtn:setAnchorPoint(cc.p(1,0.5))
	loginBtn:addChild(Coord.ingap(loginBtn, display.newImage("#res/images/login/ui_772_dl_zhzc.png"), "CC", 0, "CC", 0))
	loginBtn:setPosition(cc.p(D_SIZE.hw - 40, D_SIZE.hh - loginBtn:getContentSize().width - 30))
	node:addChild(loginBtn)

	local regBtn = display.newButton('res/images/login/ui_772_dl_an_di3.png','res/images/login/ui_772_dl_an_di3.png','res/images/login/ui_772_dl_an_di3.png', 0)
	regBtn:setTouchEnabled(true)
	regBtn:addTouchEventListener(function(t, e)
		if e ~= ccui.TouchEventType.ended then return end

		self.loginView:setVisible(true)
		self.regView:setVisible(false)
	end)
	regBtn:setAnchorPoint(cc.p(0,0.5))
	regBtn:addChild(Coord.ingap(regBtn, display.newImage("#res/images/login/ui_772_dl_fhdl.png"), "CC", 0, "CC", 0))
	regBtn:setPosition(cc.p(D_SIZE.hw + 40, D_SIZE.hh - loginBtn:getContentSize().width - 30))
	node:addChild(regBtn)

	self.regView = node
end

local initLoginView = function(self)
	local node = display.newNode()

	local loginFrameBG = display.newImage("#res/images/login/scale9/ui_772_tk_di1.png")
	display.setS9(loginFrameBG, cc.rect(28, 32, 90, 546), cc.size(D_SIZE.hw, D_SIZE.hh * 2 / 3))
	loginFrameBG:setPosition(cc.p(D_SIZE.hw, D_SIZE.hh))
	node:addChild(loginFrameBG)

	local usernameLabel = display.newText(display.trans("##20051"), 30, cc.c3b(12, 49, 144))
	local passwordLabel = display.newText(display.trans("##20052"), 30, cc.c3b(12, 49, 144))
	loginFrameBG:addChild(usernameLabel)
	loginFrameBG:addChild(passwordLabel)

	local p = cc.p(45, loginFrameBG:getContentSize().height - 80)
	usernameLabel:setAnchorPoint(cc.p(0, 0.5))
	usernameLabel:setPosition(p)
	
	passwordLabel:setAnchorPoint(cc.p(0, 0.5))
	passwordLabel:setPosition(cc.p(p.x, p.y - 100))

	local loginFrameBGSize = loginFrameBG:getContentSize()

	local username = display.newInputText(
		cc.size(loginFrameBGSize.width - p.x * 4 - usernameLabel:getContentSize().width, 50), "res/images/login/ui_772_grxx_ghtxdi.png",
		30, cc.c3b(255,255,255), nil, display.trans("##20046"), cc.c3b(76,175,232), nil, nil, ccui.TextureResType.localType
	)
	local password = display.newInputText(
		cc.size(loginFrameBGSize.width - p.x * 4 - usernameLabel:getContentSize().width, 50), "res/images/login/ui_772_grxx_ghtxdi.png",
		30, cc.c3b(255,255,255), nil,display.trans("##20047"), cc.c3b(76,175,232), nil, nil, ccui.TextureResType.localType
	)

	
	password:setInputFlag(cc.EDITBOX_INPUT_FLAG_PASSWORD)

	username:setAnchorPoint(cc.p(0, 0.5))
	password:setAnchorPoint(cc.p(0, 0.5))
	loginFrameBG:addChild(username)
	loginFrameBG:addChild(password)

	username:setPosition(cc.p(p.x + usernameLabel:getContentSize().width + 15, p.y))
	password:setPosition(cc.p(p.x + usernameLabel:getContentSize().width + 15, p.y - 100))

	local loginBtn = display.newButton('res/images/login/ui_772_dl_an_di3.png','res/images/login/ui_772_dl_an_di3.png','res/images/login/ui_772_dl_an_di3.png', 0)
	loginBtn:setTouchEnabled(true)
	loginBtn:addTouchEventListener(function(t, e)
		if e ~= ccui.TouchEventType.ended then return end

		local _username = username:getText()
		local _password = password:getText()

		if _username == "" then
			display.showMsg(display.trans("##20046"))
			return
		end

		if _password == "" then
			display.showMsg(display.trans("##20047"))
			return
		end

		doLogin(self, "user", _username, _password)
	end)
	loginBtn:setAnchorPoint(cc.p(1,0.5))
	loginBtn:addChild(Coord.ingap(loginBtn, display.newImage("#res/images/login/ui_772_dl_zhdl.png"), "CC", 0, "CC", 0))
	loginBtn:setPosition(cc.p(D_SIZE.hw - 40, D_SIZE.hh - loginBtn:getContentSize().width))
	node:addChild(loginBtn)

	local regBtn = display.newButton('res/images/login/ui_772_dl_an_di2.png','res/images/login/ui_772_dl_an_di2.png','res/images/login/ui_772_dl_an_di2.png', 0)
	regBtn:setTouchEnabled(true)
	regBtn:addTouchEventListener(function(t, e)
		if e ~= ccui.TouchEventType.ended then return end
        
		-- local weChat = require("src.platform.WeChatSDK")
		-- weChat:auth()
		if self.regView == nil then
			initRegView(self)
			self:addChild(self.regView)
		end
		self.loginView:setVisible(false)
		self.regView:setVisible(true)
	end)
	regBtn:setAnchorPoint(cc.p(0,0.5))
	regBtn:addChild(Coord.ingap(regBtn, display.newImage("#res/images/login/ui_772_dl_zhzc.png"), "CC", 0, "CC", 0))
	regBtn:setPosition(cc.p(D_SIZE.hw + 40, D_SIZE.hh - loginBtn:getContentSize().width))
	node:addChild(regBtn)

	local weChatBtn = display.newButton('res/images/login/dl_wx.png','res/images/login/dl_wx.png','res/images/login/dl_wx.png', 0)
	-- local beforeLanguage = require("src.base.tools.storage").getXML("language")
	-- if(beforeLanguage == "en")then
	-- 	weChatBtn = display.newButton('res/images/login/dl_wx_en.png','res/images/login/dl_wx_en.png','res/images/login/dl_wx_en.png', 0)
	-- end
	
	weChatBtn:setTouchEnabled(true)
	weChatBtn:addTouchEventListener(function(t, e)
		if e ~= ccui.TouchEventType.ended then return end
		local weChat = require("src.platform.WeChatSDK")
		weChat.init()
		weChat.auth()

	end)
	weChatBtn:setAnchorPoint(cc.p(1,0.5))
	-- weChatBtn:addChild(Coord.ingap(weChatBtn, display.newImage("#res/images/login/ui_772_dl_zhdl.png"), "CC", 0, "CC", 0))
	weChatBtn:setPosition(cc.p(D_SIZE.hw - 40, D_SIZE.hh - weChatBtn:getContentSize().width - 100))
	node:addChild(weChatBtn)

	-- local alipayBtn = display.newButton('res/images/login/dl_zfb.png','res/images/login/dl_zfb.png','res/images/login/dl_zfb.png', 0)
	-- alipayBtn:setTouchEnabled(true)
	-- alipayBtn:addTouchEventListener(function(t, e)
	-- 	if e ~= ccui.TouchEventType.ended then return end
	-- 	local alipay = require("src.platform.AlipaySDK")
	-- 	alipay.init()
	-- 	alipay.auth()
	-- 	-- display.showMsg("敬请期待")
	-- end)
	-- alipayBtn:setAnchorPoint(cc.p(0,0.5))
	-- -- alipayBtn:addChild(Coord.ingap(alipayBtn, display.newImage("#res/images/login/ui_772_dl_zhdl.png"), "CC", 0, "CC", 0))
	-- alipayBtn:setPosition(cc.p(D_SIZE.hw + 40, D_SIZE.hh - alipayBtn:getContentSize().width - 100))
	-- node:addChild(alipayBtn)



	self.loginView = node
end

function LoginScene:ctor()

	self.loginView = nil
	self.regView = nil
	self.sending = false

	display.loadSpriteFrames("res/images/login.plist","res/images/login.png")

	self:super("ctor")
	require("src.app.connect.LoginManager").resetTypes()
	math.randomseed(os.millis())

	local bgLeft = display.newDynamicImage(display.getResolutionPath("ui_dengl_bg_01.png"))
	local bgRight = display.newDynamicImage(display.getResolutionPath("ui_dengl_bg_02.png"))

	local background = display.newDynamicImage(display.getResolutionPath("login_background.jpg"))
	self:addChild(Coord.scgap(bgLeft,"CR",0,"CC",0))
	self:addChild(Coord.scgap(bgRight,"CL",0,"CC",0))

	if self.loginView == nil then
		initLoginView(self)
	end

	if self.loginView:getParent() == nil then
		self:addChild(self.loginView)
	end
end
function LoginScene:onEnter()
	SoundsManager.playMusic("main_sound_bg",true)
end

function LoginScene:onCleanup()
	display.removeSpriteFrames("res/images/login.plist", "res/images/login.png")
	SoundsManager.stopAudio("main_sound_bg")
end

return LoginScene
