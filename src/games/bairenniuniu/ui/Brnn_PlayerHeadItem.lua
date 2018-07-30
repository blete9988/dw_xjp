--[[
*	百人牛牛 桌面头像
*	@author：lqh
]]
local Brnn_PlayerHeadItem = class("Brnn_PlayerHeadItem",function() 
	local layout = display.newLayout(cc.size(100,120))
	layout:setAnchorPoint( cc.p(0.5,0.5) )
	return layout
end)

function Brnn_PlayerHeadItem:ctor()
	
	local goldbg = display.newImage("p_panel_1006.png")
	display.setS9(goldbg,cc.rect(25,15,60,20),cc.size(100,30))
	goldbg:setOpacity(155)
	self:addChild(Coord.ingap(self,goldbg,"CC",0,"BB",0))
	
	local headicon = require("src.ui.item.HeadIcon").new()
	headicon:setScale(0.8)
	self:addChild(Coord.outgap(goldbg,headicon,"CC",0,"TB",0,true))
	self.m_headicon = headicon
	
	local goldTxt = display.newText(0,20,Color.dantuhuangse)
	self:addChild(Coord.outgap(goldbg,goldTxt,"CC",0,"CC",0))
	
	local nameTxt = display.newText("",20,Color.dantuhuangse)
	nameTxt:setAnchorPoint( cc.p(0.5,0.5) )
	self:addChild(Coord.ingap(self,nameTxt,"CC",0,"TC",23,true))
	
	self.m_goldTxt = goldTxt
	self.m_nameTxt = nameTxt
	
end
function Brnn_PlayerHeadItem:setPlayer(playerInfo)
	if not playerInfo then return end
	if not playerInfo then 
		self:setVisible(false)
	else
		self:setVisible(true)
		self.m_headicon:setHead(playerInfo.pic)
		self.m_goldTxt:setString(string.cnspNmbformat(playerInfo.gold))
		self.m_nameTxt:setString(playerInfo.name)
	end
end

return Brnn_PlayerHeadItem