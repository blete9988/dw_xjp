--[[
*	设置 window
*	@author：lqh
]]
local SettingWindows = class("SettingWindows",require("src.ui.BaseUIWindows"))

local CheckItem = class("CheckItem",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function() 
	return display.newLayout(cc.size(187,89))
end)
--SettingWindows ctor
function SettingWindows:ctor()
	local bg = display.newImage("#res/images/single/single_windowbg_01.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,250,20,20),cc.size(1086,700)),"p_ui_1019.png")
	self:addChild(Coord.ingap(self,require("src.base.log.debugKey")(),"LL",0,"BB",0))
	
	local uilayout = display.newLayout(cc.size(970,450))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
	
	self:m_initSettingLayout(uilayout)
	self:m_initAccountLayout(uilayout)
	self:m_initChangeLangage(uilayout)
	--分享按钮
	-- local shareBtn = display.newButton("p_btn_1012.png","p_btn_1012.png")
	-- shareBtn:setPressedActionEnabled(true)
	-- uilayout:addChild(Coord.ingap(uilayout, shareBtn,"CC",0,"BB",35))
	-- shareBtn:addChild(Coord.ingap(shareBtn,display.newImage("p_ui_1020.png"),"CC",0,"CC",5))
	-- shareBtn:addTouchEventListener(function(t,e) 
	-- 	if e ~= ccui.TouchEventType.ended then return end
		
	-- end)
end

function SettingWindows:enterNextScene()
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

--切换语言
function SettingWindows:m_initChangeLangage(uilayout)
	local btnChina = nil
	local btnEn = nil
	local function buttonHandler(t,e)
		if e ~= ccui.TouchEventType.ended then return end

		local beforeLanguage = require("src.base.tools.storage").getXML("language")

		if t == btnChina then
			if(beforeLanguage == "sc")then
				return
			end
			require("src.base.tools.storage").saveXML("language",tostring("sc"))
		elseif t == btnEn then
			if(beforeLanguage == "en")then
				return
			end
			require("src.base.tools.storage").saveXML("language",tostring("en"))
		end

		reload("src.reExcute")(function() 
			self:enterNextScene()
		end)

	end

		--确认按钮
	btnChina = display.newTextButton("popui_btn_001.png","popui_btn_001.png","",1,"中文",26)
	btnChina:setLocalZOrder(2)
	btnChina:setPressedActionEnabled(true)
	btnChina:addTouchEventListener(buttonHandler)
	uilayout:addChild(Coord.outgap(uilayout,btnChina,"LR",130,"CC",-200))

		--确认按钮
	btnEn = display.newTextButton("popui_btn_001.png","popui_btn_001.png","",1,"English",26)
	btnEn:setLocalZOrder(2)
	btnEn:setPressedActionEnabled(true)
	btnEn:addTouchEventListener(buttonHandler)
	uilayout:addChild(Coord.outgap(uilayout,btnEn,"LR",300,"CC",-200))

end
--初始化音乐设置层
function SettingWindows:m_initSettingLayout(uilayout)
	--音乐按钮
	local bgmBtn = CheckItem.new()
	if SoundsManager.isCancelBGM() then
		bgmBtn:setSelect(1)
	end
	uilayout:addChild(Coord.ingap(uilayout,bgmBtn,"CR",-65,"TT",-30))
	bgmBtn:addEventListener("check_changed",function(event,param) 
		if param == 1 then
			SoundsManager.cancelBGM(true)
		else
			SoundsManager.cancelBGM(false)
		end
	end)
	--音乐图片文字
	local txtimage = display.newImage("p_ui_1022.png")
	uilayout:addChild(Coord.outgap(bgmBtn,txtimage,"LR",-20,"CC",0))
	--音效图片文字
	txtimage = display.newImage("p_ui_1021.png")
	uilayout:addChild(Coord.outgap(bgmBtn,txtimage,"RL",130,"CC",0))
	--音效按钮
	local seBtn = CheckItem.new()
	if SoundsManager.isCancelSE() then
		seBtn:setSelect(1)
	end
	uilayout:addChild(Coord.outgap(txtimage,seBtn,"RL",20,"CC",0))
	seBtn:addEventListener("check_changed",function(event,param) 
		if param == 1 then
			SoundsManager.cancelSE(true)
		else
			SoundsManager.cancelSE(false)
		end
	end)
end
--初始化账号层
function SettingWindows:m_initAccountLayout(uilayout)
	local bg = display.setS9(display.newImage("p_panel_1001.png"),cc.rect(20,20,30,30),cc.size(870,150))
	uilayout:addChild(Coord.ingap(uilayout,bg,"CC",0,"CC",0))
	
	local headicon = require("src.ui.item.HeadIcon").new(Player.headpath)
	bg:addChild(Coord.ingap(bg,headicon,"LL",30,"CC",0))
	
	bg:addChild(Coord.outgap(headicon, display.newText(Player.name,36),"RL",30,"CC",0))
	--切换账号按钮
	local changeAccountBtn = display.newButton("p_btn_1016.png","p_btn_1016.png")
	changeAccountBtn:setPressedActionEnabled(true)
	bg:addChild(Coord.ingap(bg, changeAccountBtn,"RR",-30,"CC",0))
	changeAccountBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		ConnectMgr.noticehandler(ST.TYPE_SOCKET_CLOSE_ALL)
		display.enterScene("src.ui.scene.login.LoginScene")
	end)
end
-- ---------------------------class CheckItem--------------------------------
function CheckItem:ctor()
	self:super("ctor")
	self:setTouchEnabled(true)
	self.type = 0
	local defaultTexture = display.newImage("p_btn_1015.png")
	self:addChild(Coord.ingap(self,defaultTexture,"CC",0,"CC",0))
	local selectTexture = display.newImage("p_btn_1014.png")
	selectTexture:setVisible(false)
	self:addChild(Coord.ingap(self,selectTexture,"CC",0,"CC",0))
	self:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self.type = (self.type + 1)%2
		self:setSelect(self.type)
		self:dispatchEvent("check_changed",self.type)
	end)
	self.selectTexture = selectTexture
	self.defaultTexture = defaultTexture
end
function CheckItem:setSelect(value)
	self.type = value
	if self.type == 1 then
		self.defaultTexture:setVisible(false)
		self.selectTexture:setVisible(true)
	else
		self.defaultTexture:setVisible(true)
		self.selectTexture:setVisible(false)
	end
end
function CheckItem:onCleanup()
	self:removeAllEventListeners()
end
-- --------------------------------------------------------------------------
return SettingWindows