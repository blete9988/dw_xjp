--[[
*	抢庄牛牛推送端口
* 
*	@author：lqh
]]
local Likuibuyu_Port = {}
local ExternalFun = require("src.games.likuibuyu.content.ExternalFun")
local cmd = "src.games.likuibuyu.content.models.CMD_LKGame"
local g_var = ExternalFun.req_var


function Likuibuyu_Port.extend(data)
	local player = Player
	
	local handler = function(data)
		local tp = data:readUnsignedShort()
		mlog(tp,"捕鱼推送返回")
		if tp == cmd.SUB_S_FISH_CATCH then
	mlog("李逵捕鱼catch捕获鱼收到数据返回！")
			
		elseif tp == cmd.SUB_S_FISH_CREATE then
	mlog("李逵捕鱼创建鱼收到数据返回！")

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
			
		elseif tp == cmd.SUB_S_FIRE then
			--摊牌
	mlog("李逵捕鱼收到kaihuo数据返回！")
			
		elseif tp == cmd.SUB_S_OVER then
			--开始抢庄
	mlog("李逵捕鱼结算收到数据返回！")
			
		elseif tp == cmd.SUB_S_STAY_FISH then
			--抢庄
	mlog("李逵捕鱼停留鱼120收到数据返回！")
			
		elseif tp == cmd.SUB_S_SYNCHRONOUS then
			--开始加倍
	mlog("李逵捕鱼同步信息101收到数据返回！")
			

		end
	end
	return handler
end
return Likuibuyu_Port
