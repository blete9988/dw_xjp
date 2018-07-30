local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{url="game/firecracker/firecracker_07.plist",imgurl = "game/firecracker/firecracker_07.png",size = 1861*396},
	{url="game/firecracker/firecracker_08.plist",imgurl = "game/firecracker/firecracker_08.png",size = 1011*969},
	{url="game/firecracker/firecracker_09.plist",imgurl = "game/firecracker/firecracker_09.png",size = 938*1085},
	{url="game/firecracker/firecracker_10.plist",imgurl = "game/firecracker/firecracker_10.png",size = 942*1047},
	{url="game/firecracker/firecracker_11.plist",imgurl = "game/firecracker/firecracker_11.png",size = 1918*368},
	{url="game/firecracker/firecracker_12.plist",imgurl = "game/firecracker/firecracker_12.png",size = 951*1192},
	{url="game/firecracker/firecracker_13.plist",imgurl = "game/firecracker/firecracker_13.png",size = 197*1362},
	{url="game/firecracker/firecracker_13tp.plist",imgurl = "game/firecracker/firecracker_13tp.png",size = 1019*1110},
	{url="game/firecracker/firecracker_icon.plist",imgurl = "game/firecracker/firecracker_icon.png",size = 395*891},
	{url="game/firecracker/firecracker_main.plist",imgurl = "game/firecracker/firecracker_main.png",size = 1264*465},
	{url="game/firecracker/public_frame.plist",imgurl = "game/firecracker/public_frame.png",size = 2016*1950},
	{url="game/firecracker/firecracker_firework.plist",imgurl = "game/firecracker/firecracker_firework.png",size = 1836*783},
	{url="game/firecracker/firecracker_13prize_one.plist",imgurl = "game/firecracker/firecracker_13prize_one.png",size = 1950*1540},
	{url="game/firecracker/firecracker_13prize_two.plist",imgurl = "game/firecracker/firecracker_13prize_two.png",size = 1754*1792},
	{imgurl = "game/firecracker/firecracker_Base_bg.jpg",size = 1360*765},
	{imgurl = "game/firecracker/firecracker_free_bg.jpg",size = 1360*765},
	{imgurl = "game/firecracker/firecracker_content.png",size = 1044*541},
	{imgurl = "game/firecracker/firecracker_mask_1.png",size = 192*486},
	{imgurl = "game/firecracker/firecracker_reward.png",size = 521*322},
	{imgurl = "game/firecracker/fontnumber_27X37.png",size = 270*37}
}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	--鞭炮
	{url="game/firecracker/sound/firecracker_bg.mp3",loadtype=0},
	{url="game/firecracker/sound/firecracker_free_bg.mp3",loadtype=0},
	{url="game/firecracker/sound/firecrack_free_over.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_tq1.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_tq3.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_win1.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_win2.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_win3.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_win4.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_win5.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_bigwin.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_fly.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_playover.mp3",loadtype=1},
	{url="game/firecracker/sound/firecrack_click.mp3",loadtype=1},
	{url="game/firecracker/sound/firecracker_addScore.mp3",loadtype=1}
}
--动作资源管理器
resource.animations={
	{name="action_fk_7",begnum=1,endnum=19,photoname="firecracker_07_",Format=".png",delay=0.08},
	{name="action_fk_8",begnum=1,endnum=19,photoname="firecracker_08_",Format=".png",delay=0.08},
	{name="action_fk_9",begnum=1,endnum=20,photoname="firecracker_09_",Format=".png",delay=0.08},
	{name="action_fk_10",begnum=1,endnum=20,photoname="firecracker_10_",Format=".png",delay=0.08},
	{name="action_fk_11",begnum=1,endnum=19,photoname="firecracker_11_",Format=".png",delay=0.08},
	{name="action_fk_12",begnum=1,endnum=24,photoname="firecracker_12_",Format=".png",delay=0.1},
	{name="action_fk_13",begnum=1,endnum=8,photoname="firecracker_13_",Format=".png",delay=0.08},
	{name="action_fk_13p",begnum=1,endnum=100,photoname="firecracker_13prize_",Format=".png",delay=0.05},
	{name="action_fk_13tp",begnum=1,endnum=92,photoname="firecracker_13tp_",Format=".png",delay=0.05},
	{name="frame_st",begnum=1,endnum=24,photoname="public_frame_",Format=".png",delay=0.1},
	{name="action_fk_fireworks",begnum=1,endnum=25,photoname="firecracker_firework_",Format=".png",delay=0.08}
}

return resource