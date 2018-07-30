--[[
*	资源释放方法
*	@param resource 资源配置
]]
local function ReleaseResTool(resource)
	--移除动画
	for k,v in pairs(resource.animations) do
		display.removeAnimationCache(v.name)
	end
	--移除texturecache
	for k,v in pairs(resource.plists) do
		if v.url then
			display.removeSpriteFrames(v.url, v.imgurl)
			display.removeSpriteFrames(v.url, v.imgurl)
		else
			display.removeTexture(v.imgurl)
			display.removeTexture(v.imgurl)
		end
	end
	
	SoundsManager.bathUnloadFiles(resource.gamekey)
	if Cfg.DEBUG_TAG then
		mlog(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
	end
end
return ReleaseResTool