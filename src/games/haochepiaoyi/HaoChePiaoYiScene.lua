--[[
*	好车飘逸
*	@author：gwj
]]
local HaoChePiaoYiScene = class("HaoChePiaoYiScene",require("src.base.extend.CCSceneExtend"))

function HaoChePiaoYiScene:ctor(room)
	self:super("ctor")
	self.room = room
	self:initUi()
	SoundsManager.playMusic("fcpy_bg",true)
	--注册推送端口
	ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_HAOCHEPIAOYI,require("src.games.haochepiaoyi.content.HaoChePiaoYi_JbackPort").extend())
	ConnectMgr.connect("src.games.haochepiaoyi.content.HaoChePiaoYiGetRoomConnect")
	require("src.ui.item.TalkControl").show(self.room,self,nil,108)
	--退出按钮
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(500)),110)
end

--初始化UI
function HaoChePiaoYiScene:initUi()
	local main_layout = require("src.games.haochepiaoyi.ui.HaoChePiaoYiSceneUIPanel").new(self.room)
	self:addChild(main_layout)
	self.main_layout = main_layout
end

function HaoChePiaoYiScene:onCleanup()
	SoundsManager.stopAllMusic()
	SoundsManager.stopAllSounds()
	ConnectMgr.unRegistorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_HAOCHEPIAOYI)
	if not self.main_layout.noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
end

return HaoChePiaoYiScene