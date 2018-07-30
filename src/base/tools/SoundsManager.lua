--[[
*	声音管理 		
*	所有方法 functions
*	SoundsManager.preload(files,callback,key)    @add 预加载,逐帧加载，不卡主线程
*	SoundsManager.playSound(filename, isLoop, finishcakkback)		@add 播放音效
*	SoundsManager.playMusic(filename, isLoop, finishcakkback) 		@add 播放背景音乐
*	SoundsManager.pauseAudio(idOrname)			@override native 暂停播放 音频
*	SoundsManager.resumeAudio(idOrname)			@override native 继续播放 音频
*	SoundsManager.stopAudio(idOrname)			@override native 停止播放 音频
*	SoundsManager.pauseAllSounds()				@add 暂停播放所有 音效
*	SoundsManager.resumeAllSounds()				@add 继续播放所有 音效
*	SoundsManager.stopAllSounds()				@add 停止播放所有 音效
*	SoundsManager.pauseAllMusic()				@add 暂停播放所有 背景音乐
*	SoundsManager.resumeAllMusic()				@add 继续播放所有 背景音乐
*	SoundsManager.stopAllMusic()				@add 停止播放所有 背景音乐
*	SoundsManager.unloadFile(filename)			@override native 移除指定音频文件
*	SoundsManager.bathUnloadFiles(key)			@add 移除 key 对应 的已加载的音频文件
*	SoundsManager.unloadAllFiles()				@override native 移除所有已加载的音频文件
*	SoundsManager.stopAll()						@override native 停止所有音频
*	SoundsManager.resumeAll()					@override native 暂停所有音频
*	SoundsManager.pauseAll()					@override native 继续所有音频
*	SoundsManager.getVolume(idOrname)			@override native 获取音频的 音量
*	SoundsManager.setVolume(idOrname,volume)	@override native 设置音频的 音量
*	SoundsManager.getCurrentTime(idOrname)		@override native 获取音频 播放时间
*	SoundsManager.setCurrentTime(idOrname,sec)	@override native 设置音频 播放时间
*	SoundsManager.getDuration(idOrname)			@override native 获取音频 总时间
*	SoundsManager.setLoop(idOrname,isLoop)		@override native 设置音频 是否循环
*	SoundsManager.cancelBGM(bool)				@add 是否禁用 背景音乐
*	SoundsManager.cancelSE(bool)				@add 是否禁用 音效
*	SoundsManager.isCancelBGM()					@add 获取是否禁用 背景音乐
*	SoundsManager.isCancelSE()					@add 获取是否禁用 音效
]]


local SoundsManager = {}

--@native C++
local audioEngine = ccexp.AudioEngine

--当前 背景音乐
local currentBGM

--是否禁止背景/音效
local cancelBGM,cancelSE
local SplitName,GetStatus,GetAudioID		--function

--已加载音效缓存
local loadedfilles = {}
--正在播放的音乐
local onPlayingFiles = {}

--[[
*	预加载,逐帧加载，不卡主线程
*	@param files : 声音列表
*	@param callback ： 回掉函数
*	@param key
]]
function SoundsManager.preload(files,callback,key)
	local len = #files
	if len < 1 then return end
	
	local index = 1
	
	--片段加载
	local function beginloading()
		SoundsManager.preloadAudio(files[index].url,key)
		--每0.2s加载一个音乐文件
		timeout(function() 
			if callback then callback(files[index].url,index) end
			index = index + 1
			if index <= len then
				beginloading()
			end
		end,0.05)
	end
	
	beginloading()
end

--[[
*	播放音效
*	@param filename 		音频文件名 或者 音频文件全路径
*	@param isLoop			是否循环（默认false ）
*	@param finishcakkback	播放完成回掉(默认空)
]]
function SoundsManager.playSound(filename, isLoop--[[false]] , finishcakkback--[[=nil]])
	if cancelSE then return end
	
	if not loadedfilles[filename] then
		mlog( DEBUG_W, string.format("<SoundsManager>:未预加载文件名为 %s 的音效文件，请尽量预加载音效文件",filename))
		--保存已加载音频信息
		filename = SoundsManager.preloadAudio(filename)
	end
	
	return SoundsManager.play2D(filename, isLoop , true ,finishcakkback)
end

--[[
*	播放背景音乐
*	@param filename 		音频文件名 或者 音频文件全路径
*	@param isLoop			是否循环（默认false ）
*	@param finishcakkback	播放完成回掉(默认空)
]]
function SoundsManager.playMusic(filename, isLoop--[[false]] , finishcakkback--[[=nil]])
	if not loadedfilles[filename] then
		mlog( DEBUG_W, string.format("<SoundsManager>:未预加载文件名为 %s 的背景音乐文件，请尽量预加载音乐文件",filename))
		--未加载则加载
		filename = SoundsManager.preloadAudio(filename)
	end
	--停止前一个背景音乐
	if cancelBGM and currentBGM then 
		SoundsManager.stopAudio(currentBGM[1]) 
	end
	
	--记录当前背景音乐
	currentBGM = {
		filename,
		isLoop,
		finishcakkback
	}
	
	if cancelBGM then return end
	
	return SoundsManager.play2D(filename, isLoop , false ,finishcakkback)
end

--[[
*	暂停播放 音频
*	@param idOrname 播放id或者名字
]]
function SoundsManager.pauseAudio(idOrname)
	local id = GetAudioID(idOrname)
	if id then
		audioEngine:pause(id)
	end
end

--[[
*	继续播放 音频
*	@param idOrname 播放id或者名字
]]
function SoundsManager.resumeAudio(idOrname)
	if cancelSE then return end
	
	local id = GetAudioID(idOrname)
	if id then
		audioEngine:resume(id)
	end
end

--[[
*	停止播放 音频
*	@param idOrname 播放id或者名字
]]
function SoundsManager.stopAudio(idOrname)
	if type(idOrname) == "number" then
		audioEngine:stop(idOrname)
		for name,tab in pairs(onPlayingFiles) do
			if tab[idOrname] then
				tab[idOrname] = nil
				return
			end
		end
	else
		if onPlayingFiles[idOrname] then
			local id = next(onPlayingFiles[idOrname])
			if id then
				onPlayingFiles[idOrname][id] = nil
				audioEngine:stop(id)
			end
		end
	end
end

--暂停播放所有 音效
function SoundsManager.pauseAllSounds()
	for name,tab in pairs(onPlayingFiles) do
		for id,struct in pairs(tab) do
			if struct.issound then
				audioEngine:pause(id)
			end
		end
	end
end

--继续播放所有 音效
function SoundsManager.resumeAllSounds()
	if cancelSE then return end
	
	for name,tab in pairs(onPlayingFiles) do
		for id,struct in pairs(tab) do
			if struct.issound then
				audioEngine:resume(id)
			end
		end
	end
end

--停止播放所有 音效
function SoundsManager.stopAllSounds()
	for name,tab in pairs(onPlayingFiles) do
		for id,struct in pairs(tab) do
			if struct.issound then
				audioEngine:stop(id)
				tab[id] = nil
			end
		end
	end
end

--暂停播放所有 背景音乐
function SoundsManager.pauseAllMusic()
	for name,tab in pairs(onPlayingFiles) do
		for id,struct in pairs(tab) do
			if not struct.issound then
				audioEngine:pause(id)
			end
		end
	end
end

--继续播放所有 音效
function SoundsManager.resumeAllMusic()
	if cancelSE then return end
	
	for name,tab in pairs(onPlayingFiles) do
		for id,struct in pairs(tab) do
			if not struct.issound then
				audioEngine:resume(id)
			end
		end
	end
end

--停止播放所有音效
function SoundsManager.stopAllMusic()
	currentBGM = nil
	
	for name,tab in pairs(onPlayingFiles) do
		for id,struct in pairs(tab) do
			if not struct.issound then
				audioEngine:stop(id)
				tab[id] = nil
			end
		end
	end
end

--[[
*	移除指定音频文件
*	@param filename 文件名
]]
function SoundsManager.unloadFile(filename)
	if not loadedfilles[filename] then return end
	SoundsManager.stopAudio(filename)	
	audioEngine:uncache(loadedfilles[filename].url)
	loadedfilles[filename] = nil
	
	onPlayingFiles[filename] = nil
end

--移除 key 对应 的已加载的音频文件
function SoundsManager.bathUnloadFiles(key)
	for name,v in pairs(loadedfilles) do
		if v.key == key then
			SoundsManager.unloadFile(name)
			onPlayingFiles[name] = nil
		end
	end
end

--移除所有已加载的音频文件
function SoundsManager.unloadAllFiles()
	SoundsManager.stopAll()
	for k,v in pairs(loadedfilles) do
		SoundsManager.unloadFile(k)
	end
--	audioEngine:uncacheAll()
	loadedfilles = {}
	onPlayingFiles = {}
end

--@override native
function SoundsManager.stopAll()
	SoundsManager.stopAllSounds()
	SoundsManager.stopAllMusic()
	audioEngine:stopAll()
end

--@override native
function SoundsManager.resumeAll()
	audioEngine:resumeAll()
end

--@override native
function SoundsManager.pauseAll()
	audioEngine:pauseAll()
end

--@override native 获取音频的 音量
function SoundsManager.getVolume(idOrname)
	local id = GetAudioID(idOrname)
	if id then
		return audioEngine:getVolume(id)
	end
end

--@override native 设置音频的 音量
function SoundsManager.setVolume(idOrname,volume)
	local id = GetAudioID(idOrname)
	if id then
		audioEngine:setVolume(id,volume)
	end
end

--@override native 获取音频 播放时间
function SoundsManager.getCurrentTime(idOrname)
	local id = GetAudioID(idOrname)
	if id then
		return audioEngine:getCurrentTime(id)
	end
end

--@override native 设置音频 播放时间
function SoundsManager.setCurrentTime(idOrname,sec)
	local id = GetAudioID(idOrname)
	if id then
		return audioEngine:setCurrentTime(id,sec)
	end
end

--@override native 获取音频 总时间
function SoundsManager.getDuration(idOrname)
	local id = GetAudioID(idOrname)
	if id then
		return audioEngine:getDuration(id)
	end
end

--@override native 设置音频 是否循环
function SoundsManager.setLoop(idOrname,isLoop)
	if type(isLoop) ~= "boolean" then isLoop = false end
	
	local id = GetAudioID(idOrname)
	if id then
		return audioEngine:setLoop(id,isLoop)
	end
end

--是否禁用 背景音乐
function SoundsManager.cancelBGM(bool)
	if type(bool) ~= "boolean" then bool = false end
	if cancelBGM == bool then return end
	
	cancelBGM = bool
	
	if currentBGM then
		if cancelBGM then 
			SoundsManager.stopAudio(currentBGM[1]) 
		else
			SoundsManager.playMusic(unpack(currentBGM))
		end
	end
	
	require("src.base.tools.storage").saveXML("cancelBGM",tostring(cancelBGM))
end
--是否禁用  音效
function SoundsManager.cancelSE(bool)
	if type(bool) ~= "boolean" then bool = false end
	if cancelSE == bool then return end
	cancelSE = bool
	
	if cancelSE then
		SoundsManager.stopAllSounds()
	end
	
	require("src.base.tools.storage").saveXML("cancelSE",tostring(cancelSE))
end
function SoundsManager.isCancelBGM()
	return cancelBGM
end
function SoundsManager.isCancelSE()
	return cancelSE
end

--[[
*	@private 预加载声音，外部不要主动调用
]]
function SoundsManager.preloadAudio(filepath,key)
	local name = SplitName(filepath)
	key = key or "public"
	loadedfilles[name] = {url = filepath,key = key}
	audioEngine:preload(filepath)
	return name
end
--[[
*	@private 播放音频文件，外部不要主动调用
*	记录正在播放的文件，方便业务的实现
]]
function SoundsManager.play2D(filename, isLoop , issound, finishcakkback)
	if type(isLoop) ~= "boolean" then isLoop = false end
	
	local id = audioEngine:play2d(loadedfilles[filename].url,isLoop)
	if not onPlayingFiles[filename] then
		onPlayingFiles[filename] = {}
	end
	
	--记录正在播放的音频
	onPlayingFiles[filename][id] = {
		id 				= id,
		finishcakkback 	= finishcakkback,
		issound			= issound
	}
	if not isLoop then
		--设置回掉
		audioEngine:setFinishCallback(id,SoundsManager.audioFinishCallback)
	end
	
	return id
end
--[[
*	@private 播放完成回掉，外部不要主动调用
]]
function SoundsManager.audioFinishCallback(id,filepath)
	local name = SplitName(filepath)
	if onPlayingFiles[name] and onPlayingFiles[name][id] then
		local callback = onPlayingFiles[name][id].finishcakkback
		onPlayingFiles[name][id] = nil
		if callback then
			callback(id,filepath)
		end
	end
end
--拆分路径，获取文件名
function SplitName(url)
	local src = string.reverse(url)
	local sindex = string.find(src,"/")
	local sindex1 = string.find(src,"%.")
	local len = string.len(url)
	if(not sindex)then
		return
	end
	return string.sub(url,len - sindex + 2, len - sindex1)
end
function GetStatus()
	local utils = require("src.base.tools.storage")
	cancelBGM = utils.getXML("cancelBGM")
	if cancelBGM == "" or cancelBGM == "false" then
		cancelBGM = false
	else
		cancelBGM = true
	end
	cancelSE = utils.getXML("cancelSE")
	if cancelSE == "" or cancelSE == "false" then
		cancelSE = false
	else
		cancelSE = true
	end
end
function GetAudioID(idOrname)
	if type(idOrname) == "number" then
		return idOrname
	else
		if onPlayingFiles[idOrname] then
			local key = next(onPlayingFiles[idOrname])
			return key
		end
	end
end
GetStatus()

Gbv.SoundsManager = SoundsManager

return SoundsManager