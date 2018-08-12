local Lkby_Scene = class("Lkby_Scene",function()
	local scene = display.extend("CCSceneExtend",cc.Scene:createWithPhysics())
	return scene
end,IEventListener)

local TAG_ENUM = 
{
  Tag_Fish = 200
}

local scheduler = cc.Director:getInstance():getScheduler()
local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")

function Lkby_Scene:ctor(room)
	self:super("ctor")
	self.room = room

	self.m_infoList = {}
	self.m_scheduleUpdate = nil
	self.m_secondCountSchedule = nil
	self._scene = room
	self.m_bScene = false
	self.m_bSynchronous = false
	self.m_nSecondCount = 60
	self.m_catchFishCount = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
	  -- self._gameFrame = frameEngine
	  -- self._gameFrame:setKindInfo(cmd.KIND_ID,cmd.VERSION)
	  -- self._roomRule = self._gameFrame._dwServerRule

	local gameView = require("src.games.likuibuyu.ui.LikuibuyuSceneUiPanel").new()
	self:addChild(gameView)
	self._gameView = gameView


	self._dataModel = require("src.games.likuibuyu.content.GameFrame").getInstance()
		--设置场景引力
    self:getPhysicsWorld():setGravity(cc.p(0,-100))



   	-- self:initUi()
   	-- self:initData()
	-- SoundsManager.playMusic("qznn_bgm",true)

  -- self.m_pUserItem = self._gameFrame:GetMeUserItem()
  -- self.m_nTableID  = self.m_pUserItem.wTableID
  -- self.m_nChairID  = self.m_pUserItem.wChairID  

  	self:setReversal()

  	--鱼层
	  self.m_fishLayer = cc.Layer:create()
	  self._gameView:addChild(self.m_fishLayer, 5)
    
    if self._dataModel.m_reversal then
	    self.m_fishLayer:setRotation(180)
	end


  --自己信息
  self._gameView:initUserInfo()

   --创建定时器
  self:onCreateSchedule()

  --60秒未开炮倒计时
  self:createSecoundSchedule()

   --注册事件
  ExternalFun.registerTouchEvent(self,true)

  --注册通知
  -- self:addEvent()

	require("src.ui.item.TalkControl").show(room,self)
	local quitebtn = require("src.ui.QuitButton").new()
	self:addChild(Coord.ingap(self,quitebtn,"LL",0,"TT",0),109)

end

function Lkby_Scene:onEnter( )
	
  print("onEnter of Lkby_Scene")

end

function Lkby_Scene:onEnterTransitionFinish(  )
 
  print("onEnterTransitionFinish of Lkby_Scene")

  --AudioEngine.playMusic(g_var(cmd).Music_Back_1,true)

--碰撞监听
  self:addContact()

end



--触摸事件
function Lkby_Scene:onTouchBegan(touch, event)

	return true
end

function Lkby_Scene:onTouchMoved(touch, event)

end

function Lkby_Scene:onTouchEnded(touch, event )
	
end

--添加碰撞
function Lkby_Scene:addContact()

    local function onContactBegin(contact)
    
        local a = contact:getShapeA():getBody():getNode()
        local b = contact:getShapeB():getBody():getNode()
       
        local bullet = nil

        if a and b then
          if a:getTag() == g_var(cmd).Tag_Bullet then
            bullet = a
          end

          if b:getTag() == g_var(cmd).Tag_Bullet then
            bullet = b
          end

        end
        if nil ~= bullet then
           bullet:fallingNet()
           bullet:removeFromParent()
        end

        return true
    end

    local dispatcher = self:getEventDispatcher()
    self.contactListener = cc.EventListenerPhysicsContact:create()
    self.contactListener:registerScriptHandler(onContactBegin, cc.Handler.EVENT_PHYSICS_CONTACT_BEGIN)
    dispatcher:addEventListenerWithSceneGraphPriority(self.contactListener, self)

end

function Lkby_Scene:createSecoundSchedule() 

  local function setSecondTips() --提示

    if nil == self._gameView:getChildByTag(10000) then 

      local tipBG = cc.Sprite:create("game/likuibbuyu/secondTip.png")
      tipBG:setPosition(667, 630)
      tipBG:setTag(10000)
      self._gameView:addChild(tipBG,100)


      local watch = cc.Sprite:createWithSpriteFrameName("watch_0.png")
      watch:setPosition(60, 45)
      tipBG:addChild(watch)

      local animation = cc.AnimationCache:getInstance():getAnimation("watchAnim")
      if nil ~= animation then
         watch:runAction(cc.RepeatForever:create(cc.Animate:create(animation)))
      end

	--排名文本
	-- local labeltxt = display.newText(index,26,Color.danrubaise)
	-- layout:addChild(Coord.ingap(layout,labeltxt,"LL",20,"CC",0))
      local time = display.newText(string.format("%d秒",self.m_nSecondCount), 26,Color.danrubaise)
      time:setTextColor(cc.YELLOW)
      time:setAnchorPoint(0.0,0.5)
      time:setPosition(117, 55)
      time:setTag(1)
      tipBG:addChild(time)

      local buttomTip = display.newText("60秒未开炮,即将退出游戏", 20,Color.danrubaise)
      buttomTip:setAnchorPoint(0.0,0.5)
      buttomTip:setPosition(117, 30)
      tipBG:addChild(buttomTip)

    else

         local tipBG = self._gameView:getChildByTag(10000)
         local time = tipBG:getChildByTag(1)
         time:setString(string.format("%d秒",self.m_nSecondCount))      
    end

  end

  local function removeTip()

    local tipBG = self._gameView:getChildByTag(10000)
    if nil ~= tipBG then
      tipBG:removeFromParent()
    end

  end


  local function update(dt)

    if self.m_nSecondCount == 0 then --发送起立
      removeTip()
      self:onKeyBack()
      return
    end

    if self.m_nSecondCount - 1 >= 0 then 
      self.m_nSecondCount = self.m_nSecondCount - 1
    end

    if self.m_nSecondCount <= 10 then
       setSecondTips()
    end

  end

  if nil == self.m_secondCountSchedule then
    self.m_secondCountSchedule = scheduler:scheduleScriptFunc(update, 1.0, false)
  end

end

--创建定时器
function Lkby_Scene:onCreateSchedule()
  local isBreak0 = false
  local isBreak1 = true


--鱼队列
	  local function dealCanAddFish()

	    if isBreak0 then
	       isBreak1 = false
	      return
	    end

	     if #self._dataModel.m_waitList >=5 then
	       isBreak0 = true
	       isBreak1 = false
	       return
	    end

	    table.sort( self._dataModel.m_fishCreateList, function ( a ,b )
	      return a.nProductTime < b.nProductTime
	    end )

	    local function isCanAddtoScene(data)

	    
	      local iscanadd = false

	      local time = currentTime()
	      if data.nProductTime <= time and data.nProductTime ~= 0  then

	          iscanadd = true
	          return iscanadd
	      end

	       return iscanadd
	    end

	    local texture = cc.Director:getInstance():getTextureCache():getTextureForKey("game/likuibbuyu/fish_move1.png")
	    local texture1 = cc.Director:getInstance():getTextureCache():getTextureForKey("game/likuibbuyu/fish_move2.png")
	    local anim = cc.AnimationCache:getInstance():getAnimation("animation_fish_move26")
	    if not texture or not texture1 or not anim then
	       return
	    end

	    if 0 ~= #self._dataModel.m_fishCreateList  then
	      local fishdata = self._dataModel.m_fishCreateList[1]
	      table.remove(self._dataModel.m_fishCreateList,1)
	      local iscanadd = isCanAddtoScene(fishdata)
	      if iscanadd then
	          local fish =  g_var(Fish):create(fishdata,self)
	          fish:initAnim()
	          fish:setTag(g_var(cmd).Tag_Fish)
	          fish:initWithState()
	          fish:initPhysicsBody()
	          self.m_fishLayer:addChild(fish, fish.m_data.nFishType + 1)
	          self._dataModel.m_fishList[fish.m_data.nFishKey] = fish
	        else
	          table.insert(self._dataModel.m_waitList, fishdata)
	      end
	    end 
	  end

--等待队列
	  local function dealWaitList( )

	      if isBreak1 then
	        isBreak0 = false
	        return
	      end

	      if  #self._dataModel.m_waitList == 0 then
	         
	          isBreak0 = false
	          isBreak1 = true
	          return
	      end

	      if  #self._dataModel.m_waitList ~= 0 then
	       
	          for i=1, #self._dataModel.m_waitList do
	             local fishdata = self._dataModel.m_waitList[i]
	             table.insert(self._dataModel.m_fishCreateList,1,fishdata)
	          end

	         self._dataModel.m_waitList = {}
	      end
	  end

--定位大鱼
	local function selectMaxFish()

	     --自动锁定
	      if self._dataModel.m_autolock  then

	           local fish = self._dataModel.m_fishList[self._dataModel.m_fishIndex]

	           if nil == fish then
	              self._dataModel.m_fishIndex = self._dataModel:selectMaxFish()
	              return
	           end

	           local rect = cc.rect(0,0,yl.WIDTH,yl.HEIGHT)
	           local pos = cc.p(fish:getPositionX(),fish:getPositionY()) 
	          
	           if  not cc.rectContainsPoint(rect,pos) then
	               self._dataModel.m_fishIndex = self._dataModel:selectMaxFish()
	      
	           end
	         
	      end
	end


	local function update(dt)

	--筛选大鱼
	  selectMaxFish()

	--能加入显示的鱼群
	  dealCanAddFish()

	--需等待的鱼群
	  dealWaitList()

	end

--游戏定时器
	if nil == self.m_scheduleUpdate then
		self.m_scheduleUpdate = scheduler:scheduleScriptFunc(update, 0, false)
	end

end


--判断自己位置 是否需翻转
function Lkby_Scene:setReversal( )
   
  -- if self.m_pUserItem then
  --   if self.m_pUserItem.wChairID < 3 then
  --       self._dataModel.m_reversal = true
  --   end
  -- end

  -- return self._dataModel.m_reversal

end

--初始化UI
function Lkby_Scene:initUi()

	--自己信息
  	-- self._gameView:initUserInfo()
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