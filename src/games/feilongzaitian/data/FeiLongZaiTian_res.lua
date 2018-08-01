local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{url="game/feilongzaitian/gwj_ui.plist",imgurl = "game/feilongzaitian/gwj_ui.png",size = 1671*242},
	{url="game/feilongzaitian/flzt_action_1.plist",imgurl = "game/feilongzaitian/flzt_action_1.png",size = 510*1988},
	{url="game/feilongzaitian/flzt_action_2.plist",imgurl = "game/feilongzaitian/flzt_action_2.png",size = 920*1278},
	{url="game/feilongzaitian/flzt_action_3.plist",imgurl = "game/feilongzaitian/flzt_action_3.png",size = 920*1136},
	{url="game/feilongzaitian/flzt_gui.plist",imgurl = "game/feilongzaitian/flzt_gui.png",size = 504*777},
	{url="game/feilongzaitian/flzt_rect.plist",imgurl = "game/feilongzaitian/flzt_rect.png",size = 1988*694},
	{url="game/feilongzaitian/flzt_action_4.plist",imgurl = "game/feilongzaitian/flzt_action_4.png",size = 504*466},
	{imgurl = "game/feilongzaitian/flzt_content.png",size = 966*580},
	{imgurl = "game/feilongzaitian/flzt_free_content.png",size = 966*580},
	{imgurl = "game/feilongzaitian/flzt_free_bg.jpg",size = 1360*765},
	{imgurl = "game/feilongzaitian/flzt_normal_bg.jpg",size = 1360*765},
	{imgurl = "game/feilongzaitian/flzt_Free_Desc_WonCredits_bg.png",size = 956*579},
	{imgurl = "game/feilongzaitian/flzt_Free_Desc_WonCredits_cn.png",size = 956*579},
	{imgurl = "game/feilongzaitian/flzt_Free_Desc_WonCredits_effect1.png",size = 956*579},
	{imgurl = "game/feilongzaitian/flzt_Free_Desc_WonCredits_effect2.png",size = 956*579},
	{imgurl = "game/feilongzaitian/flzt_Performe_cn.png",size = 955*552},
	{imgurl = "game/feilongzaitian/flzt_free_TSBG.png",size = 1111*1997},
	{imgurl = "game/feilongzaitian/flzt_number_1.png",size = 220*29},
	{imgurl = "game/feilongzaitian/flzt_number_2.png",size = 270*37},
	{imgurl = "game/feilongzaitian/flzt_number_3.png",size = 270*37},
	{imgurl = "game/feilongzaitian/flzt_number_4.png",size = 420*60},
	{imgurl = "game/feilongzaitian/flzt_number_5.png",size = 740*100},
	{imgurl = "game/feilongzaitian/flzt_number_6.png",size = 1330*162},
	{imgurl = "game/feilongzaitian/flzt_rule_bg.png",size = 1168*693},
	{imgurl = "game/feilongzaitian/flzt_1.png",size = 182*560},
	{imgurl = "game/feilongzaitian/flzt_rule_1.png",size = 1111*1970},
	{imgurl = "game/feilongzaitian/flzt_rule_2.png",size = 1111*1880}
}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	{url="game/feilongzaitian/sound/flzt_scoring_01.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_scoring_02.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_bonus.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_buttonClick.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_freeBg.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_goldBlow.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_freeOver.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_long.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_maybeBlow.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_scoringEnd.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_turnOver.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_free.mp3",loadtype=0},
	{url="game/feilongzaitian/sound/flzt_bg.mp3",loadtype=0}
}
--动作资源管理器
resource.animations={
	{name="flzt_action_tongqian",begnum=1,endnum=38,photoname="flzt_action_1_",Format=".png",delay=0.03},
	{name="flzt_action_long",begnum=1,endnum=45,photoname="flzt_action_2_",Format=".png",delay=0.03},
	{name="flzt_action_longzhu",begnum=1,endnum=40,photoname="flzt_action_3_",Format=".png",delay=0.03},
	{name="flzt_action_yuanbao",begnum=1,endnum=31,photoname="flzt_action_4_",Format=".png",delay=0.1}
}

return resource