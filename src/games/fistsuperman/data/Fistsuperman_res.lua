local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{url="game/fistsuperman/gwj_ui.plist",imgurl = "game/fistsuperman/gwj_ui.png",size = 1671*242},
	{url="game/fistsuperman/FP_public.plist",imgurl = "game/fistsuperman/FP_public.png",size = 496*715},
	{url="game/fistsuperman/fsp_10.plist",imgurl = "game/fistsuperman/fsp_10.png",size = 920*1988},
	{url="game/fistsuperman/fsp_11.plist",imgurl = "game/fistsuperman/fsp_11.png",size = 878*1846},
	{url="game/fistsuperman/fsp_12.plist",imgurl = "game/fistsuperman/fsp_12.png",size = 920*1988},
	{url="game/fistsuperman/FS_Rect.plist",imgurl = "game/fistsuperman/FS_Rect.png",size = 920*1420},
	{url="game/fistsuperman/fsp_bigwin.plist",imgurl = "game/fistsuperman/fsp_bigwin.png",size = 1384*246},
	{imgurl = "game/fistsuperman/fistsuperman_1.png",size = 182*560},
	{imgurl = "game/fistsuperman/fs_free_content.png",size = 966*580},
	{imgurl = "game/fistsuperman/fs_free_bg.jpg",size = 1360*765},
	{imgurl = "game/fistsuperman/fs_content.png",size = 966*580},
	{imgurl = "game/fistsuperman/fs_normal_bg.jpg",size = 1360*765},
	{imgurl = "game/fistsuperman/fontnumber_22X29_1.png",size = 220*29},
	{imgurl = "game/fistsuperman/fontnumber_27X37.png",size = 270*37},
	{imgurl = "game/fistsuperman/fontnumber_27X37_yellow.png",size = 270*37},
	{imgurl = "game/fistsuperman/fontnumber_42X60.png",size = 420*60},
	{imgurl = "game/fistsuperman/fontnumber_74X100_1.png",size = 740*100},
	{imgurl = "game/fistsuperman/fontnumber_133X162_1.png",size = 1330*162}	
}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	{url="game/fistsuperman/sound/FS_addScoring.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_blow.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_fly.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_freeBg.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_freeOver.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_maybeBlow.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_scoringEnd.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_turn.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_turnOver.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_buttonClick.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_bonus.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_goldBlow.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_Freeblow.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_Addx.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_Click.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_FreeSpinsResult.mp3",loadtype=1},
	{url="game/fistsuperman/sound/FS_BonusSingle.mp3",loadtype=1},
	{url="game/fistsuperman/sound/yqcr_bg.mp3",loadtype=0}

}
--动作资源管理器
resource.animations={
	{name="action_FS_bigwin",begnum=1,endnum=31,photoname="fsp_bigwin_",Format=".png",delay=0.1},
	{name="action_FS_10",begnum=1,endnum=67,photoname="fsp_10_",Format=".png",delay=0.03},
	{name="action_FS_11_1",begnum=1,endnum=41,photoname="fsp_11_",Format=".png",delay=0.03},
	{name="action_FS_11_2",begnum=42,endnum=61,photoname="fsp_11_",Format=".png",delay=0.03},
	{name="action_FS_12",begnum=1,endnum=72,photoname="fsp_12_",Format=".png",delay=0.03}
}

return resource