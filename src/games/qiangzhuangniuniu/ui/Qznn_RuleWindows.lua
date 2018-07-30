--[[
*	抢庄牛牛 规则window
*	@author：lqh
]]
local Qznn_RuleWindows = class("Qznn_RuleWindows",BaseWindow,function() 
	local layer = display.newLayout(cc.size(1234,616))
	layer:setTouchEnabled(true)
	Coord.scgap(layer,"CC",0,"CC",0)
	return layer
end)
Qznn_RuleWindows.hide_forward = false

function Qznn_RuleWindows:ctor()
	self:super("ctor")
	--透明蒙版
	self:addChild(Coord.ingap(self, display.newMask(cc.size(D_SIZE.w,D_SIZE.h),200),"CC",0,"CC",0))
	--底板
	local background = display.newDynamicImage("game/qiangzhuangniuniu/qznn_windowbg_2.png")
	background:setScale(1.319)
	self:addChild(Coord.ingap(self,background,"CC",0,"CC",0,true))
	
	local closebtn = display.newButton("qznn_ui_1025.png","qznn_ui_1025.png")
	closebtn:setPressedActionEnabled(true)
	self:addChild(Coord.ingap(self,closebtn,"RR",-5,"TT",-45))
	closebtn:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		self:executQuit()
	end)
	
	local listview = display.newListView(nil,nil,nil,true)
	listview:setBackGroundImage("qznn_panel_1003.png",1)
	display.setBgS9(listview,cc.rect(40,40,10,10),cc.size(1100,500))
	self:addChild(Coord.ingap(self,listview,"CC",0,"BB",30))
		
	local temply = display.newLayout(cc.size(1050,1108))
	local rulepic = display.newDynamicImage("game/qiangzhuangniuniu/qznn_rulepic_1.png")
	rulepic:setScale(1)
	temply:addChild(Coord.ingap(temply,rulepic,"CC",0,"CC",0,true))
	
	listview:pushBackCustomItem(temply)
	
end
return Qznn_RuleWindows