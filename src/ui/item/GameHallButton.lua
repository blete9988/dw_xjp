--[[
*	大厅分类按钮
*	@author：lqh
]]
local GameHallButton = class("GameHallButton",require("src.base.extend.CCLayerExtend"),IEventListener,function() 
	local layer = display.newLayout(cc.size(270,450))
	layer:setAnchorPoint( cc.p(0.5,0.5) )
	layer:setScale(1.05)
	layer:setTouchEnabled(true)
	return layer
end)

function GameHallButton:ctor(gametype,animaJson,animaAtlas)
	self:super("ctor")
	self:addEvent(ST.COMMAND_GAME_HALL_PLAYERS_UPDATE)
	self.gametype = gametype
	self:setTouchEnabled(true)
	display.extendButtonToSound(self)
	
	local spineAnimate = display.newSpine(animaJson,animaAtlas)
	spineAnimate:setAnimation(0, "animation", true)
	spineAnimate:setPosition(cc.p(135,20))
	self:addChild(spineAnimate)
	
	local playerNmbTxt = display.newRichText(display.trans("##2067",Player.gameMgr:getGameHallPlayersCount(gametype)),26)
	self:addChild(Coord.ingap(self,playerNmbTxt,"CC",0,"BB",40))
	playerNmbTxt:setVisible(false)
	self.m_playerNmbTxt = playerNmbTxt
end

--@override
function GameHallButton:handlerEvent(event,arg)
	if event == ST.COMMAND_GAME_HALL_PLAYERS_UPDATE then
		self.m_playerNmbTxt:setString(display.trans("##2067",Player.gameMgr:getGameHallPlayersCount(self.gametypeetype)))
	end
end

function GameHallButton:onCleanup()
	self:super("onCleanup")
	self:removeAllEvent()
end

return GameHallButton