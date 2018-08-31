--服务器配置 
local server_config = {
	--版本请求地址
	version = {
		["sc"] = "http://218.244.150.113:7163/?port=6&&version=",
		["tc"] = "http://218.244.150.113:7163/?port=6&&version=",
		["en"] = "http://107.150.96.82:7163/?port=6&&version=",
	},
	--商店地址
	store = {
		["sc"] = "http://www.baidu.com",
		["en"] = "http://www.baidu.com",
	},
	--本地调试地址
	localserver = {
		
	},
	--审核服务器地址
	testserver = {
		
	},
	--47.106.250.105
	--220.128.128.40
	server = "tcp://220.128.128.40:6001",
	--接口地址
	apihost = "http://220.128.128.40:8360/game/"
}
return server_config
