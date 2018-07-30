--[[
*	重启过度界面
*	该界面为游戏重启做准备，需要在线更新时 可调用该界面
*	##
*		会清除游戏内部缓存（texturecache，framecache，lua已加载文件，路径缓存，动画缓存）
]]
local RelanuchScene = class("RelanuchScene",require("src.base.extend.CCSceneExtend"))

function RelanuchScene:ctor()
	self:super("ctor")
	--关闭通讯
	if Gbv.ConnectMgr then
		ConnectMgr.noticehandler(ST.TYPE_SOCKET_CLOSE_ALL)
	end
	--清理消息中心
	CommandCenter:clear()
	--清除文本缓存池
	require("src.base.control.label.LabelPools").stop()
	--停止所有帧监听
	timeclean()
	
	local handleID
	handleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handleID)
        --清除动画缓存
        cc.AnimationCache:destroyInstance()
        cc.SpriteFrameCache:getInstance():removeSpriteFrames()
        if Gbv.resource then
	        local plists = resource.plists
	        for i = 1,#plists do
	        	local texture = cc.Director:getInstance():getTextureCache():getTextureForKey(plists[i].imgurl)
	        	if plists[i].retain and texture then
	        		texture:release()
	        	end
	        end
        end
        cc.Director:getInstance():getTextureCache():removeAllTextures()
        --清除已缓存的全路径
        cc.FileUtils:getInstance():purgeCachedEntries()
        
        --清除音效
        SoundsManager.unloadAllFiles()
        
		mlog(cc.Director:getInstance():getTextureCache():getCachedTextureInfo())
        --清理全局变量
        for k,v in pairs(Gbv) do
        	Gbv[k] = nil
        end
        --移除lua逻辑文件
		for k,v in pairs(package.loaded) do
			local head = string.sub(k,1,4)
			if head == "src." then
				package.loaded[k] = nil
			end
		end
		require("src.main")
    end, 1, false)
    
    self:addChild(Coord.scgap(display.newText("游戏将在1S后重启！！！！！！",48),"CC",0,"CC",0))
end

return RelanuchScene