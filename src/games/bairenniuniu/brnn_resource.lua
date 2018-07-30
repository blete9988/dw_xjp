local resource={}
resource.plists={
	{imgurl = "game/bairenniuniu/brnn_desktop_background.jpg",size = 1360*765},
	{url="game/bairenniuniu/brnn_poker.plist",imgurl = "game/bairenniuniu/brnn_poker.png",size = 1623*512},
	{url="game/bairenniuniu/brnn_public.plist",imgurl = "game/bairenniuniu/brnn_public.png",size = 2043*728},
	{imgurl = "game/bairenniuniu/brnn_number_1.png",size = 230*33},
	{imgurl = "game/bairenniuniu/brnn_number_2.png",size = 142*21},
	{imgurl = "game/bairenniuniu/brnn_number_3.png",size = 580*82},
}

resource.sounds={
	{url="game/bairenniuniu/sounds/brnn_bg.mp3"},
	{url="game/bairenniuniu/sounds/brnn_countdown.mp3"},
	{url="game/bairenniuniu/sounds/brnn_countdown_ring.mp3"},
	{url="game/bairenniuniu/sounds/brnn_fanpai.mp3"},
	{url="game/bairenniuniu/sounds/brnn_dong.mp3"},
	{url="game/bairenniuniu/sounds/brnn_send_card.mp3"},
	{url="game/bairenniuniu/sounds/brnn_bet_end.mp3"},
	{url="game/bairenniuniu/sounds/brnn_bet_start.mp3"},
	{url="game/bairenniuniu/sounds/brnn_add_bet.mp3"},
	{url="game/bairenniuniu/sounds/brnn_result_lose.mp3"},
	{url="game/bairenniuniu/sounds/brnn_result_nobet.mp3"},
	{url="game/bairenniuniu/sounds/brnn_result_win.mp3"},
	{url="game/bairenniuniu/sounds/brnn_result_niuniu.mp3"},
	{url="game/bairenniuniu/sounds/brnn_zhuang_change.mp3"},
	{url="game/bairenniuniu/sounds/brnn_get_gold.mp3"},
}
resource.animations={
	{name="brnn_clock_ring_5",begnum=1,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="brnn_clock_ring_4",begnum=9,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="brnn_clock_ring_3",begnum=17,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="brnn_clock_ring_2",begnum=25,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="brnn_clock_ring_1",begnum=33,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="brnn_fanpai",begnum=1,endnum=7,photoname="brnn_fanpai_",Format=".png",delay=0.06},
	{name="brnn_fanpai_over",begnum=8,endnum=9,photoname="brnn_fanpai_",Format=".png",delay=0.04},
	{name="brnn_zhuozhuang",begnum=1,endnum=3,photoname="ui_brnn_1046_effect_",Format=".png",delay=0.1},
}

--jinrf Distributed desgin
--resource.initNet=function(addr,callback)
--	mlog(string.format("bairenniuniu resource ininet addr = %s",addr))
--	local url = "src.app.communication.CFLoadingNetMgr"
--	local netInit = require(url).new() 
--	CFLoadingNetMgr:connect(addr or "tcp://192.168.1.112:6101",function(ret,socketID)
--		if ret == netInit.RET_TYPE.SUCC then
--			mlog("resource.initNet callback success")
--			if callback then
--				callback(socketID)
--			end
--		else
--			if callback then
--				callback(0)
--			end
--		end
--	end)
--	package.loaded[url]=nil
--
--	--	local url = "src.games.catchFish.src.app.communication.CMD_InitNet"
--	--	require(url):exec(addr or "tcp://192.168.1.112:6101",callback)
--	--	package.loaded[url]=nil
--end

return resource