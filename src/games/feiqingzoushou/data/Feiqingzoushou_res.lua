local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	--飞禽走兽
	{url="game/feiqingzoushou/FeiQingZouShou_UI.plist",imgurl = "game/feiqingzoushou/FeiQingZouShou_UI.png",size = 738*1961},
	{url="game/feiqingzoushou/fqzs_bird.plist",imgurl = "game/feiqingzoushou/fqzs_bird.png",size = 1606*524},
	{url="game/feiqingzoushou/fqzs_dove.plist",imgurl = "game/feiqingzoushou/fqzs_dove.png",size = 1370*476},
	{url="game/feiqingzoushou/fqzs_eagle.plist",imgurl = "game/feiqingzoushou/fqzs_eagle.png",size = 1644*492},
	{url="game/feiqingzoushou/fqzs_lion.plist",imgurl = "game/feiqingzoushou/fqzs_lion.png",size = 1452*452},
	{url="game/feiqingzoushou/fqzs_monkey.plist",imgurl = "game/feiqingzoushou/fqzs_monkey.png",size = 1548*476},
	{url="game/feiqingzoushou/fqzs_peacock.plist",imgurl = "game/feiqingzoushou/fqzs_peacock.png",size = 1636*500},
	{url="game/feiqingzoushou/fqzs_rabbit.plist",imgurl = "game/feiqingzoushou/fqzs_rabbit.png",size = 2020*248},
	{url="game/feiqingzoushou/fqzs_shark.plist",imgurl = "game/feiqingzoushou/fqzs_shark.png",size = 746*1432},
	{url="game/feiqingzoushou/fqzs_panda.plist",imgurl = "game/feiqingzoushou/fqzs_panda.png",size = 1372*402},
	{url="game/feiqingzoushou/clock_ring.plist",imgurl = "game/feiqingzoushou/clock_ring.png",size = 478*1063},
	{url="game/feiqingzoushou/fqzs_goldshark.plist",imgurl = "game/feiqingzoushou/fqzs_goldshark.png",size = 1000*555},
	{url="game/feiqingzoushou/fqzs_shark_gui.plist",imgurl = "game/feiqingzoushou/fqzs_shark_gui.png",size = 952*720},
	{imgurl = "game/feiqingzoushou/fqzs-fly-main-backdrop.png",size = 1143*656},
	{imgurl = "game/feiqingzoushou/fqzs-fly-main-background.png",size = 1360*765},
	{imgurl = "game/feiqingzoushou/fqzs-rule-bg.png",size = 1125*514},
	{imgurl = "game/feiqingzoushou/fqzs_vip_142_21.png",size = 142*21},
	{imgurl = "game/feiqingzoushou/fqzs-guize-content.png",size = 968*106},
	{imgurl = "game/feiqingzoushou/fqzs-rule-content.png",size = 1010*331},
	{imgurl = "game/feiqingzoushou/fqzs_number_1.png",size = 230*33},
	{imgurl = "game/feiqingzoushou/fqzs_number_2.png",size = 580*82}
}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	{url="game/feiqingzoushou/sound/fqzs_bg.mp3",loadtype=0},
	{url="game/feiqingzoushou/sound/fqzs_countdown.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_countdown_ring.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_1.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_2.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_3.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_4.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_5.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_6.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_7.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_8.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_9.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_10.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_11.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_element_12.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_turn.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_start_wager.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_end_wager.mp3",loadtype=1},
	{url="game/feiqingzoushou/sound/fqzs_score.mp3",loadtype=1},
}
--动作资源管理器
resource.animations={
	{name="fqzs_dove",begnum=1,endnum=17,photoname="fqzs_dove_",Format=".png",delay=0.2},
	{name="fqzs_monkey",begnum=1,endnum=13,photoname="fqzs_monkey_",Format=".png",delay=0.2},
	{name="fqzs_peacock",begnum=1,endnum=14,photoname="fqzs_peacock_",Format=".png",delay=0.2},
	{name="fqzs_eagle",begnum=1,endnum=13,photoname="fqzs_eagle_",Format=".png",delay=0.2},
	{name="fqzs_shark",begnum=1,endnum=17,photoname="fqzs_shark_",Format=".png",delay=0.2},
	{name="fqzs_lion",begnum=1,endnum=12,photoname="fqzs_lion_",Format=".png",delay=0.2},
	{name="fqzs_rabbit",begnum=1,endnum=12,photoname="fqzs_rabbit_",Format=".png",delay=0.2},
	{name="fqzs_bird",begnum=1,endnum=10,photoname="fqzs_bird_",Format=".png",delay=0.2},
	{name="fqzs_panda",begnum=1,endnum=13,photoname="fqzs_panda_",Format=".png",delay=0.2},
	{name="fqzs_goldshark",begnum=1,endnum=15,photoname="fqzs_goldshark_",Format=".png",delay=0.2},
	{name="fqzs_gold",begnum=1,endnum=4,photoname="fqzs_gold_",Format=".png",delay=0.2},
	{name="fqzs_wenzi_jinsha",begnum=1,endnum=11,photoname="fqzs_wenzi_",Format=".png",delay=0.2},
	{name="fqzs_clock_ring_5",begnum=1,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fqzs_clock_ring_4",begnum=9,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fqzs_clock_ring_3",begnum=17,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fqzs_clock_ring_2",begnum=25,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fqzs_clock_ring_1",begnum=33,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
}

return resource