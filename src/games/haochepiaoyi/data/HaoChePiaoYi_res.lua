local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{url="game/haochepiaoyi/fcpy_main.plist",imgurl = "game/haochepiaoyi/fcpy_main.png",size = 1971*783},
	{url="game/haochepiaoyi/clock_ring.plist",imgurl = "game/haochepiaoyi/clock_ring.png",size = 478*1063},
	{url="game/haochepiaoyi/fcpy_result.plist",imgurl = "game/haochepiaoyi/fcpy_result.png",size = 494*1449},
	{imgurl = "game/haochepiaoyi/fcpy_vip_142_21.png",size = 142*21},
	{imgurl = "game/haochepiaoyi/fcpy_number-240x32.png",size = 240*32},
	{imgurl = "game/haochepiaoyi/fcpy_number_1.png",size = 230*33},
	{imgurl = "game/haochepiaoyi/fcpy_number_2.png",size = 200*28},
	{imgurl = "game/haochepiaoyi/fcpy_number_3.png",size = 286*30},
	{imgurl = "game/haochepiaoyi/fcpy_number_4.png",size = 180*24},
	{imgurl = "game/haochepiaoyi/fcpy_number_5.png",size = 180*30},
	{imgurl = "game/haochepiaoyi/fcpy_number_6.png",size = 580*82}
}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	-- {url="game/feiqingzoushou/sound/fqzs_bg.mp3",loadtype=0},
	{url="game/haochepiaoyi/sound/fcpy_award_bg.mp3",loadtype=0},
	{url="game/haochepiaoyi/sound/fcpy_bg.mp3",loadtype=0},
	{url="game/haochepiaoyi/sound/fcpy_countdown.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_countdown_ring.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_end_wager.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_lose.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_score.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_select.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_start_wager.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_turn.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_turn_end.mp3",loadtype=1},
	{url="game/haochepiaoyi/sound/fcpy_win.mp3",loadtype=1}
}
--动作资源管理器
resource.animations={
	{name="fcpy_clock_ring_5",begnum=1,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fcpy_clock_ring_4",begnum=9,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fcpy_clock_ring_3",begnum=17,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fcpy_clock_ring_2",begnum=25,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fcpy_clock_ring_1",begnum=33,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="fcpy_yan",begnum=1,endnum=9,photoname="fcpy_yan_",Format=".png",delay=0.1}
	-- {name="fqzs_dove",begnum=1,endnum=17,photoname="fqzs_dove_",Format=".png",delay=0.2},
}

return resource