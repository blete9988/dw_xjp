--[[
*	推送端口
* 
*	@author：zj
]]
local Likuibuyu_Port = {}
local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")
local cmd = "src.games.likuibuyu.content.models.CMD_LKGame"
local g_var = ExternalFun.req_var


function Likuibuyu_Port.extend(data)
	local player = Player
	local dataModel  = require("src.games.likuibuyu.content.GameFrame").getInstance()
	local handler = function(data)
		local tp = data:readUnsignedShort()
		mlog(tp,"捕鱼推送返回")
		if tp == cmd.SUB_S_FISH_CATCH then
			mlog("李逵捕鱼catch捕获鱼收到数据返回！")
		

			dataModel.m_secene.curscene:onSubFishCatch(data)

		elseif tp == cmd.SUB_S_FISH_CREATE then
			mlog("李逵捕鱼创建鱼收到数据返回！")
		  	if math.mod(data:getlen(),577) == 0 then --576 sizeof(CMD_S_FishCreate)
		        --通知
		      -- local event = cc.EventCustom:new(g_var(cmd).Event_FishCreate)
		      -- cc.Director:getInstance():getEventDispatcher():dispatchEvent(event)
		      
		  		--鱼创建
		  		self:onSubFishCreate(data)
		  	end
			--玩家准备状态
		elseif tp == cmd.SUB_S_DELAY_BEGIN then
			--收到结果
			mlog("李逵捕鱼延迟107收到数据返回！")
			
		elseif tp == cmd.SUB_S_DELAY then
			--发牌
			mlog("李逵捕鱼延迟108收到数据返回！")
			
		elseif tp == cmd.SUB_S_EXCHANGE_SCENE then
			--有玩家退出
			mlog("李逵捕鱼切换场景收到数据返回！")
			dataModel.m_secene.curscene:onSubExchangeScene(data)

		elseif tp == cmd.SUB_S_FIRE then
			--摊牌
			mlog("李逵捕鱼收到kaihuo数据返回！")
			
			dataModel.m_secene.curscene:onSubFire(data)
		elseif tp == cmd.SUB_S_OVER then
			--开始抢庄
			mlog("李逵捕鱼结算收到数据返回！")
			
		elseif tp == cmd.SUB_S_STAY_FISH then
			--抢庄
			mlog("李逵捕鱼停留鱼120收到数据返回！")

			dataModel.m_secene.curscene:onSubStayFish(data)
			
		elseif tp == cmd.SUB_S_SYNCHRONOUS then
			--开始加倍
			mlog("李逵捕鱼同步信息101收到数据返回！")
			
			dataModel.m_secene.curscene:onSubSynchronous(data)

		elseif tp == cmd.SUB_S_UPDATE_GAME then --更新游戏
			-- self:onSubUpdateGame(dataBuffer)
		  local update = ExternalFun.read_netdata(g_var(cmd).CMD_S_UpdateGame,databuffer)
		  require("src.games.likuibuyu.content.GameFrame").getInstance().m_secene.nBulletVelocity = update.nBulletVelocity
		  require("src.games.likuibuyu.content.GameFrame").getInstance().m_secene.nBulletCoolingTime = update.nBulletCoolingTime
		  require("src.games.likuibuyu.content.GameFrame").getInstance().m_secene.nFishMultiple = update.nFishMultiple
		  require("src.games.likuibuyu.content.GameFrame").getInstance().m_secene.nMultipleValue = update.nMultipleValue

		  elseif tp == cmd.SUB_S_SUPPLY then --补给
		  	dataModel.m_secene.curscene:onSubSupply(data)
		 elseif tp == cmd.SUB_S_MULTIPLE then --beishu
		  	dataModel.m_secene.curscene:onSubMultiple(data)

		elseif tp == cmd.SUB_S_SUPPLY_TIP then --更新游戏
		  	dataModel.m_secene.curscene:onSubSupplyTip(data)
		
		end

	end
	return handler
end
return Likuibuyu_Port
