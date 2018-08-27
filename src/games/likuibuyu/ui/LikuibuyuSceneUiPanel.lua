local LikuibuyuUiPanel = class("LikuibuyuUiPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"))


--Tag
LikuibuyuUiPanel.VIEW_TAG = 
{
    tag_bg        = 200,
    tag_autoshoot = 210,
    tag_autolock = 211,
    tag_gameScore= 212,
    tag_gameMultiple = 213,
    tag_grounpTips = 214,
    tag_GoldCycle = 3000,
    tag_GoldCycleTxt = 4000,
    tag_Menu = 5000
}


local module_pre = "src.games.likuibuyu" 
local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")
local g_var = ExternalFun.req_var
local cmd = module_pre..".content.CMD_LKGame"

local  TAG = LikuibuyuUiPanel.VIEW_TAG

function LikuibuyuUiPanel:ctor(scene)
	self._tag = 0
	self._scene = scene

	local game_bg = display.newImage("#game/likuibuyu/game_bg_0.png")
	game_bg:setAnchorPoint(cc.p(0,0))
	self:addChild(game_bg)
	self.game_bg = game_bg

    --底栏菜单栏
    local menuBG = display.newImage("#game/likuibuyu/game_buttom.png")
    menuBG:setAnchorPoint(0.5,0.0)
    menuBG:setScaleY(0.9)
    menuBG:setPositionX(667)
    -- self:addChild(Coord.ingap(self,menuBG,"CC",0,"BB",0),109,20)
    self.menuBG = menuBG
    menuBG:setPosition(667, -6)
    self:addChild(menuBG,20)

	--添加按钮
	local mutipleBtn = ccui.Button:create("game/likuibuyu/im_multiple_tip_0.png","game/likuibuyu/im_multiple_tip_1.png",nil)
	self:addChild(mutipleBtn)
	mutipleBtn:addTouchEventListener(function(sender,eventype)
	    if eventype == ccui.TouchEventType.ended then
            local index = self._scene._dataModel.m_secene.nMultipleIndex[1][self._scene.m_nChairID+1]
            index = index + 1
            index = math.mod(index,6)
        --     local cmddata = CCmd_Data:create(4)
        --  cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_MULTIPLE);
        --  cmddata:pushint(index)
        -- self._scene:sendNetData(cmddata) 
        -- mlog("切换倍数！！！！"..index)
          local condata = {}
          condata.int1 = index
          ConnectMgr.connect("src.games.likuibuyu.content.Likuibuyu_MultipleConnect" ,condata,function(result) end)

      end
    end)
    Coord.ingap(self,mutipleBtn,"CC",-100,"BB",-20)
    -- mutipleBtn:setPosition(yl.WIDTH/2 - 70, -20)
    mutipleBtn:setAnchorPoint(0.5,0.0)
    self.mutipleBtn = mutipleBtn


    local function callBack( sender, eventType)
        self:ButtonEvent(sender,eventType)
    end


    --自动射击
    local autoShootBtn = ccui.Button:create()
    autoShootBtn:setContentSize(cc.size(42, 36))
    autoShootBtn:setScale9Enabled(true)
    autoShootBtn:setPosition(675, 24)
    autoShootBtn:setTag(TAG.tag_autoshoot)
    autoShootBtn:addTouchEventListener(callBack)
    self:addChild(autoShootBtn,20)


    --自动锁定
    local autoLockBtn = ccui.Button:create()
    autoLockBtn:setContentSize(cc.size(42, 36))
    autoLockBtn:setScale9Enabled(true)
    autoLockBtn:setPosition(894, 24)
    autoLockBtn:setTag(TAG.tag_autolock)
    autoLockBtn:addTouchEventListener(callBack)
    self:addChild(autoLockBtn,20)


    --水波效果
    local render = cc.RenderTexture:create(1360,765)
    render:beginWithClear(0,0,0,0)
    local water = cc.Sprite:createWithSpriteFrameName("water_0.png")
    water:setScale(2.5)
    water:setOpacity(120)
   water:setBlendFunc(gl.SRC_ALPHA,gl.ONE)
    water:visit()
    render:endToLua()
    water:addChild(render)
    render:setPosition(680,382.5) 
    water:setPosition(680,382.5)
    self:addChild(water, 1)

    local ani1 = cc.Animate:create(cc.AnimationCache:getInstance():getAnimation("WaterAnim"))
    local ani2 = ani1:reverse()

    local action = cc.RepeatForever:create(cc.Sequence:create(ani1,ani2))
    water:runAction(action)

         --注册事件
    ExternalFun.registerTouchEvent(self,true)
end

function LikuibuyuUiPanel:initUserInfo()
    --用户昵称
    local nick = cc.Label:createWithCharMap("game/likuibuyu/num_multiple.png",19,20,string.byte("0"))
    nick:setString("1:")
    nick:setAnchorPoint(0.0,0.5)
    nick:setPosition(410,22)
    nick:setTag(TAG.tag_gameMultiple)
    self:addChild(nick,22)


    --用户分数 
    local score = cc.Label:createWithCharMap("game/likuibuyu/scoreNum.png",16,22,string.byte("0"))
    -- score:setString(string.format("%d", self._scene.m_pUserItem.lScore))
    score:setAnchorPoint(0.0,0.5)
    score:setTag(TAG.tag_gameScore)
    score:setPosition(71, 22)
    self:addChild(score,22)	
end

function LikuibuyuUiPanel:ButtonEvent(sender,eventType)
    if eventType == ccui.TouchEventType.ended then
            local function getCannonPos()
                 --获取自己炮台
              local cannonPos = self._scene.m_nChairID
              if self._scene._dataModel.m_reversal then 
                 cannonPos = 5 - cannonPos
              end
              return cannonPos
            end

            local tag = sender:getTag()

            if tag == TAG.tag_autoshoot then --自动射击

				self._scene._dataModel.m_autoshoot = not self._scene._dataModel.m_autoshoot

				if self._scene._dataModel.m_autoshoot then
				  self._scene._dataModel.m_autolock = false
				end

				self:setAutoShoot(self._scene._dataModel.m_autoshoot,sender)
				local lock = self:getChildByTag(TAG.tag_autolock)
				self:setAutoLock(self._scene._dataModel.m_autolock,lock)

				local isauto = false

				if self._scene._dataModel.m_autoshoot or self._scene._dataModel.m_autolock then
				  isauto =  true
				end

				local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
				cannon:setAutoShoot(isauto)

				if self._scene._dataModel.m_autoshoot then
				  cannon:removeLockTag()
				end
                    
            elseif tag == TAG.tag_autolock then --自动锁定
				self._scene._dataModel.m_autolock = not self._scene._dataModel.m_autolock
				if self._scene._dataModel.m_autolock then
				  self._scene._dataModel.m_autoshoot = false
				end

				local auto = self:getChildByTag(TAG.tag_autoshoot)
				self:setAutoShoot(self._scene._dataModel.m_autoshoot,auto)
				self:setAutoLock(self._scene._dataModel.m_autolock,sender) 

				local isauto = false

				if self._scene._dataModel.m_autoshoot or self._scene._dataModel.m_autolock then
				  isauto =  true
				end

				local cannon = self._scene.m_cannonLayer:getCannoByPos(getCannonPos() + 1)
				cannon:setAutoShoot(isauto)

				if self._scene._dataModel.m_autoshoot then
				  cannon:removeLockTag()
				end
            end
    end
end

function LikuibuyuUiPanel:updteBackGround(param)


    local bg = self:getChildByTag(TAG.tag_bg)

    if bg  then
        local call = cc.CallFunc:create(function()
            bg:removeFromParent()
        end)

        bg:runAction(cc.Sequence:create(cc.FadeTo:create(2.5,0),call))

        local bgfile = string.format("game/likuibuyu/game_bg_%d.png", param)
        local _bg = cc.Sprite:create(bgfile)
        _bg:setPosition(D_SIZE.width/2, D_SIZE.height/2)
        _bg:setOpacity(0)
        _bg:setTag(TAG.tag_bg)
        self:addChild(_bg)

        _bg:runAction(cc.FadeTo:create(5,255))
    end

        --鱼阵提示
        local groupTips = ccui.ImageView:create("game/likuibuyu/fish_grounp.png")
        groupTips:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
        groupTips:setTag(TAG.tag_grounpTips)
        self:addChild(groupTips,30)

        local callFunc = cc.CallFunc:create(function()
                groupTips:removeFromParent()
            end)

        groupTips:runAction(cc.Sequence:create(cc.DelayTime:create(5.0),callFunc))

       
end
function LikuibuyuUiPanel:setAutoShoot(b,target)
                 
    if b then

        local auto = cc.Sprite:create("game/likuibuyu/bt_check_yes.png")
        auto:setTag(1)
        auto:setPosition(target:getContentSize().width/2, target:getContentSize().height/2)
        target:removeChildByTag(1)
        target:addChild(auto)

    else
         target:removeChildByTag(1)
    end
          
end

function LikuibuyuUiPanel:setAutoLock(b,target)
          
    if b then
        local lock = cc.Sprite:create("game/likuibuyu/bt_check_yes.png")
        lock:setTag(1)
        lock:setPosition(target:getContentSize().width/2, target:getContentSize().height/2)
        target:removeChildByTag(1)
        target:addChild(lock)

    else
         target:removeChildByTag(1)

         --取消自动射击
         self._scene._dataModel.m_fishIndex = g_var(cmd).INT_MAX

        --删除自动锁定图标
         local cannonPos = self._scene.m_nChairID
         if self._scene._dataModel.m_reversal then 
           cannonPos = 5 - cannonPos
         end

         local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)
         cannon:removeLockTag()

    end              
end


function LikuibuyuUiPanel:ShowCoin( score,wChairID,pos,fishtype )

  --print("score.."..score.."wChairID.."..wChairID.."fishtype.."..fishtype)
  -- mlog(DEBUG_W,"播放金币，。。。"..pos.x.. "  "..pos.y)
  self._scene._dataModel:playEffect("coinfly")

  local silverNum = {2,2,3,4,4}
  local goldNum = {1,1,1,2,2,3,3,4,5,6,8,16,16,16,18,18,18}
  
  local nMyNum = self._scene.m_nChairID/3
  local playerNum = wChairID/3

  local cannonPos = wChairID
--获取炮台
  if self._scene._dataModel.m_reversal then 
     cannonPos = 5 - cannonPos
   end

   local cannon = self._scene.m_cannonLayer:getCannoByPos(cannonPos + 1)

   if nil == cannon then
      return
   end

   local anim = nil
   local coinNum = 1
   local frameName = nil
   local distant = 50


  if fishtype < 5 then
    anim = cc.AnimationCache:getInstance():getAnimation("SilverAnim")
    frameName = "silver_coin_0.png"
    coinNum = silverNum[fishtype+1]
  elseif fishtype>=5 and fishtype<17 then
    anim = cc.AnimationCache:getInstance():getAnimation("GoldAnim")
    frameName = "gold_coin_0.png"

    coinNum = goldNum[fishtype+1]

  elseif fishtype == g_var(cmd).FishType.FishType_YuanBao then
    anim = cc.AnimationCache:getInstance():getAnimation("FishIgnotCoin")
    frameName = "ignot_coin_0.png"
    coinNum = 1
  end

  -- local posX = {}
  -- local initX = -105
  -- posX[1] = initX

  -- for i=2,10 do
  --   posX[i] = initX-(i-1)*39
  -- end

  local node = cc.Node:create()
  node:setAnchorPoint(0.5,0.5)
  node:setContentSize(cc.size(distant*5 , distant*4))
  
  if coinNum > 5 then
    node:setContentSize(cc.size(distant*5 , distant*2+40))
  end

  node:setPosition(pos.x, pos.y)
  self._scene.m_cannonLayer:addChild(node,1)

  if nil ~= anim then
      local action = cc.RepeatForever:create(cc.Animate:create(anim))
     
      if coinNum > 10 then
        coinNum = 10
      end
      -- mlog("score:"..score)
     -- local num = cc.LabelAtlas:create(string.format("%d", score),"game/likuibuyu/num_game_gold.png",37,34,string.byte("0"))
     local num = cc.Label:createWithCharMap("game/likuibuyu/num_game_gold.png",37,34,string.byte("0"))
     num:setString(string.format("%d", score))
     num:setAnchorPoint(0.5,0.5)
     num:setPosition(node:getContentSize().width/2, node:getContentSize().height-140)
     node:addChild(num)
     local call = cc.CallFunc:create(function()
       num:removeFromParent()
     end)

     num:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),call))

     local secondNum = coinNum
     if coinNum > 5 then
        secondNum = coinNum/2 
     end

     local node1 = cc.Node:create()
     node1:setContentSize(cc.size(distant*secondNum, distant))
     node1:setAnchorPoint(0.5,0.5)
     node1:setPosition(node:getContentSize().width/2, distant/2)
     node:addChild(node1)

     for i=1,secondNum do
       local coin = cc.Sprite:createWithSpriteFrameName(frameName)
       coin:runAction(action:clone())
       coin:setPosition(distant/2+(i-1)*distant, distant/2)
       node1:addChild(coin)
     end

     if coinNum > 5 then
       local firstNum = coinNum - secondNum
       local node2 = cc.Node:create()
       node2:setContentSize(cc.size(distant*firstNum, distant))
       node2:setAnchorPoint(0.5,0.5)
       node2:setPosition(node:getContentSize().width/2, distant*3/2)
       node:addChild(node2)

     end
  end

  local cannonPos = cc.p(cannon:getPositionX(),cannon:getPositionY())
  local call = cc.CallFunc:create(function()
    node:removeFromParent()
  end)

  node:runAction(cc.Sequence:create(cc.MoveBy:create(1.0,cc.p(0,40)),cc.MoveTo:create(0.5,cannonPos),call))

  local angle = 70.0
  local time = 0.12
  local moveY = 30.0

  if fishtype >= g_var(cmd).FishType.FishType_JianYu and fishtype <= g_var(cmd).FishType.FishType_LiKui then
    
    local goldCycle = self:getChildByTag(TAG.tag_GoldCycle + wChairID )
    if nil == goldCycle then
        goldCycle = cc.Sprite:create("game/likuibuyu/goldCircle.png")
        goldCycle:setTag(TAG.tag_GoldCycle + wChairID)

        goldCycle:setPosition(pos.x, pos.y)
        self:addChild(goldCycle,6)
        local call = cc.CallFunc:create(function( )
           goldCycle:removeFromParent()
        end)
        goldCycle:runAction(cc.Sequence:create(cc.RotateBy:create(time*18,360*1.3),call))
    end


    local goldTxt = self:getChildByTag(TAG.tag_GoldCycleTxt + wChairID)
    if goldTxt == nil then

      -- goldTxt = cc.LabelAtlas:create(string.format("%d", score),"game/likuibuyu/mutipleNum.png",14,17,string.byte("0"))
     goldTxt = cc.Label:createWithCharMap("game/likuibuyu/mutipleNum.png",14,17,string.byte("0"))
      goldTxt:setString(string.format("%d", score))
      goldTxt:setAnchorPoint(0.5,0.5)

      goldTxt:setPosition(pos.x, pos.y)          
      self:addChild(goldTxt,6)

      local action = cc.Sequence:create(cc.RotateTo:create(time*2,angle),cc.RotateTo:create(time*4,-angle),cc.RotateTo:create(time*2,0))
      local call = cc.CallFunc:create(function()  
          goldTxt:removeFromParent()
      end)

      goldTxt:runAction(cc.Sequence:create(action,call))

    end

  end

end

function LikuibuyuUiPanel:ShowAwardTip(data)


 local fishName = {"小黄刺鱼","小草鱼","热带黄鱼","大眼金鱼","热带紫鱼","小丑鱼","河豚鱼","狮头鱼","灯笼鱼","海龟","神仙鱼","蝴蝶鱼","铃铛鱼","剑鱼","魔鬼鱼","大白鲨","大金鲨","双头企鹅"
    ,"巨型黄金鲨","金龙","李逵","水浒传","忠义堂","爆炸飞镖","宝箱","元宝鱼"}

  local labelList = {}

  local tipStr  = nil
  local tipStr1 = nil
  local tipStr2 = nil

  if data.nFishMultiple >= 50 then
    if data.nScoreType == g_var(cmd).SupplyType.EST_Cold then
       tipStr = "捕中了"..fishName[data.nFishType+1]..",获得"
    elseif data.nScoreType == g_var(cmd).SupplyType.EST_Laser then
      
       tipStr = "使用激光,获得"
    end

  tipStr1 = string.format("%d倍 %d分数",data.nFishMultiple,data.lFishScore)
  if data.nFishMultiple > 500 then
     tipStr2 = "超神了!!!"
  elseif data.nFishMultiple == 19 then
       tipStr2 = "运气爆表!!!"   
  else
      tipStr2 = "实力超群!!!"     
  end

  local name = data.szPlayName
  local tableStr = nil
  if data.wTableID == self._scene.m_nTableID  then 
    tableStr = "本桌玩家"

  else
       tableStr = string.format("第%d桌玩家",data.wTableID+1)

  end

  -- local lb1 =  cc.Label:createWithTTF(tableStr, "fonts/round_body.ttf", 20)
   local lb1 = display.newText(tableStr, 26,Color.YELLOW)
  -- lb1:setTextColor(cc.YELLOW)
  lb1:setAnchorPoint(0,0.5)
  table.insert(labelList, lb1)
 

  -- local lb2 =  cc.Label:createWithTTF(name, "fonts/round_body.ttf", 20)
  local lb2 = display.newText(name, 26,Color.RED)
  -- lb2:setTextColor(cc.RED)
  lb2:setAnchorPoint(0,0.5)
  table.insert(labelList, lb2)

  -- local lb3 =  cc.Label:createWithTTF(tipStr, "fonts/round_body.ttf", 20)
  local lb3 = display.newText(tipStr, 26,Color.YELLOW)
  -- lb3:setTextColor(cc.YELLOW)
  lb3:setAnchorPoint(0,0.5)
  table.insert(labelList, lb3)

  -- local lb4 =  cc.Label:createWithTTF(tipStr1, "fonts/round_body.ttf", 20)
  local lb4 = display.newText(tipStr1, 26,Color.RED)
  -- lb4:setTextColor(cc.RED)
  lb4:setAnchorPoint(0,0.5)
  table.insert(labelList, lb4)

  -- local lb5 =  cc.Label:createWithTTF(tipStr2, "fonts/round_body.ttf", 20)
  local lb5 = display.newText(tipStr2, 26,Color.YELLOW)
  -- lb5:setTextColor(cc.YELLOW)
  lb5:setAnchorPoint(0,0.5)
  table.insert(labelList, lb5)

  else

    -- local lb1 =  cc.Label:createWithTTF("恭喜你捕中了补给箱,获得", "fonts/round_body.ttf", 20)
    local lb1 = display.newText("恭喜你捕中了补给箱,获得", 26,Color.YELLOW)
    -- lb1:setTextColor(cc.YELLOW)
    lb1:setAnchorPoint(0,0.5)

    -- local lb1 =  cc.Label:createWithTTF(string.format("%d倍 %d分数 !", data.nFishMultiple,data.lFishScore), "fonts/round_body.ttf", 20)
    local lb1 = display.newText(string.format("%d倍 %d分数 !", data.nFishMultiple,data.lFishScore), 26,Color.RED)
    -- lb1:setTextColor(cc.RED)
    lb1:setAnchorPoint(0,0.5)

    table.insert(labelList, lb1)
    table.insert(labelList, lb2)

  end



  local length = 60
  for i=1,#labelList do
    local lb = labelList[i]
    lb:setPosition(length - 30 , 20)
    length =  length + lb:getContentSize().width + 5 
  end


   local bg = ccui.ImageView:create("game/likuibuyu/clew_box.png")
    bg:setScale9Enabled(true)
  
    bg:setContentSize(length,40)
    bg:setScale(0.1)

    for i=1,#labelList do
      local lb = labelList[i]
      bg:addChild(lb)
    end

    self:ShowTipsForBg(bg)
    labelList = {}
end



function LikuibuyuUiPanel:updateUserScore( score )
    
    local _score  = self:getChildByTag(TAG.tag_gameScore)
    -- mlog(DEBUG_W,"_score",_score)
    -- mlog(DEBUG_W,"score",score)
    if nil ~=  _score then
        _score:setString(string.format("%d",score))
    end
end

function LikuibuyuUiPanel:updateMultiple( multiple )
    local _Multiple = self:getChildByTag(TAG.tag_gameMultiple)
    if nil ~=  _Multiple then
        _Multiple:setString(string.format("%d:",multiple))
    end

end


function LikuibuyuUiPanel:Showtips( tips )
  
    -- local lb =  cc.Label:createWithTTF(tips, "fonts/round_body.ttf", 20)
     local lb = display.newText(tips, 26,Color.YELLOW)
    local bg = ccui.ImageView:create("game/likuibuyu/clew_box.png")
    -- lb:setTextColor(cc.YELLOW)
    bg:setScale9Enabled(true)
    bg:setContentSize(cc.size(lb:getContentSize().width + 60  , 40))
    bg:setScale(0.1)
    lb:setPosition(bg:getContentSize().width/2, 20)
    bg:addChild(lb)

    self:ShowTipsForBg(bg)

end

function LikuibuyuUiPanel:ShowTipsForBg( bg )

  local infoCount = #self._scene.m_infoList
  local sublist = {}

  while infoCount >= 3 do

    local node = self._scene.m_infoList[1]
    table.remove(self._scene.m_infoList,1)
    node:removeFromParent()

    for i=1,#self._scene.m_infoList do
      local bg = self._scene.m_infoList[i]
      bg:runAction(cc.MoveBy:create(0.2,cc.p(0,60)))
    end

    infoCount = #self._scene.m_infoList
  end

  bg:setPosition(D_SIZE.width/2, D_SIZE.height-120-60*infoCount)
  self:addChild(bg,30)
  table.insert(self._scene.m_infoList, bg)

  local call = cc.CallFunc:create(function()
    bg:removeFromParent()
    for i=1,#self._scene.m_infoList do
      local _bg = self._scene.m_infoList[i]
      if bg == _bg then
        table.remove(self._scene.m_infoList,i)
        break
      end
    end

    if #self._scene.m_infoList > 0 then
      for i=1,#self._scene.m_infoList do

       local _bg = self._scene.m_infoList[i]
          _bg:runAction(cc.MoveBy:create(0.2,cc.p(0,60)))

       end
    end

  end)

  bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.17,1.0),cc.DelayTime:create(5),cc.ScaleTo:create(0.17,0.1,1.0),call)) 
end
return LikuibuyuUiPanel