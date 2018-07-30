local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{url="game/baodaren/gwj_ui.plist",imgurl = "game/baodaren/gwj_ui.png",size = 1671*242},
	{url="game/baodaren/baodaren_gui.plist",imgurl = "game/baodaren/baodaren_gui.png",size = 1472*464},
	{url="game/baodaren/bdr_action_1.plist",imgurl = "game/baodaren/bdr_action_1.png",size = 970*1260},
	{url="game/baodaren/bdr_action_2.plist",imgurl = "game/baodaren/bdr_action_2.png",size = 2042*674},
	{url="game/baodaren/bdr_action_3.plist",imgurl = "game/baodaren/bdr_action_3.png",size = 920*1420},
	{url="game/baodaren/bdr_action_4.plist",imgurl = "game/baodaren/bdr_action_4.png",size = 504*1710},
	{url="game/baodaren/bdr_action_5.plist",imgurl = "game/baodaren/bdr_action_5.png",size = 914*1966},
	{url="game/baodaren/bdr_rect.plist",imgurl = "game/baodaren/bdr_rect.png",size = 1988*694},
	{url="game/baodaren/bdr_action_6.plist",imgurl = "game/baodaren/bdr_action_6.png",size = 504*466},
	{imgurl = "game/baodaren/bdr_content.png",size = 966*580},
	{imgurl = "game/baodaren/bdr_free_content.png",size = 966*580},
	{imgurl = "game/baodaren/bdr_free_bg.jpg",size = 1360*765},
	{imgurl = "game/baodaren/bdr_normal_bg.jpg",size = 1360*765},
	{imgurl = "game/baodaren/bdr_Free_Desc_WonCredits_bg.png",size = 956*579},
	{imgurl = "game/baodaren/bdr_Free_Desc_WonCredits_cn.png",size = 956*579},
	{imgurl = "game/baodaren/bdr_Free_Desc_WonCredits_effect1.png",size = 956*579},
	{imgurl = "game/baodaren/bdr_Free_Desc_WonCredits_effect2.png",size = 956*579},
	{imgurl = "game/baodaren/bdr_free_TS_1.png",size = 966*580},
	{imgurl = "game/baodaren/bdr_free_TS_2.png",size = 966*580},
	{imgurl = "game/baodaren/bdr_free_TSBG.png",size = 966*580},
	{imgurl = "game/baodaren/bdr_rule_1.png",size = 1111*1997},
	{imgurl = "game/baodaren/bdr_rule_2.png",size = 1111*988},
	{imgurl = "game/baodaren/bdr_rule_3.png",size = 1110*1872},
	{imgurl = "game/baodaren/bdr_number_1.png",size = 220*29},
	{imgurl = "game/baodaren/bdr_number_2.png",size = 270*37},
	{imgurl = "game/baodaren/bdr_number_3.png",size = 270*37},
	{imgurl = "game/baodaren/bdr_number_4.png",size = 420*60},
	{imgurl = "game/baodaren/bdr_number_5.png",size = 740*100},
	{imgurl = "game/baodaren/bdr_number_6.png",size = 1330*162},
	{imgurl = "game/baodaren/bdr_rule_bg.png",size = 1168*693},
	{imgurl = "game/baodaren/bdr_1.png",size = 182*560},
}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	{url="game/baodaren/sound/bdr_bonus.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_chile.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_freeBg.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_goldBlow.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_maybeBlow.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_scoringEnd.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_sfbj.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_1.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_2.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_3.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_4.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_5.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_6.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_7.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_8.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_9.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turn_10.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_free.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_qiaoluo.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_Scoring01.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_Scoring02.mp3",loadtype=0},
	{url="game/baodaren/sound/bdr_turnOver.mp3",loadtype=0}
}
--动作资源管理器
resource.animations={
	{name="bdr_action_dagu",begnum=1,endnum=28,photoname="bdr_action_1_",Format=".png",delay=0.05},
	{name="bdr_action_px",begnum=1,endnum=42,photoname="bdr_action_2_",Format=".png",delay=0.05},
	{name="bdr_action_sfbj",begnum=1,endnum=50,photoname="bdr_action_3_",Format=".png",delay=0.05},
	{name="bdr_action_cj",begnum=1,endnum=38,photoname="bdr_action_4_",Format=".png",delay=0.1},
	{name="bdr_action_dxch",begnum=1,endnum=37,photoname="bdr_action_5_",Format=".png",delay=0.05},
	{name="bdr_action_yuanbao",begnum=1,endnum=31,photoname="bdr_action_6_",Format=".png",delay=0.1}
}

return resource