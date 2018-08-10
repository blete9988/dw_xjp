local Lkby_Scene = class("Lkby_Scene",function()
	local scene = display.extend("CCSceneExtend",cc.Scene:createWithPhysics())
	return scene
end,IEventListener)
function Lkby_Scene:ctor(room)
	self:super("ctor")
	self.room = room

		--设置场景引力
    self:getPhysicsWorld():setGravity(cc.p(0,-600))

   	self:initUi()
   	self:initData()
	-- SoundsManager.playMusic("qznn_bgm",true)


	require("src.ui.item.TalkControl").show(room,self)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)
end



--初始化UI
function Lkby_Scene:initUi()
	local main_layout = require("src.games.likuibuyu.ui.LikuibuyuSceneUiPanel").new()
	self:addChild(main_layout)
	self.main_layout = main_layout
end

--初始化数据
function Lkby_Scene:initData()
end

function Lkby_Scene:Quit()
	ConnectMgr.connect("gamehall.QuitRoomConnect")
	display.enterScene("src.ui.scene.MainScene")
end

--@override
function Lkby_Scene:onCleanup()
	mlog("关闭面板。。。。。")
	self:removeAllEvent()
	-- self:removeFromParent(true)
	SoundsManager.stopAllMusic()
	-- require("src.games.qiangzhuangniuniu.data.Qznn_GameMgr").getInstance():destory(self.noNeedClearRes)
	self:Quit()
end

return Lkby_Scene