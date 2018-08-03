--[[
*	全局type 常量定义，值不能被修改
*	##注意
*   	所有常量必须先定义在使用，不能运行时动态添加，同时也不能再运行时更改type的值
*
*	使用格式 ST.TEST
*	@author:lqh
]]
local R = {}
-- ---------------------------------------数值定义--------------------------------------------
R.TYPE_POP_OK 					= 0			--提示框 确定
R.TYPE_POP_NO 					= 1			--提示框 取消
R.TYPE_POP_NIL 					= 2			--提示框 关闭
R.TYPE_POP_FLAG_1				= 1			--提示框 显示2个按钮
R.TYPE_POP_FLAG_2 				= 2			--提示框 显示1个按钮

R.TYPE_PROGAM_ONBACK 				= 10000		--主程序进入后台
R.TYPE_PROGAM_ONFRONT 				= 10001		--主程序从后台进入前台
R.TYPE_SOCKET_CLOSE 				= -100		--主动关闭socket
R.TYPE_SOCKET_CLOSE_ALL				= -200		--主动关闭所有链接
R.TYPE_SOCKET_CREATE_ERROR 			= 100		--SOCKET创建失败
R.TYPE_SOCKET_CONNECT_ERROR 		= 101		--SOCKET初始化连接失败
R.TYPE_SOCKET_SEND_ERROR 			= 102		--SOCKET发送失败
R.TYPE_SOCKET_LARGE_DATA 			= 103		--SOCKET接收消息过长
R.TYPE_SOCKET_REV_ENCRYPTION 		= 104		--链接成功并收到后台通讯密钥
R.TYPE_SOCKET_OUTTIME 				= 111		--链接超时
R.TYPE_SOCKET_PING_TERMAIL			= 112		--ping暂停超过限制

R.TYPE_GAME_OPEN				= 0			--游戏已开启
R.TYPE_GAME_CLOSE				= 1			--游戏关闭

R.TYPE_GAME_SYSTEM_MSG			= 0			--系统跑马灯
R.TYPE_GAME_WIN_MSG				= 1			--游戏大奖跑马灯

R.TYPE_GAMEHALL_1				= 1			--棋牌游戏 大厅
R.TYPE_GAMEHALL_2				= 2			--百人街机游戏 大厅
R.TYPE_GAMEHALL_3				= 3			--捕鱼游戏 大厅
-- ---------------------------------------Player type----------------------------------------
R.PLY_HEADICON_LEN 				= 10		--玩家可选头像数量		

-- ---------------------------------------status type---------------------------------------
--每日status
--R.DAILYSTATUS_AWARD_GETED 		= 1
--持久status
R.STATUS_PLAYER_PSW_SETTED 		= 200			--是否已设置过银行密码	
R.STATUS_PLAYER_NAME_CHANGED 	= 201			--是否已更改过名字		
R.STATUS_PLAYER_GETAWARD_DAY 	= 202			--最近一次领取返利的日期		

-- ---------------------------------------game type 定义----------------------------------------
--百家乐
R.TYPE_GAMEBJL_PLAYER_0			= 0		--百家乐 闲家
R.TYPE_GAMEBJL_PLAYER_1			= 1		--百家乐 庄家
R.TYPE_GAMEBJL_WAIT				= 0		--百家乐	等待中
R.TYPE_GAMEBJL_ON_BET			= 1		--百家乐	下注中
R.TYPE_GAMEBJL_RESULT_0			= 0 	--百家乐	平
R.TYPE_GAMEBJL_RESULT_1			= 1 	--百家乐 同点平
R.TYPE_GAMEBJL_RESULT_2			= 2 	--百家乐 闲对
R.TYPE_GAMEBJL_RESULT_3			= 3 	--百家乐 庄对
R.TYPE_GAMEBJL_RESULT_4			= 4 	--百家乐 闲天王
R.TYPE_GAMEBJL_RESULT_5			= 5 	--百家乐 庄天王
R.TYPE_GAMEBJL_RESULT_6			= 6 	--百家乐 闲赢
R.TYPE_GAMEBJL_RESULT_7			= 7 	--百家乐 庄赢

--百人牛牛
R.TYPE_GAMEBRNN_WAIT			= 0		--百人牛牛 等待中
R.TYPE_GAMEBRNN_ON_BET			= 1		--百人牛牛 下注中
R.TYPE_GAMEBRNN_PLAYER_HEI		= 0		--百人牛牛 黑桃闲家
R.TYPE_GAMEBRNN_PLAYER_HONG		= 1		--百人牛牛 红桃闲家
R.TYPE_GAMEBRNN_PLAYER_YING		= 2		--百人牛牛 樱花闲家
R.TYPE_GAMEBRNN_PLAYER_FANG		= 3		--百人牛牛 方片闲家

--通比牛牛
R.TYPE_GAMETBNN_MAX_PLAYERS		= 5		--通比牛牛 最大玩家数量
R.TYPE_GAMETBNN_WAIT			= 0		--通比牛牛 等待中
R.TYPE_GAMETBNN_PLAYING			= 1		--通比牛牛 开始中
R.TYPE_GAMETBNN_READY			= 2		--通比牛牛 已准备
R.TYPE_GAMETBNN_NOT_READY		= 0		--通比牛牛 未准备
R.TYPE_GAMETBNN_SHOWDOWN		= 1		--通比牛牛 已摊牌
R.TYPE_GAMETBNN_NOT_SHOWDOWN	= 0		--通比牛牛 未摊牌
R.TYPE_GAMETBNN_AUTO			= 1		--通比牛牛 自动执行
R.TYPE_GAMETBNN_NOT_AUTO		= 0		--通比牛牛 未自动执行

--抢庄牛牛
R.TYPE_GAMEQZNN_MAX_PLAYERS		= 5		--抢庄牛牛 最大玩家数量
R.TYPE_GAMEQZNN_WAIT			= 0		--抢庄牛牛 等待中
R.TYPE_GAMEQZNN_PLAYING			= 1		--抢庄牛牛 开始中
R.TYPE_GAMEQZNN_PLAYSTATUS_MASTER = 0	--抢庄牛牛 抢庄中
R.TYPE_GAMEQZNN_PLAYSTATUS_ADDTIMES = 1	--抢庄牛牛 加倍中
R.TYPE_GAMEQZNN_PLAYSTATUS_PLAYING = 2	--抢庄牛牛 正常游戏中
R.TYPE_GAMEQZNN_READY			= 2		--抢庄牛牛 已准备
R.TYPE_GAMEQZNN_NOT_READY		= 0		--抢庄牛牛 未准备
R.TYPE_GAMEQZNN_SHOWDOWN		= 1		--抢庄牛牛 已摊牌
R.TYPE_GAMEQZNN_NOT_SHOWDOWN	= 0		--抢庄牛牛 未摊牌
R.TYPE_GAMEQZNN_AUTO			= 1		--抢庄牛牛 自动执行
R.TYPE_GAMEQZNN_NOT_AUTO		= 0		--抢庄牛牛 未自动执行

--三公
R.TYPE_GAMESANGONG_MAX_PLAYERS		= 5		--三公 最大玩家数量
R.TYPE_GAMESANGONG_WAIT			= 0		--三公 等待中
R.TYPE_GAMESANGONG_PLAYING			= 1		--三公 开始中
R.TYPE_GAMESANGONG_PLAYSTATUS_MASTER = 0	--三公 抢庄中
R.TYPE_GAMESANGONG_PLAYSTATUS_ADDTIMES = 1	--三公 加倍中
R.TYPE_GAMESANGONG_PLAYSTATUS_PLAYING = 2	--三公 正常游戏中
R.TYPE_GAMESANGONG_READY			= 2		--三公 已准备
R.TYPE_GAMESANGONG_NOT_READY		= 0		--三公 未准备
R.TYPE_GAMESANGONG_SHOWDOWN		= 1		--三公 已摊牌
R.TYPE_GAMESANGONG_NOT_SHOWDOWN	= 0		--三公 未摊牌
R.TYPE_GAMESANGONG_AUTO			= 1		--三公 自动执行
R.TYPE_GAMESANGONG_NOT_AUTO		= 0		--三公 未自动执行

--红黑大战
R.TYPE_GAMEHHDZ_WAIT			= 0		--红黑大战 等待中
R.TYPE_GAMEHHDZ_ON_BET			= 1		--红黑大战 下注中
R.TYPE_GAMEHHDZ_BET_BLACK		= 1		--红黑大战 下注黑色区域
R.TYPE_GAMEHHDZ_BET_RED			= 2		--红黑大战 下注红色区域
R.TYPE_GAMEHHDZ_BET_OTHERS		= 0		--红黑大战 下注其他区域



-- ---------------------------------------Command type--------------------------------------
--[[
* Command事件定义，以COMMAND 开头
]]
R.COMMAND_SERVER_TIME 				= 1				--服务器时间更新事件
R.COMMAND_MAINSOCKET_BREAK			= 99			--主socket断开连接
R.COMMAND_SOCKET_BREAK				= 100			--socket 断开连接
R.COMMAND_PLAYER_LOGIN				= 110			--玩家登陆成功
R.COMMAND_GAME_DOWNLOAD				= 200			--单个游戏下载
R.COMMAND_PLAYER_GOLD_UPDATE		= 300			--玩家金币更新
R.COMMAND_PLAYER_HEAD_UPDATE		= 301			--玩家头像更新
R.COMMAND_PLAYER_NAME_UPDATE		= 302			--玩家名字更新
R.COMMAND_PLAYER_STATUS_UPDATE		= 303			--玩家持久状态更新
R.COMMAND_PLAYER_DAILYSTATUS_UPDATE	= 304			--玩家每日状态更新
R.COMMAND_GAME_SCROLL_MSG			= 351			--跑马灯事件
R.COMMAND_GAME_PSW_QUIT				= 352			--退出设置密码界面
R.COMMAND_GAME_HALL_PLAYERS_UPDATE	= 353			--大厅人数改变
R.COMMAND_PLAYER_BANK_GOLD_UPDATE	= 360			--银行玩家金币更新
--百家乐
R.COMMAND_GAMEBJL_INITROOM			= 1001			--百家乐房	间初始化完成
R.COOMAND_GAMEBJL_BEGANBET			= 1002			--百家乐房	开始下注
R.COMMAND_GAMEBJL_RESULT			= 1003			--百家乐房	收到牌局结果
R.COMMAND_GAMEBJL_BET				= 1004			--百家乐房	收到下注数据
R.COMMAND_GAMEBJL_POKER_OVER		= 1010			--百家乐房	比牌 显示结束
R.COMMAND_GAMEBJL_RESULT_OVER		= 1011			--百家乐房	结果显示 结束
R.COMMAND_GAMEBJL_DESKTOP_OVER		= 1012			--百家乐房	桌面结果 显示结束
--百人牛牛
R.COMMAND_GAMEBRNN_INITROOM			= 3001			--百人牛牛	房间初始化完成
R.COOMAND_GAMEBRNN_BEGANBET			= 3002			--百人牛牛	开始下注
R.COMMAND_GAMEBRNN_RESULT			= 3003			--百人牛牛	收到牌局结果
R.COMMAND_GAMEBRNN_BET				= 3004			--百人牛牛	收到下注数据
R.COMMAND_GAMEBRNN_APPLYNUM_UPDATE	= 3005			--百人牛牛	上庄申请人数变化
R.COMMAND_GAMEBRNN_MASTER_UPDATE	= 3006			--百人牛牛	庄家序列化
R.COMMAND_GAMEBRNN_POKER_OVER		= 3010			--百人牛牛	比牌 显示结束
R.COMMAND_GAMEBRNN_RESULT_OVER		= 3011			--百人牛牛	结果显示 结束
R.COMMAND_GAMEBRNN_DESKTOPPLAYERS_UPDATE = 3012		--百人牛牛	桌面玩家显示更新

--通比牛牛
R.COMMAND_GAMETBNN_ENTRYROOM		= 4001			--通比牛牛	进入房间
R.COOMAND_GAMETBNN_BEGAN			= 4002			--通比牛牛	发牌开始
R.COOMAND_GAMETBNN_SEND_OVER		= 4003			--通比牛牛	发牌结束
R.COMMAND_GAMETBNN_RESULT			= 4004			--通比牛牛	收到牌局结果
R.COMMAND_GAMETBNN_RESULT_OVER		= 4005			--通比牛牛	牌局结果显示结束
R.COMMAND_GAMETBNN_SHOWDOWN			= 4006			--通比牛牛	摊牌
R.COMMAND_GAMETBNN_SHOWDOWN_OVER	= 4007			--通比牛牛	所有人摊牌结束
R.COMMAND_GAMETBNN_PLAYERCHANGE		= 4008			--通比牛牛	玩家变动
R.COMMAND_GAMETBNN_READYSTATUS_UPDATE=4009			--通比牛牛	玩家准备状态发生改变
R.COMMAND_GAMETBNN_AWARD_UPDATE		= 4010			--通比牛牛	彩金变化

--抢庄牛牛
R.COMMAND_GAMEQZNN_ENTRYROOM		= 4201			--抢庄牛牛	进入房间
R.COOMAND_GAMEQZNN_BEGAN			= 4202			--抢庄牛牛	发牌开始
R.COOMAND_GAMEQZNN_SEND_OVER		= 4203			--抢庄牛牛	发牌结束
R.COMMAND_GAMEQZNN_RESULT			= 4204			--抢庄牛牛	收到牌局结果
R.COMMAND_GAMEQZNN_RESULT_OVER		= 4205			--抢庄牛牛	牌局结果显示结束
R.COMMAND_GAMEQZNN_SHOWDOWN			= 4206			--抢庄牛牛	摊牌
R.COMMAND_GAMEQZNN_PLAYERCHANGE		= 4208			--抢庄牛牛	玩家变动
R.COMMAND_GAMEQZNN_READYSTATUS_UPDATE=4209			--抢庄牛牛	玩家准备状态发生改变
R.COMMAND_GAMEQZNN_BEGAN_GET_MASTER = 4210			--抢庄牛牛	开始抢庄
R.COMMAND_GAMEQZNN_MASTER_VALUE 	= 4211			--抢庄牛牛	抢庄倍数
R.COMMAND_GAMEQZNN_BEGAN_ADD_TIMES 	= 4212			--抢庄牛牛	开始加倍
R.COMMAND_GAMEQZNN_TIMES_VALUE 		= 4213			--抢庄牛牛	加倍倍数

--三公
R.COMMAND_GAMESANGONG_ENTRYROOM		= 4401			--三公	进入房间
R.COOMAND_GAMESANGONG_BEGAN			= 4402			--三公	发牌开始
R.COOMAND_GAMESANGONG_SEND_OVER		= 4403			--三公	发牌结束
R.COMMAND_GAMESANGONG_RESULT			= 4404			--三公	收到牌局结果
R.COMMAND_GAMESANGONG_RESULT_OVER		= 4405			--三公	牌局结果显示结束
R.COMMAND_GAMESANGONG_SHOWDOWN			= 4406			--三公	摊牌
R.COMMAND_GAMESANGONG_PLAYERCHANGE		= 4408			--三公	玩家变动
R.COMMAND_GAMESANGONG_READYSTATUS_UPDATE=4409			--三公	玩家准备状态发生改变
R.COMMAND_GAMESANGONG_BEGAN_GET_MASTER = 4410			--三公	开始抢庄
R.COMMAND_GAMESANGONG_MASTER_VALUE 	= 4411			--三公	抢庄倍数
R.COMMAND_GAMESANGONG_BEGAN_ADD_TIMES 	= 4412			--三公	开始加倍
R.COMMAND_GAMESANGONG_TIMES_VALUE 		= 4413			--三公	加倍倍数

--红黑大战
R.COMMAND_GAMEHHDZ_INITROOM			= 5001			--红黑大战	房间初始化完成
R.COOMAND_GAMEHHDZ_BEGAN			= 5002			--红黑大战	开始
R.COOMAND_GAMEHHDZ_OVER				= 5003			--红黑大战	结束
R.COOMAND_GAMEHHDZ_BEGAN_ANIM_OVER	= 5004			--红黑大战	开始全屏动画播放结束
R.COOMAND_GAMEHHDZ_OPEN_POKER_OVER	= 5007			--红黑大战	翻牌动画结束
R.COOMAND_GAMEHHDZ_BET				= 5008			--红黑大战	收到下注数据

--飞禽走兽
R.COMMAND_GAMEFQZS_UPDATEDROP		= 2001			--更新之前的结果集
R.COMMAND_GAMEFQZS_BETBEGIN			= 2002			--下注开始
R.COMMAND_GAMEFQZS_BETEND			= 2003			--下注结束
R.COMMAND_GAMEFQZS_BETCHANGE		= 2004			--桌面下注
R.COMMAND_GAMEFQZS_INITWAIT			= 2005			--初始化等待
R.COMMAND_GAMEFQZS_UPDATEBANKER		= 2006			--更新庄家数据
R.COMMAND_GAMEFQZS_UPDATEAPPLY		= 2007			--更新申请
R.COMMAND_GAMEFQZS_UPBANKERSTATE	= 2008			--更新自己的的庄家状态
--金鲨银鲨
R.COMMAND_GAMEJSYS_UPDATEDROP		= 2101			--更新之前的结果集
R.COMMAND_GAMEJSYS_BETBEGIN			= 2102			--下注开始
R.COMMAND_GAMEJSYS_BETEND			= 2103			--下注结束
R.COMMAND_GAMEJSYS_BETCHANGE		= 2104			--桌面下注
R.COMMAND_GAMEJSYS_INITWAIT			= 2105			--初始化等待
--豪车漂移
R.COMMAND_GAMEHCPY_UPDATEDROP		= 2001			--更新之前的结果集
R.COMMAND_GAMEHCPY_BETBEGIN			= 2002			--下注开始
R.COMMAND_GAMEHCPY_BETEND			= 2003			--下注结束
R.COMMAND_GAMEHCPY_BETCHANGE		= 2004			--桌面下注
R.COMMAND_GAMEHCPY_INITWAIT			= 2005			--初始化等待
R.COMMAND_GAMEHCPY_UPDATEBANKER		= 2006			--更新庄家数据
R.COMMAND_GAMEHCPY_UPDATEAPPLY		= 2007			--更新申请
R.COMMAND_GAMEHCPY_UPBANKERSTATE	= 2008			--更新自己的的庄家状态
--包大人
R.COMMAND_GAMEBDR_FREE_STATE		= 2201			--包大人免费状态
R.COMMAND_GAMEBDR_NORMAL_STATE		= 2202			--包大人正常状态

Gbv.ST = {}
setmetatable(ST,{
	__index = function(t,k) 
		if not R[k] then mlog(DEBUG_E,string.format("<ST>:attempt to read undeclared variable, key = <%s>",k)) end
		return R[k]
	end,
	__newindex = function(t,k,v)
		if R[k] then
			mlog(DEBUG_E,string.format("<ST>:can not change ST property(%s) value!",k))
			return
		end
		mlog(DEBUG_E,string.format("<ST> attempt to write new variable ,key = <%s>",k))
  	end,
  	__metatable = "You cannot get the protect metatable"
})

return ST
