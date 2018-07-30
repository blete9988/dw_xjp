local resource={}
resource.plists={
	{imgurl = "game/hongheidazhan/hhdz_desktop_background.jpg",size = 1136*640},
	{imgurl = "game/hongheidazhan/hhdz_trendbg.jpg",size = 869*603},
	{url="game/hongheidazhan/hhdz_public.plist",imgurl = "game/hongheidazhan/hhdz_public.png",size = 1995*261},
	{url="game/hongheidazhan/hhdz_anim_pkboom.plist",imgurl = "game/hongheidazhan/hhdz_anim_pkboom.png",size = 504*1900},
	{url="game/hongheidazhan/hhdz_anim_shine.plist",imgurl = "game/hongheidazhan/hhdz_anim_shine.png",size = 770*210},
	{imgurl = "game/hongheidazhan/hhdz_number_1.png",size = 142*21},
	{imgurl = "game/hongheidazhan/hhdz_number_2.png",size = 400*30},
	{imgurl = "game/hongheidazhan/hhdz_number_3.png",size = 264*34},
	{imgurl = "game/hongheidazhan/hhdz_number_4.png",size = 312*34},
	{imgurl = "game/hongheidazhan/particle/star01.png",size = 128*128},
}

resource.sounds={
	{url="game/hongheidazhan/sounds/hhdz_bgm.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_add_bet.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_add_bet_bath.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_cd.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_getGold.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_grouptype_4.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_grouptype_5.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_grouptype_6.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_grouptype_7.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_grouptype_8.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_grouptype_9.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_over.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_sendpoker.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_show.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_start.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_start_alert.mp3"},
	{url="game/hongheidazhan/sounds/hhdz_turnPoker.mp3"},
}
resource.animations={
	{name="pk_boom",begnum=1,endnum=23,photoname="hhdz_pk_boom_",Format=".png",delay=0.05},
	{name="start_shine",begnum=1,endnum=10,photoname="start_shine_",Format=".png",delay=0.1},
}

return resource