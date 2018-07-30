--[[
*	水果拉霸
*	@author：gwj
]]
local ShuiGuoLaBaScene = class("ShuiGuoLaBaScene",require("src.base.extend.CCSceneExtend"),IEventListener)

function ShuiGuoLaBaScene:ctor(room)
	self:super("ctor")
	self:addEvent(ST.COMMAND_PLAYER_GOLD_UPDATE)
	self:addEvent(ST.COMMAND_MAINSOCKET_BREAK)
	self.room = room
	self.noNeedClearRes = false
	self:initUi()
	self:initData()
	SoundsManager.playMusic("sglb_bg",true)
	require("src.ui.item.TalkControl").show(self.room,self,nil,108)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)
	require("src.ui.item.ScreenScrollMsg").show(self,cc.p(D_SIZE.hw,D_SIZE.top(25)),110)
	--注册推送端口
	-- ConnectMgr.registorJBackPort(ConnectMgr.getMainSocket(),Port.PORT_JBACK_FEIQINGZOUSHOU,require("src.games.feiqingzoushou.content.FeiQingZouShou_JbackPort").extend())
	-- ConnectMgr.connect("src.games.feiqingzoushou.content.FeiQingZouShouGetRoomConnect")
end

function ShuiGuoLaBaScene:handlerEvent(event,arg)
	--金币发生改变
	if event == ST.COMMAND_PLAYER_GOLD_UPDATE then
		self.main_layout:updateGold()
	elseif event == ST.COMMAND_MAINSOCKET_BREAK then
		--主socket断开连接
		self.noNeedClearRes = true
		display.enterScene("src.ui.ReloginScene",{self.room})
	end
end

--初始化UI
function ShuiGuoLaBaScene:initUi()
	local main_layout = require("src.games.shuiguolaba.ui.ShuiGuoLaBaUIPanel").new()
	self:addChild(main_layout)
	self.main_layout = main_layout
end

function ShuiGuoLaBaScene:initData()
	ConnectMgr.connect("src.games.shuiguolaba.content.ShuiGuoLaBaInitConnect",function(result)
		if not result then
			display.showMsg("初始化失败!请重新进入!")
		end
	end)
end

function ShuiGuoLaBaScene:onCleanup()
	SoundsManager.stopAllMusic()
	SoundsManager.stopAllSounds()
	self:removeAllEvent()
	if not self.noNeedClearRes then
		require("src.command.ReleaseResTool")(require(self.room.game.resourcecfg))
	end
end

return ShuiGuoLaBaScene