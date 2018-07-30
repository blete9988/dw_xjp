--[[
*	断线重连 scene
]]
local ReloginScene = class("ReloginScene",require("src.base.extend.CCSceneExtend"),IEventListener)

function ReloginScene:ctor(room)
	self:super("ctor")
	
	self:addEvent(ST.COMMAND_PLAYER_LOGIN)
	
	local bg = display.newDynamicImage(string.format("game/%s/game_loading_bg.png",room.game.key))
	bg:setScale(1.61)
	self:addChild(Coord.scgap(bg,"CC",0,"CC",0,true))
	
	local tiptxt = cc.LabelTTF:create(display.trans("##1000"),Cfg.FONT,38)
	tiptxt:enableStroke(cc.c3b(0xff,0xff,0xff),2)
	tiptxt:enableShadow(cc.size(5,-3),0.3,1,true)
	tiptxt:setColor(Cfg.COLOR)
	self:addChild(Coord.scgap(tiptxt,"CC",0,"BB",50))
	self.room = room
end
--@override
function ReloginScene:handlerEvent(event,arg)
	if event == ST.COMMAND_PLAYER_LOGIN then
		local newroom = Player.getAndClearRoom()
		local oldroom = self.room
		if not newroom or newroom.id ~= oldroom.id then 
			--表明已经不再该房间中
			display.showPop({info = display.trans("##2044"),flag = ST.TYPE_POP_FLAG_2, callback = function() 
				display.enterScene("src.ui.scene.MainScene")
			end})
		else
			self.room = nil
			timeout(function()
				display.enterScene(newroom.game.path,{newroom})
			end,1.5)
		end
	end
end

function ReloginScene:onCleanup()
	self:super("onCleanup")
	if self.room then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
	self:removeAllEvent()
end

return ReloginScene
