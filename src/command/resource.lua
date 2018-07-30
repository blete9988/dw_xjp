local resource={}

--[[
*	plist管理器
*	可填参数 retain:是否额外引用(防止误回收),antialia:是否开启抗锯齿(土块拼接时不出现黑线),size:图片尺寸,url:plist路径,imgurl:图片路径
]]
resource.plists={
	{retain = true,url="res/images/public.plist",imgurl = "res/images/public.png",size = 2024*2024},
	{retain = true,url="res/images/popui.plist",imgurl = "res/images/popui.png",size = 629*345},
	{retain = true,url="res/images/hall_martbtn_anim.plist",imgurl = "res/images/hall_martbtn_anim.png",size = 1832*284},
	{url="res/images/login.plist",imgurl = "res/images/login.png",size = 629*345},
	{imgurl = "res/fonts/main_font_nmb_1.png",size = 220*26},
	{imgurl = "res/fonts/main_font_nmb_2.png",size = 463*42},
	{imgurl = "res/fonts/main_font_nmb_3.png",size = 210*31},
--	{retain = true,imgurl = "res/images/spine/hall_girl_tex.png",size = 670*1024},
--	{retain = true,imgurl = "res/images/spine/chess_tex.png",size = 670*1024},
--	{retain = true,imgurl = "res/images/spine/solot_tex.png",size = 670*1024},
--	{retain = true,imgurl = "res/images/spine/fishing_tex.png",size = 670*1024},
}

if D_SIZE.is9_16 then
else
end

--[声音特效 loadtype:0 音乐 1:音效]
resource.sounds={
	{url="res/sounds/main_sound_click.mp3"},
	{url="res/sounds/main_sound_hall_click.mp3"},
	{url="res/sounds/main_sound_bg.mp3"},
}
--动作资源管理器
resource.animations={
	{name="hall_martbtn_anim",begnum=1,endnum=22,photoname="hall_martbtn_anim_",Format=".png",delay=0.1},
}

--创建json node
function resource.createNodeByjsonName(name)
	local jsonUrl=resource.uijson[name]
	if jsonUrl then
		local json=display.extend("UIWidgetExtend",ccs.GUIReader:getInstance():widgetFromJsonFile(jsonUrl))
		return json
	end
end

function resource.loadAnimation(config)
	local animCache = cc.AnimationCache:getInstance()
	local tb,path
	for k,v in pairs(config) do
		tb = {}
		for i = v.begnum,v.endnum do
			path = string.format("%s%02d%s",v.photoname,i,v.Format)
			local sprite_frame = display.getFrameCache():getSpriteFrame(path)
			table.insert(tb,sprite_frame)
		end
		animCache:addAnimation(cc.Animation:createWithSpriteFrames(tb,v.delay),v.name)
	end
end

--[[
	根据动画key获取动画
	isForever 是否连续播放
]]	
function resource.getAnimateByKey(key,isForever,isOriginalFrame)
	if not key then return end
	local animation=cc.AnimationCache:getInstance():getAnimation(key)
	--如果key发生错误
	if not animation then
		print("getAnimateByKey is key Does not exist key:"..key)
		return nil
	end
	if not isOriginalFrame then
		animation:setRestoreOriginalFrame(false)
	else
		animation:setRestoreOriginalFrame(true)
	end
--	animation:setLoops(1)
	local ani=cc.Animate:create(animation)
	if isForever then
		return cc.RepeatForever:create(ani)
	else
		return ani
	end
end

--获取动画播放时间
function resource.getAnimationDuration(key)
	if not key then return end
	local animCache = CCAnimationCache:sharedAnimationCache()
	local animation=animCache:animationByName(key)
	--如果key发生错误
	if not animation then
		mlog("getAnimationDuration is key Does not exist key:"..key)
		return nil
	end
	return animation:getDuration()
end

Gbv.resource = resource

return resource