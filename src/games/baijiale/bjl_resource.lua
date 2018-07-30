local resource={}
resource.plists={
	{imgurl = "game/baijiale/bjl_desktop_background.jpg",size = 1360*765},
	{imgurl = "game/baijiale/bjl_desktop_background_1.png",size = 1112*693},
	{imgurl = "game/baijiale/bjl_number_1.png",size = 230*33},
	{imgurl = "game/baijiale/bjl_number_2.png",size = 142*21},
	{imgurl = "game/baijiale/bjl_number_3.png",size = 420*46},
	{imgurl = "game/baijiale/bjl_number_4.png",size = 455*46},
	{url="game/baijiale/bjl_poker.plist",imgurl = "game/baijiale/bjl_poker.png",size = 2006*1008},
	{url="game/baijiale/bjl_public.plist",imgurl = "game/baijiale/bjl_public.png",size = 1003*1800},
}

resource.sounds={
	{url="game/baijiale/sounds/bjl_countdown.mp3"},
	{url="game/baijiale/sounds/bjl_countdown_ring.mp3"},
	{url="game/baijiale/sounds/bjl_send_card.mp3"},
	{url="game/baijiale/sounds/bjl_send_card_over.mp3"},
	{url="game/baijiale/sounds/bjl_fanpai.mp3"},
	{url="game/baijiale/sounds/bjl_add_bet.mp3"},
	{url="game/baijiale/sounds/bjl_bet_end.mp3"},
	{url="game/baijiale/sounds/bjl_bet_start.mp3"},
	{url="game/baijiale/sounds/bjl_get_gold.mp3"},
	{url="game/baijiale/sounds/bjl_win.mp3"},
	{url="game/baijiale/sounds/bjl_start.mp3"},
	{url="game/baijiale/sounds/bjl_dong.mp3"},
	{url="game/baijiale/sounds/bjl_cheer_0.mp3"},
	{url="game/baijiale/sounds/bjl_cheer_1.mp3"},
	{url="game/baijiale/sounds/bjl_cheer_2.mp3"},
}
resource.animations={
	{name="bjl_clock_ring_5",begnum=1,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="bjl_clock_ring_4",begnum=9,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="bjl_clock_ring_3",begnum=17,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="bjl_clock_ring_2",begnum=25,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="bjl_clock_ring_1",begnum=33,endnum=40,photoname="clock_ring_",Format=".png",delay=1/8},
	{name="bjl_fanpai",begnum=1,endnum=7,photoname="bjl_fanpai_",Format=".png",delay=0.06},
	{name="bjl_fanpai_over",begnum=8,endnum=9,photoname="bjl_fanpai_",Format=".png",delay=0.04},
}

return resource