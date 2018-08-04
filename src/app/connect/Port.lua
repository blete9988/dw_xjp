--[[
*	连接端口 常量定义
*	@author：lqh
]]
local port = {}

--服务器push channel
port.PING_CHANNEL 					= 2			--ping频道
port.CUSTOM_RETURN_CHANNEL 			= 2000		--通用推送频道
-- ----------------------------------请求端口--------------------------------------
port.PORT_SERVER					= 1001		--登陆初始化端口
port.PORT_PING 						= 1002		--ping
port.PORT_NORMAL					= 1100		--大厅端口
port.PORT_LEADERBOARD				= 1107		--排行榜端口
port.PORT_EMAIL						= 1314		--邮件端口
port.PORT_CHARGE 					= 1315		--充值端口

port.PORT_FEIQINGZOUSHOU            = 1201		--飞禽走兽
port.PORT_JBACK_FEIQINGZOUSHOU      = 3002		--飞禽走兽推送
port.PORT_BJL						= 1200		--百家乐端口
port.PORT_JBACK_BJL					= 3001		--百家乐推送端口
port.PORT_BRNN						= 1208		--百人牛牛端口
port.PORT_JBACK_BRNN				= 4001		--百人牛牛推送端口
port.PORT_TBNN						= 1209		--通比牛牛端口
port.PORT_JBACK_TBNN				= 4002		--通比牛牛推送端口
port.PORT_HHDZ						= 1300		--红黑大战端口
port.PORT_JBACK_HHDZ				= 3006		--红黑大战推送端口
port.PORT_QZNN						= 1210		--抢庄牛牛端口
port.PORT_SANGONG					= 1220		--三公端口
port.PORT_JBACK_QZNN				= 4003		--抢庄牛牛推送端口
port.PORT_JBACK_SANGONG				= 3007		--三公推送端口
port.PORT_JINSHAYINSHA				= 1202		--金鲨银鲨
port.PORT_JBACK_JINSHAYINSHA		= 3005		--金鲨银鲨推送

port.PORT_HAOCHEPIAOYI				= 1203		--豪车漂移
port.PORT_JBACK_HAOCHEPIAOYI		= 3004		--豪车漂移推送

port.PORT_FISTSUPERMAN				= 1204		--一拳超人
port.PORT_BAODAREN					= 1205		--包大人
port.PORT_FEILONGZAITIAN			= 1206		--飞龙在天
port.PORT_SHUIHUZHUAN				= 1207		--水浒传
port.PORT_ZHAOCHAIBIANPAO			= 1218		--招财鞭炮
port.PORT_SHUIGUOLABA				= 1219		--水果拉吧
Gbv.Port = {}
setmetatable(Port,{
	__index = function(t,k) 
		if not port[k] then error(string.format("<Port>:attempt to read undeclared variable, key = <%s>",k)) end
		return port[k]
	end,
  	__newindex = function(t,k,v)
		if port[k] then
			error(string.format("<Port>:can not change port property(%s) value!",k))
			return
		end
		error(string.format("<Port>:attempt to write new variable ,key = <%s>",k))
  	end,
  	__metatable = "You cannot get the protect metatable"
})
return Port