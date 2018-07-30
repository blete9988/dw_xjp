--[[
*	兑换码  window
*	@author：lqh
]]
local AwardWindows = class("AwardWindows",require("src.ui.BaseUIWindows"))

--AwardWindows ctor
function AwardWindows:ctor()
	local bg = display.newImage("#res/images/single/single_windowbg_01.png")
	self:super("ctor",display.setS9(bg,cc.rect(510,250,20,20),cc.size(1086,700)))
	self:addChild(Coord.ingap(self,require("src.base.log.debugKey")(),"LL",0,"BB",0))
	
	local uilayout = display.newLayout(cc.size(970,450))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
	
	uilayout:addChild(Coord.ingap(uilayout,display.newText(display.trans("##2055"),40),"CC",0,"TT",-15))
	
	local awardbg = display.newImage("p_panel_1004.png")
	display.setS9(awardbg,cc.rect(10,10,20,20),cc.size(600,65))
	uilayout:addChild(Coord.ingap(uilayout,awardbg,"CC",0,"TT",-70))
	-- uilayout:addChild(Coord.outgap(awardbg,display.newImage("p_ui_1009.png"),"LR",-10,"CC",0))
	--返利文本
	-- local awardTxt = cc.Label:createWithCharMap(display.getTexture("res/fonts/main_font_nmb_2.png"),46.3,42,string.byte("0"))
	-- awardTxt:setString(0)
	-- awardbg:addChild(Coord.ingap(awardbg,awardTxt,"LL",20,"CC",0))
	--密码输入
	local awardTxt = display.newInputText(cc.size(600,65),nil,28,nil,nil,"请输入卡号")
	awardTxt:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
	awardTxt:setMaxLength(16)
	uilayout:addChild(Coord.ingap(uilayout,awardTxt,"CC",0,"TT",-70))


		--密码背景
	-- local dhmbg = display.newLayout()
	-- dhmbg:setTouchEnabled(true)
	-- dhmbg:setBackGroundImage("p_panel_1004.png",1)
	-- display.setBgS9(dhmbg,cc.rect(10,10,20,20),cc.size(520,70))
	-- uilayout:addChild(Coord.ingap(uilayout,dhmbg,"CC",0,"TT",-70))
	-- dhmbg:addChild(Coord.ingap(dhmbg, display.newText(display.trans("##2030"),28,Color.GREY),"LL",10,"CC",0))
	
	local confirmBtn = display.newButton("p_btn_1012.png","p_btn_1012.png")
	confirmBtn:setPressedActionEnabled(true)
	confirmBtn:addChild(Coord.ingap(confirmBtn,display.newImage("p_ui_1016.png"),"CC",0,"CC",5))
	uilayout:addChild(Coord.outgap(awardbg,confirmBtn,"CC",0,"BT",-30))
	confirmBtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		local dhm_str = awardTxt:getText()
		-- local dhm_type = type(dhm_str);
		-- if(dhm_type == "number")then
			require("src.base.http.HttpRequest").postJSON(require("src.app.config.server.server_config").apihost..'card/exchange', {
				['token'] = Player.token,
				['code'] = dhm_str
			}, function(result, data)
				self.sending = false

				if data == nil then
					display.showMsg(display.trans("##2071"))
					return
				end

				if data["errno"] ~= 0 then
					display.showMsg(data["errmsg"] or "##2071")
					return
				end
				-- mlog(data)
				-- mlog("fdsafadsfads"..require("src.cocos.cocos2d.json"):encode(data))

				display.showMsg(display.trans("##2072"))
			end)
		-- else
		-- 	display.showMsg(display.trans("##2070"))
		-- end

	end)
	
	-- require("src.base.http.HttpRequest").postJSON(require("src.app.config.server.server_config").apihost..'auth/register', {
	-- 		['username'] = _username,
	-- 		['password'] = _password
	-- 	}, function(result, data)
	-- 		self.sending = false

	-- 		if data == nil then
	-- 			display.showMsg("注册失败")
	-- 			return
	-- 		end

	-- 		if data["errno"] ~= 0 then
	-- 			display.showMsg(data["errmsg"] or "注册失败")
	-- 			return
	-- 		end

	-- 		display.showMsg("注册成功")

	-- 		--注册成功，直接进入登陆流程
	-- 		--进入登陆流程
	-- 		doLogin(self, "user", _username, _password)
	-- 	end)



	-- local tipTxt = display.newRichText(display.trans("##2056"),30)
	-- tipTxt:setWidth(820)
	-- tipTxt:setLeading(15)
	-- uilayout:addChild(Coord.ingap(uilayout,tipTxt,"CC",0,"BB",40))
end

return AwardWindows