--[[
*	主scnee
*	@author：lqh
]]
local MainScene = class("MainScene",require("src.base.extend.CCSceneExtend"),IEventListener)

function MainScene:ctor()
	self:super("ctor")
	self:addEvent(ST.COMMAND_PLAYER_LOGIN)
	--Player.msgMgr:test()
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw + 165,D_SIZE.top(140)),20)
	
	--背景
	self:addChild(Coord.scgap(display.newImage("#" .. display.getResolutionPath("main_background.jpg")),"CC",0,"CC",0))
	--主页layout
	self.m_mianview = require("src.ui.view.MainView").new()
	self:addChild(self.m_mianview)
	
	timeout(function() 
		--检查主socket是否正常连接
		if ConnectMgr.chekMainSocket() then
			--主socket正常链接，检查是否在房间中
			self:checkPlayerIsInGame()
		end
	end,0.2)

	--每60S更新一次各类游戏在线人数
	--self:onTimer(handler(self,self.updateGameHallPlayerCount),60)
end

--更新各个游戏人数
function MainScene:updateGameHallPlayerCount()
	--ConnectMgr.connect("gamehall.GameHallPlayersCountConnect")
end

function MainScene:checkPlayerIsInGame()
	local room = Player.getAndClearRoom()
	if not room then return end
	--正在游戏中
	display.showPop({
		--提示是否回到游戏
		info = display.trans("##2042",room.game.name),
		callback = function(result)
			if(result == ST.TYPE_POP_OK )then
				display.showWindow("src.ui.window.LoadingWindows",room)
			end
		end,
		flag = ST.TYPE_POP_FLAG_2
	})
end

--@override
function MainScene:handlerEvent(event,arg)
	if event == ST.COMMAND_PLAYER_LOGIN then
		self:checkPlayerIsInGame()
	end
end
function MainScene:onCleanup()
	self:removeAllEvent()
	SoundsManager.stopAudio("main_sound_bg")
end

function MainScene:onEnter()
	SoundsManager.playMusic("main_sound_bg",true)
end

return MainScene
