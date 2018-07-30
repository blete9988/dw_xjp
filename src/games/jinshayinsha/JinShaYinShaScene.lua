--[[
*	飞禽走兽
*	@author：gwj
]]
local JinShaYinShaScene = class("JinShaYinShaScene",require("src.base.extend.CCSceneExtend"))

function JinShaYinShaScene:ctor(room)
	self:super("ctor")
	self.room = room
	self:initUi()
	SoundsManager.playMusic("jsys_music_game_1",true)
	--注册推送端口
	ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_JINSHAYINSHA,require("src.games.jinshayinsha.content.JinShaYinSha_JbackPort").extend())
	ConnectMgr.connect("src.games.jinshayinsha.content.JinShaYinShaGetRoomConnect")
	require("src.ui.item.TalkControl").show(self.room,self,nil,108)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(120)),110)
end

--初始化UI
function JinShaYinShaScene:initUi()
	local main_layout = require("src.games.jinshayinsha.ui.JinShaYinShaUIPanel").new(self.room)
	self:addChild(main_layout)
	self.main_layout = main_layout
end

function JinShaYinShaScene:onCleanup()
	SoundsManager.stopAllMusic()
	SoundsManager.stopAllSounds()
	ConnectMgr.unRegistorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_JINSHAYINSHA)
	if not self.main_layout.noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
end

return JinShaYinShaScene