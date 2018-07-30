local zipdownload = {}
--[[
*	下载
*	@param:url				下载地址
*	@param:successCallback 	下载结束回调
*	@param:progressCallback	下载进度回调
*	@param:errorCallback 	下载出错回调
]]
function zipdownload.download(url,successCallback,progressCallback,errorCallback)
	--获取下载文件夹路径
	local downdir = cc.FileUtils:getInstance():getWritablePath()
	
	local assetsManager = cc.AssetsManager:new(url,"placeholder",downdir)
    assetsManager:retain()
    assetsManager:setConnectionTimeout(3)
    
    --注册错误回调
    assetsManager:setDelegate(function(errorCode) 
    	assetsManager:release()
		--errorCode(0:创建本地文件路径失败，1:资源下载失败，3:包解压失败，包出错)
		mlog(DEBUG_E,string.format("<zipdownload>:download failed error = %s",errorCode))
		if errorCallback then errorCallback(errorCode) end
    end, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    
    --注册下载进度回调
    assetsManager:setDelegate(function(percent) 
    	if percent < 0 then percent = 0 end
		if percent > 100 then percent = 100 end
		if progressCallback then progressCallback(percent) end
    end, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    
    --注册下载完成回调
    assetsManager:setDelegate(function() 
    	--释放下载器
    	assetsManager:release()
    	
    	if successCallback then successCallback() end
    	
    end, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    
    assetsManager:checkUpdate()
end
return zipdownload