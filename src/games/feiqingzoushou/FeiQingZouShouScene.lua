--[[
*	飞禽走兽
*	@author：gwj
]]
local FeiQingZouShouScene = class("FeiQingZouShouScene",require("src.base.extend.CCSceneExtend"))

function FeiQingZouShouScene:ctor(room)
	self:super("ctor")
	self.room = room
	self:initUi()
	--注册推送端口
	ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_FEIQINGZOUSHOU,require("src.games.feiqingzoushou.content.FeiQingZouShou_JbackPort").extend())
	ConnectMgr.connect("src.games.feiqingzoushou.content.FeiQingZouShouGetRoomConnect")

	require("src.ui.item.TalkControl").show(self.room,self,cc.p(0,D_SIZE.height/2 + 70),108)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(120)),110)
end

--初始化UI
function FeiQingZouShouScene:initUi()
	local main_layout = require("src.games.feiqingzoushou.ui.FeiQingZouShouUIPanel").new(self.room)
	self:addChild(main_layout)
	self.main_layout = main_layout
end

function FeiQingZouShouScene:onCleanup()
	SoundsManager.stopAllMusic()
	SoundsManager.stopAllSounds()
	ConnectMgr.unRegistorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_FEIQINGZOUSHOU)
	if not self.main_layout.noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
end

return FeiQingZouShouScene