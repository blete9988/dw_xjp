--[[
*	退出游戏按钮
]]
local QuitButton = class("QuitButton",require("src.base.extend.CCLayerExtend"),function(normalname,pressname) 
	if not normalname then
		normalname = "p_ui_1062.png"
		pressname = "p_ui_1063.png"
	end
	return display.newButton(normalname,pressname)
end)

function QuitButton:ctor(normalname,pressname,normalname1,pressname1)
	if not normalname then
		normalname = "p_ui_1062.png"
		pressname = "p_ui_1063.png"
	else
		if not pressname then
			pressname = normalname
			self:loadTexturePressed(pressname,1)
			self:setPressedActionEnabled(true)
		end
	end
	
	if not normalname1 then
		normalname1 = "p_ui_1064.png"
		pressname1 = "p_ui_1065.png"
	else
		if not pressname1 then
			pressname1 = normalname1
			self:loadTexturePressed(pressname1,1)
			self:setPressedActionEnabled(true)
		end
	end
	
	self.normalname_0 = normalname
	self.pressname_0 = pressname
	self.normalname_1 = normalname1
	self.pressname_1 = pressname1
	
	self.status = 0 
	
	self:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self.status = (self.status + 1)%2
		if self.status == 1 then
			self:showExtendContent()
		else
			self:closeExtendContent()
		end
	end)
	
	self.m_disbaleExitbtn = false
end
--是否禁用退出按钮
function QuitButton:disabledExitButton(bool)
	if bool == self.m_disbaleExitbtn then return end
	self.m_disbaleExitbtn = bool
	if self.clipLayout then
		if bool then
			require("src.base.tools.openglTools").setGray(self.clipLayout.exitBtn)
			self.clipLayout.exitBtn:setTouchEnabled(false)
		else
			require("src.base.tools.openglTools").resetProgram(self.clipLayout.exitBtn)
			self.clipLayout.exitBtn:setTouchEnabled(true)
		end
	end
end
--显示扩展容器
function QuitButton:showExtendContent()
	self:setTouchEnabled(false)
	self:loadTextureNormal(self.normalname_1,1)
	self:loadTexturePressed(self.pressname_1,1)
	
	self.clipLayout = self:createExtendContent()	
	
	self.clipLayout.content:runAction(cc.Sequence:create({
		cc.MoveTo:create(0.15,cc.p(0,0)),
		cc.CallFunc:create(function(target) 
			if not target then return end
			self:setTouchEnabled(true)
		end)
	}))
end
function QuitButton:closeExtendContent()
	self:setTouchEnabled(false)
	self:loadTextureNormal(self.normalname_0,1)
	self:loadTexturePressed(self.pressname_0,1)
	
	self.clipLayout.content:runAction(cc.Sequence:create({
		cc.MoveTo:create(0.15,cc.p(0,300)),
		cc.CallFunc:create(function(target) 
			if not target then return end
			self:setTouchEnabled(true)
			self.clipLayout:removeFromParent()
			self.clipLayout = nil
		end)
	}))
end
function QuitButton:createExtendContent()
	local clipLayout = display.newLayout(cc.size(200,300))
	clipLayout:setClippingEnabled(true)
	self:addChild(Coord.ingap(self,clipLayout,"LL",0,"BT",0))
	
	local content = display.newLayout(cc.size(200,300))
	content:setBackGroundImage("p_panel_1005.png",1)
	display.setBgS9(content,cc.rect(35,35,10,10))
	content:setPositionY(300)
	clipLayout:addChild(content)
	
	--音乐按钮
	local bgmBtn
	if SoundsManager.isCancelBGM() then
		bgmBtn = display.newButton("p_ui_1061.png","p_ui_1060.png")
	else
		bgmBtn = display.newButton("p_ui_1060.png","p_ui_1061.png")
	end
--	bgmBtn:setPressedActionEnabled(true)
	bgmBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local bool = SoundsManager.isCancelBGM()
		bool = not bool
		SoundsManager.cancelBGM(bool)
		if bool then
			bgmBtn:loadTextureNormal("p_ui_1061.png",1)
			bgmBtn:loadTexturePressed("p_ui_1060.png",1)
		else
			bgmBtn:loadTextureNormal("p_ui_1060.png",1)
			bgmBtn:loadTexturePressed("p_ui_1061.png",1)
		end
	end)
	content:addChild(Coord.ingap(content,bgmBtn,"CC",0,"CC",0))
	
	--音效按钮
	local seBtn
	if SoundsManager.isCancelSE() then
		seBtn = display.newButton("p_ui_1059.png","p_ui_1058.png")
	else
		seBtn = display.newButton("p_ui_1058.png","p_ui_1059.png")
	end
--	seBtn:setPressedActionEnabled(true)
	seBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local bool = SoundsManager.isCancelSE()
		bool = not bool
		SoundsManager.cancelSE(bool)
		if bool then
			seBtn:loadTextureNormal("p_ui_1059.png",1)
			seBtn:loadTexturePressed("p_ui_1058.png",1)
		else
			seBtn:loadTextureNormal("p_ui_1058.png",1)
			seBtn:loadTexturePressed("p_ui_1059.png",1)
		end
	end)
	content:addChild(Coord.outgap(bgmBtn,seBtn,"CC",0,"TB",20))
	
	--返回大厅按钮
	local exitbtn = display.newImage("p_ui_1057.png")
	if self.m_disbaleExitbtn then
		require("src.base.tools.openglTools").setGray(exitbtn)
		exitbtn:setTouchEnabled(false)
	else
		exitbtn:setTouchEnabled(true)
	end
	exitbtn:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then 
			t:setScale(1.2)
		elseif e == ccui.TouchEventType.canceled then 
			t:setScale(1)
		elseif e == ccui.TouchEventType.ended then 
			t:setScale(1)
			ConnectMgr.connect("gamehall.QuitRoomConnect")
			display.enterScene("src.ui.scene.MainScene")
		end		
	end)
	
	content:addChild(Coord.outgap(bgmBtn,exitbtn,"CC",0,"BT",-20))
	
	clipLayout.exitBtn = exitbtn
	clipLayout.content = content
	
	return clipLayout
end

return QuitButton