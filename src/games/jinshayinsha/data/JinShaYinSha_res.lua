local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{url="game/jinshayinsha/jsys_ui.plist",imgurl = "game/jinshayinsha/jsys_ui.png",size = 1838*389},
	{url="game/jinshayinsha/jsys_action.plist",imgurl = "game/jinshayinsha/jsys_action.png",size = 990*1382},
	{url="game/jinshayinsha/cm_ui.plist",imgurl = "game/jinshayinsha/cm_ui.png",size = 512*512},

	{imgurl = "game/jinshayinsha/jsys_main_bg.jpg",size = 1360*765},
	{imgurl = "game/jinshayinsha/jsys_number_1.png",size = 299*30},
	{imgurl = "game/jinshayinsha/jsys_number_2.png",size = 110*20},
	{imgurl = "game/jinshayinsha/jsys_number_3.png",size = 180*26},
	{imgurl = "game/jinshayinsha/jsys_number_4.png",size = 180*21},
	{imgurl = "game/jinshayinsha/jsys_number_5.png",size = 142*21},
	{imgurl = "game/jinshayinsha/jsys_number_6.png",size = 420*56},
	{imgurl = "game/jinshayinsha/jsys_number_7.png",size = 110*20},

}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	{url="game/jinshayinsha/sound/jsys_music_game_1.mp3",loadtype=0},
	{url="game/jinshayinsha/sound/jsys_music_game_2.mp3",loadtype=0},
	{url="game/jinshayinsha/sound/jsys_chouma.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_jiqiang.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_1.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_2.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_3.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_4.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_5.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_6.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_7.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_8.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_9.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_element_10.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_time_over.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_time_qiaozhong.mp3",loadtype=1},
	{url="game/jinshayinsha/sound/jsys_trun.mp3",loadtype=1}
}
--动作资源管理器
resource.animations={
	{name="jsys_prizes",begnum=1,endnum=5,photoname="jsys_prizes_",Format=".png",delay=0.2},
	{name="jsys_pigeon",begnum=1,endnum=5,photoname="jsys_pigeon_",Format=".png",delay=0.2},
	{name="jsys_moneky",begnum=1,endnum=5,photoname="jsys_moneky_",Format=".png",delay=0.2},
	{name="jsys_goldshark",begnum=1,endnum=5,photoname="jsys_goldshark_",Format=".png",delay=0.2},
	{name="jsys_peacock",begnum=1,endnum=5,photoname="jsys_peacock_",Format=".png",delay=0.2},
	{name="jsys_eagle",begnum=1,endnum=5,photoname="jsys_eagle_",Format=".png",delay=0.2},
	{name="jsys_lion",begnum=1,endnum=5,photoname="jsys_lion_",Format=".png",delay=0.2},
	{name="jsys_rabbit",begnum=1,endnum=5,photoname="jsys_rabbit_",Format=".png",delay=0.2},
	{name="jsys_panda",begnum=1,endnum=5,photoname="jsys_panda_",Format=".png",delay=0.2},
	{name="jsys_swallow",begnum=1,endnum=5,photoname="jsys_swallow_",Format=".png",delay=0.2},
	{name="jsys_slivershark",begnum=1,endnum=5,photoname="jsys_slivershark_",Format=".png",delay=0.2},
	{name="jsys_rect_green",begnum=1,endnum=2,photoname="jsys_rect_green_",Format=".png",delay=0.2},
	{name="jsys_rect_red",begnum=1,endnum=2,photoname="jsys_rect_red_",Format=".png",delay=0.2},
	{name="jsys_rect_yellow",begnum=1,endnum=2,photoname="jsys_rect_yellow_",Format=".png",delay=0.2}
}

return resource