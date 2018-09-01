--公告
--[[
*	公告window
*	@author：zj
]]
local LoginNoticWindow = class("LoginNoticWindow",require("src.ui.BaseUIWindows"))

--LoginNoticWindow ctor
function LoginNoticWindow:ctor(loadingscene)
	-- Player.emailMgr:updateEmail()	
	self._loadingscene = loadingscene
	local bg = display.newImage("#res/images/login/gg_bg.png")
	self:super("ctor",display.setS9(bg,cc.rect(20,20,20,20),cc.size(1086,680)),"",true)
	
	local uilayout = display.newLayout(cc.size(970,680))
	self:addChild(Coord.ingap(self,uilayout,"CC",0,"BB",55))
	
	--确定按钮
	local qd_Btn = display.newButton("res/images/login/gg_qd.png","res/images/login/gg_qd.png",'res/images/login/gg_qd.png', 0)
	qd_Btn:setTouchEnabled(true)
	uilayout:addChild(Coord.ingap(uilayout, qd_Btn,"CC",0,"BB",0))
	-- qd_Btn:addChild(Coord.ingap(qd_Btn,display.newImage("p_ui_1024.png"),"CC",0,"CC",5))
	qd_Btn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		loadingscene:initComplete()
	end)

	--二维码
	local erweimalabel_label = cc.LabelTTF:create(display.trans("##2076"),Cfg.FONT,25)
	erweimalabel_label:enableStroke(cc.c3b(0xff,0xff,0xff),2)
	erweimalabel_label:enableShadow(cc.size(5,-3),0.3,1,true)
	erweimalabel_label:setAnchorPoint(cc.p(0,0.5))
	erweimalabel_label:setColor(Cfg.COLOR)
	uilayout:addChild(Coord.scgap(erweimalabel_label,"CC",-250,"CC",30))

	local erweima = display.newImage("#res/images/login/erweima.png")
	erweima:setAnchorPoint(cc.p(1,0.5))

	uilayout:addChild(Coord.ingap(self,erweima,"CC",-60,"CC",-100))
 	
	--公告
	local notice_label = cc.LabelTTF:create("公告",Cfg.FONT,40)
	notice_label:enableStroke(cc.c3b(0xff,0xff,0xff),2)
	notice_label:enableShadow(cc.size(5,-3),0.3,1,true)
	notice_label:setAnchorPoint(cc.p(0,0.5))
	notice_label:setColor(Cfg.COLOR)
	uilayout:addChild(Coord.scgap(notice_label,"CC",-200,"CC",200))

	--内容
	local notice_con_label = cc.LabelTTF:create(display.trans("##2075"),Cfg.FONT,30)
	notice_con_label:enableStroke(cc.c3b(0xff,0xff,0xff),2)
	notice_con_label:enableShadow(cc.size(5,-3),0.3,1,true)
	notice_con_label:setAnchorPoint(cc.p(0,0.5))
	notice_con_label:setColor(Cfg.COLOR)
	uilayout:addChild(Coord.scgap(notice_con_label,"LL",50,"CC",125))

end

function LoginNoticWindow:executQuit()
	self._loadingscene:initComplete()
end
return LoginNoticWindow