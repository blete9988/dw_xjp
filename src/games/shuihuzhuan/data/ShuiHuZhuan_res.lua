local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{url="game/shuihuzhuan/shz_action_boss_1.plist",imgurl = "game/shuihuzhuan/shz_action_boss_1.png",size = 1999*1388},
	{url="game/shuihuzhuan/shz_action_boss_2.plist",imgurl = "game/shuihuzhuan/shz_action_boss_2.png",size = 1888*914},
	{url="game/shuihuzhuan/shz_action_dadao.plist",imgurl = "game/shuihuzhuan/shz_action_dadao.png",size = 969*1325},
	{url="game/shuihuzhuan/shz_action_dagu.plist",imgurl = "game/shuihuzhuan/shz_action_dagu.png",size = 953*196},
	{url="game/shuihuzhuan/shz_action_futou.plist",imgurl = "game/shuihuzhuan/shz_action_futou.png",size = 1005*1599},
	{url="game/shuihuzhuan/shz_action_linchong.plist",imgurl = "game/shuihuzhuan/shz_action_linchong.png",size = 1010*1313},
	{url="game/shuihuzhuan/shz_action_long.plist",imgurl = "game/shuihuzhuan/shz_action_long.png",size = 1958*1013},
	{url="game/shuihuzhuan/shz_action_luzhisheng.plist",imgurl = "game/shuihuzhuan/shz_action_luzhisheng.png",size = 953*1599},
	{url="game/shuihuzhuan/shz_action_qizhi.plist",imgurl = "game/shuihuzhuan/shz_action_qizhi.png",size = 1958*869},
	{url="game/shuihuzhuan/shz_action_shuangqiang.plist",imgurl = "game/shuihuzhuan/shz_action_shuangqiang.png",size = 1005*1584},
	{url="game/shuihuzhuan/shz_action_songjiang.plist",imgurl = "game/shuihuzhuan/shz_action_songjiang.png",size = 1958*725},
	{url="game/shuihuzhuan/shz_action_yaoqi.plist",imgurl = "game/shuihuzhuan/shz_action_yaoqi.png",size = 1969*186},
	{url="game/shuihuzhuan/shz_action_zhongyitang.plist",imgurl = "game/shuihuzhuan/shz_action_zhongyitang.png",size = 1958*725},
	{url="game/shuihuzhuan/shz_ui.plist",imgurl = "game/shuihuzhuan/shz_ui.png",size = 916*2034},
	{url="game/shuihuzhuan/shz_full_font.plist",imgurl = "game/shuihuzhuan/shz_full_font.png",size = 1838*624},
	{imgurl = "game/shuihuzhuan/shz_background.jpg",size = 1360*765},
	{imgurl = "game/shuihuzhuan/shz_background_frame.png",size = 1328*750},
	{imgurl = "game/shuihuzhuan/shz_background_frame_bg.jpg",size = 1101*504},
	{imgurl = "game/shuihuzhuan/shz_dice_bottom.png",size = 1328*134},
	{imgurl = "game/shuihuzhuan/shz_dice_bg.png",size = 1360*765},
	{imgurl = "game/shuihuzhuan/shz_number_1.png",size = 142*21}
}

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	{url="game/shuihuzhuan/sound/shz_allElement_win.mp3",loadtype=0},
	{url="game/shuihuzhuan/sound/shz_bg.mp3",loadtype=0},
	{url="game/shuihuzhuan/sound/shz_click.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_bg.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_lose.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point2.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point3.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point4.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point5.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point6.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point7.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point8.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point9.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point10.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point11.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_point12.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_rock.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_wait_1.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_wait_2.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_wait_3.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_wait_4.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_wait_5.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_dice_win.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_1.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_2.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_3.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_4.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_5.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_6.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_7.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_8.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_element_9.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_selected.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_turn_line_1.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_turn_line_2.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_turn_start.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_turn_win.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_turn_compare_bt.mp3",loadtype=1},
	{url="game/shuihuzhuan/sound/shz_bg2.mp3",loadtype=0}
}
--动作资源管理器
resource.animations={
	{name="shz_action_yaoqi_1",begnum=1,endnum=22,photoname="shz_action_yaoqi_",Format=".png",delay=0.1},
	{name="shz_action_dagu",begnum=1,endnum=14,photoname="shz_action_dagu_",Format=".png",delay=0.2},
	{name="shz_action_elment1",begnum=1,endnum=52,photoname="shz_action_futou_",Format=".png",delay=0.06},
	{name="shz_action_elment2",begnum=1,endnum=54,photoname="shz_action_shuangqiang_",Format=".png",delay=0.06},
	{name="shz_action_elment3",begnum=1,endnum=41,photoname="shz_action_dadao_",Format=".png",delay=0.06},
	{name="shz_action_elment4",begnum=1,endnum=51,photoname="shz_action_luzhisheng_",Format=".png",delay=0.06},
	{name="shz_action_elment5",begnum=1,endnum=45,photoname="shz_action_linchong_",Format=".png",delay=0.06},
	{name="shz_action_elment6",begnum=1,endnum=47,photoname="shz_action_songjiang_",Format=".png",delay=0.06},
	{name="shz_action_elment7",begnum=1,endnum=57,photoname="shz_action_qizhi_",Format=".png",delay=0.06},
	{name="shz_action_elment8",begnum=1,endnum=46,photoname="shz_action_zhongyitang_",Format=".png",delay=0.06},
	{name="shz_action_elment9",begnum=1,endnum=67,photoname="shz_action_long_",Format=".png",delay=0.06},
	{name="shz_action_boss_wait",begnum=1,endnum=8,photoname="shz_action_boss_wait_",Format=".png",delay=0.1},
	{name="shz_action_boss_win",begnum=1,endnum=7,photoname="shz_action_boss_win_",Format=".png",delay=0.2},
	{name="shz_action_boss_lose_1",begnum=1,endnum=11,photoname="shz_action_boss_lose_",Format=".png",delay=0.2},
	{name="shz_action_boss_lose_2",begnum=12,endnum=14,photoname="shz_action_boss_lose_",Format=".png",delay=0.2},
	{name="shz_action_boss_dice_1",begnum=1,endnum=15,photoname="shz_action_boss_dice_",Format=".png",delay=0.2},
	{name="shz_action_boss_dice_2",begnum=16,endnum=18,photoname="shz_action_boss_dice_",Format=".png",delay=0.2},
	{name="shz_action_boss_dice_3",begnum=19,endnum=22,photoname="shz_action_boss_dice_",Format=".png",delay=0.2},
}

return resource