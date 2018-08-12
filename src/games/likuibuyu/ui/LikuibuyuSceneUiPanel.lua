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

local  TAG = LikuibuyuUiPanel.VIEW_TAG

function LikuibuyuUiPanel:ctor()
	local game_bg = display.newImage("#game/likuibuyu/game_bg_0.png")
	game_bg:setAnchorPoint(cc.p(0,0))
	self:addChild(game_bg)
	self.game_bg = game_bg

    --底栏菜单栏
    local menuBG = display.newImage("#game/likuibuyu/game_buttom.png")
    menuBG:setAnchorPoint(0.5,0.0)
    menuBG:setScaleY(0.9)
    -- menuBG:setPosition(667, -6)
    self:addChild(Coord.ingap(self,menuBG,"CC",0,"BB",0),109,20)
    self.menuBG = menuBG


	--添加按钮
	local mutipleBtn = ccui.Button:create("game/likuibuyu/im_multiple_tip_0.png","game/likuibuyu/im_multiple_tip_1.png",nil)
	self:addChild(mutipleBtn)
	mutipleBtn:addTouchEventListener(function(sender,eventype)
	    if eventype == ccui.TouchEventType.ended then
            -- local index = self._scene._dataModel.m_secene.nMultipleIndex[1][self._scene.m_nChairID+1]
            -- index = index + 1
            -- index = math.mod(index,6)
        --     local cmddata = CCmd_Data:create(4)
        --  cmddata:setcmdinfo(yl.MDM_GF_GAME, g_var(cmd).SUB_C_MULTIPLE);
        --  cmddata:pushint(index)
        -- self._scene:sendNetData(cmddata) 
        end
    end)
    Coord.ingap(self,mutipleBtn,"CC",0,"BB",-20)
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

return LikuibuyuUiPanel