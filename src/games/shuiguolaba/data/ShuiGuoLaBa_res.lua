local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{url="game/shuiguolaba/sglb_ui.plist",imgurl = "game/shuiguolaba/sglb_ui.png",size = 1536*505},
	{url="game/shuiguolaba/sglb_action_1.plist",imgurl = "game/shuiguolaba/sglb_action_1.png",size = 1935*976},
	{url="game/shuiguolaba/sglb_action_2.plist",imgurl = "game/shuiguolaba/sglb_action_2.png",size = 1908*1837},
	{url="game/shuiguolaba/bibei.plist",imgurl = "game/shuiguolaba/bibei.png",size = 295*64},
	{url="game/shuiguolaba/sglb_ui2.plist",imgurl = "game/shuiguolaba/sglb_ui2.png",size = 512*1024},
	{imgurl = "game/shuiguolaba/sglb_bg.png",size = 1360*765},
	{imgurl = "game/shuiguolaba/sglb_rule_bg.png",size = 962*644},
	{imgurl = "game/shuiguolaba/sglb_rule_content.png",size = 790*1256},
	{imgurl = "game/shuiguolaba/sglb_number_1.png",size = 210*31},
	{imgurl = "game/shuiguolaba/sglb_number_2.png",size = 180*27},
	{imgurl = "game/shuiguolaba/sglb_number_3.png",size = 140*21},
	{imgurl = "game/shuiguolaba/sglb_number_4.png",size = 484*71},
	{imgurl = "game/shuiguolaba/sglb_number_5.png",size = 180*32},
	{imgurl = "game/shuiguolaba/sglb_number_6.png",size = 142*21}
}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	{url="game/shuiguolaba/sound/sglb_bg.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_bet.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_dmg.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_dsx.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_dsy.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_khc.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_more_bet.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_dx_lose.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_dx_win.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_turn.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_xmg.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_xsy.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_element_1.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_element_2.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_element_3.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_element_4.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_element_5.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_element_6.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_element_7.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_element_8.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_lucky.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/sglb_pa.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/Game05_area_1.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/Game05_area_2.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/Game05_area_3.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/Game05_area_4.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/Game05_area_5.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/Game05_area_6.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/Game05_area_7.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/Game05_area_8.mp3",loadtype=0},
	{url="game/shuiguolaba/sound/bibei.mp3",loadtype=0}
	
}
--动作资源管理器
resource.animations={
	{name="sglb_action_bet",begnum=1,endnum=12,photoname="sglb_action_bet_",Format=".png",delay=0.1},
	{name="sglb_action_element",begnum=1,endnum=3,photoname="sglb_action_element_",Format=".png",delay=0.2},
	{name="sglb_action_bx",begnum=1,endnum=12,photoname="sglb_action_bx_",Format=".png",delay=0.05},
	{name="sglb_action_dsx",begnum=1,endnum=12,photoname="sglb_action_dsx_",Format=".png",delay=0.05},
	{name="sglb_action_dsy",begnum=1,endnum=12,photoname="sglb_action_dsy_",Format=".png",delay=0.05},
	{name="sglb_action_khc",begnum=1,endnum=12,photoname="sglb_action_khc_",Format=".png",delay=0.05},
	{name="sglb_action_sjjl",begnum=1,endnum=12,photoname="sglb_action_sjjl_",Format=".png",delay=0.05},
	{name="sglb_action_xsy",begnum=1,endnum=12,photoname="sglb_action_xsy_",Format=".png",delay=0.05}
}

return resource