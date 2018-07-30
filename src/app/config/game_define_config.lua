--游戏定义
local _config = {
	[101] = 
		{
			sid = 101,
			name = "百家乐",
			key = "baijiale",
			group = 1,
			order = 0,
			background = "p_ui_bg_blue.png",
			namepanel = "p_ui_namebg_blue.png",
			namepic = "p_ui_1103.png",
			icon = "p_ui_1203.png",
			path = "src.games.baijiale.ui.Bjl_Scene",
			resourcecfg = "src.games.baijiale.bjl_resource"
		},
	-- [102] = 
	-- 	{
	-- 		sid = 102,
	-- 		name = "百人牛牛",
	-- 		key = "bairenniuniu",
	-- 		group = 1,
	-- 		order = 0,
	-- 		background = "p_ui_bg_yellow.png",
	-- 		namepanel = "p_ui_namebg_purple.png",
	-- 		namepic = "p_ui_1107.png",
	-- 		icon = "p_ui_1207.png",
	-- 		path = "src.games.bairenniuniu.ui.Brnn_Scene",
	-- 		resourcecfg = "src.games.bairenniuniu.brnn_resource"
	-- 	},
	-- [103] = 
	-- 	{
	-- 		sid = 103,
	-- 		name = "斗地主",
	-- 		key = "doudizhu",
	-- 		group = 1,
	-- 		order = 0,
	-- 		background = "p_ui_bg_yellow.png",
	-- 		namepanel = "p_ui_namebg_purple.png",
	-- 		namepic = "p_ui_1101.png",
	-- 		icon = "p_ui_1201.png",
	-- 		path = "",
	-- 		resourcecfg = ""
	-- 	},
	-- [104] = 
	-- 	{
	-- 		sid = 104,
	-- 		name = "通比牛牛",
	-- 		key = "tongbiniuniu",
	-- 		group = 1,
	-- 		order = 0,
	-- 		background = "p_ui_bg_purple.png",
	-- 		namepanel = "p_ui_namebg_blue.png",
	-- 		namepic = "p_ui_1105.png",
	-- 		icon = "p_ui_1205.png",
	-- 		path = "src.games.tongbiniuniu.ui.Tbnn_Scene",
	-- 		resourcecfg = "src.games.tongbiniuniu.tbnn_resource"
	-- 	},
	-- [105] = 
	-- 	{
	-- 		sid = 105,
	-- 		name = "炸金花",
	-- 		key = "zhajinhua",
	-- 		group = 1,
	-- 		order = 0,
	-- 		background = "p_ui_bg_pink.png",
	-- 		namepanel = "p_ui_namebg_blue.png",
	-- 		namepic = "p_ui_1102.png",
	-- 		icon = "p_ui_1202.png",
	-- 		path = "",
	-- 		resourcecfg = ""
	-- 	},
	-- [106] = 
	-- 	{
	-- 		sid = 106,
	-- 		name = "梭哈",
	-- 		key = "suoha",
	-- 		group = 1,
	-- 		order = 0,
	-- 		background = "p_ui_bg_pink.png",
	-- 		namepanel = "p_ui_namebg_purple.png",
	-- 		namepic = "p_ui_1106.png",
	-- 		icon = "p_ui_1206.png",
	-- 		path = "",
	-- 		resourcecfg = ""
	-- 	},
	-- [107] = 
	-- 	{
	-- 		sid = 107,
	-- 		name = "德州扑克",
	-- 		key = "dezhoupuke",
	-- 		group = 1,
	-- 		order = 0,
	-- 		background = "p_ui_bg_yellow.png",
	-- 		namepanel = "p_ui_namebg_purple.png",
	-- 		namepic = "p_ui_1100.png",
	-- 		icon = "p_ui_1200.png",
	-- 		path = "",
	-- 		resourcecfg = ""
	-- 	},
	-- [108] = 
	-- 	{
	-- 		sid = 108,
	-- 		name = "红黑大战",
	-- 		key = "hongheidazhan",
	-- 		group = 1,
	-- 		order = 0,
	-- 		background = "p_ui_bg_yellow.png",
	-- 		namepanel = "p_ui_namebg_purple.png",
	-- 		namepic = "p_ui_1122.png",
	-- 		icon = "p_ui_1222.png",
	-- 		path = "src.games.hongheidazhan.ui.Hhdz_Scene",
	-- 		resourcecfg = "src.games.hongheidazhan.hhdz_resource"
	-- 	},
	[109] = 
		{
			sid = 109,
			name = "抢庄牛牛",
			key = "qiangzhuangniuniu",
			group = 1,
			order = 0,
			background = "p_ui_bg_pink.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1121.png",
			icon = "p_ui_1221.png",
			path = "src.games.qiangzhuangniuniu.ui.Qznn_Scene",
			resourcecfg = "src.games.qiangzhuangniuniu.qznn_resource"
		},
	[201] = 
		{
			sid = 201,
			name = "包大人",
			key = "baodaren",
			group = 2,
			order = 97,
			background = "p_ui_bg_pink.png",
			namepanel = "p_ui_namebg_blue.png",
			namepic = "p_ui_1108.png",
			icon = "p_ui_1208.png",
			path = "src.games.baodaren.BaoDaRenScene",
			resourcecfg = "src.games.baodaren.data.BaoDaRen_res"
		},
	[202] = 
		{
			sid = 202,
			name = "水浒传",
			key = "shuihuzhuan",
			group = 2,
			order = 96,
			background = "p_ui_bg_purple.png",
			namepanel = "p_ui_namebg_blue.png",
			namepic = "p_ui_1109.png",
			icon = "p_ui_1209.png",
			path = "src.games.shuihuzhuan.ShuiHuZhuanScene",
			resourcecfg = "src.games.shuihuzhuan.data.ShuiHuZhuan_res"
		},
	[203] = 
		{
			sid = 203,
			name = "飞禽走兽",
			key = "feiqingzoushou",
			group = 2,
			order = 95,
			background = "p_ui_bg_yellow.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1110.png",
			icon = "p_ui_1210.png",
			path = "src.games.feiqingzoushou.FeiQingZouShouScene",
			resourcecfg = "src.games.feiqingzoushou.data.Feiqingzoushou_res"
		},
	[204] = 
		{
			sid = 204,
			name = "豪车漂移",
			key = "haochepiaoyi",
			group = 2,
			order = 94,
			background = "p_ui_bg_purple.png",
			namepanel = "p_ui_namebg_blue.png",
			namepic = "p_ui_1111.png",
			icon = "p_ui_1211.png",
			path = "src.games.haochepiaoyi.HaoChePiaoYiScene",
			resourcecfg = "src.games.haochepiaoyi.data.HaoChePiaoYi_res"
		},
	[205] = 
		{
			sid = 205,
			name = "幸运鞭炮",
			key = "firecracker",
			group = 2,
			order = 99,
			background = "p_ui_bg_yellow.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1112.png",
			icon = "p_ui_1212.png",
			path = "src.games.firecracker.FirecrackerScene",
			resourcecfg = "src.games.firecracker.data.Firecracker_res"
		},
	[206] = 
		{
			sid = 206,
			name = "一拳超人",
			key = "fistsuperman",
			group = 2,
			order = 98,
			background = "p_ui_bg_blue.png",
			namepanel = "p_ui_namebg_blue.png",
			namepic = "p_ui_1113.png",
			icon = "p_ui_1213.png",
			path = "src.games.fistsuperman.FistSuperManScene",
			resourcecfg = "src.games.fistsuperman.data.Fistsuperman_res"
		},
	[207] = 
		{
			sid = 207,
			name = "飞龙在天",
			key = "feilongzaitian",
			group = 2,
			order = 100,
			background = "p_ui_bg_yellow.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1115.png",
			icon = "p_ui_1215.png",
			path = "src.games.feilongzaitian.FeiLongZaiTianScene",
			resourcecfg = "src.games.feilongzaitian.data.FeiLongZaiTian_res"
		},
	[208] = 
		{
			sid = 208,
			name = "水果拉闸",
			key = "shuiguolaba",
			group = 2,
			order = 92,
			background = "p_ui_bg_blue.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1116.png",
			icon = "p_ui_1216.png",
			path = "src.games.shuiguolaba.ShuiGuoLaBaScene",
			resourcecfg = "src.games.shuiguolaba.data.ShuiGuoLaBa_res"
		},
	[209] = 
		{
			sid = 209,
			name = "金鲨银鲨",
			key = "jinshayinsha",
			group = 2,
			order = 93,
			background = "p_ui_bg_blue.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1114.png",
			icon = "p_ui_1214.png",
			path = "src.games.jinshayinsha.JinShaYinShaScene",
			resourcecfg = "src.games.jinshayinsha.data.JinShaYinSha_res"
		},
	[301] = 
		{
			sid = 301,
			name = "疯狂捕鱼",
			key = "ppby",
			group = 3,
			order = 0,
			background = "p_ui_bg_blue.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1117.png",
			icon = "p_ui_1217.png",
			path = "src.games.catchFish.ppby.PPBYScene",
			resourcecfg = "src.games.catchFish.ppby.configs.ResConfigs"
		},
	[302] = 
		{
			sid = 302,
			name = "海盗船长",
			key = "hdby",
			group = 3,
			order = 0,
			background = "p_ui_bg_yellow.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1119.png",
			icon = "p_ui_1219.png",
			path = "src.games.catchFish.hdby.HDBYScene",
			resourcecfg = "src.games.catchFish.hdby.configs.ResConfigs"
		},
	[303] = 
		{
			sid = 303,
			name = "李逵劈鱼",
			key = "lkpy",
			group = 3,
			order = 0,
			background = "p_ui_bg_purple.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1120.png",
			icon = "p_ui_1220.png",
			path = "src.games.catchFish.lkpy.LKPYScene",
			resourcecfg = "src.games.catchFish.lkpy.configs.ResConfigs"
		},
	[304] = 
		{
			sid = 304,
			name = "金蟾捕鱼",
			key = "jcby",
			group = 3,
			order = 0,
			background = "p_ui_bg_pink.png",
			namepanel = "p_ui_namebg_purple.png",
			namepic = "p_ui_1118.png",
			icon = "p_ui_1218.png",
			path = "src.games.catchFish.jcby.JCBYScene",
			resourcecfg = "src.games.catchFish.jcby.configs.ResConfigs"
		}
}
return _config
