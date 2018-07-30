--[[
*	下载工具类
*	可获取版本号，服务器列表，更新列表 和 下载包等操作
*	版本号请求会 自动对版本号就行检查，通过返回参数获取版本号比对结果（默认版本号是3位有效数字 ： 0.0.0 格式）
*	
*	@author：lqh
]]
local versionMgr = {}

local TIME_OUT = 8				--超时时间

--[[
*	版本号 验证
*	@param callback：回调函数
*	@param updatelist: 是否强制更新服务器列表
]]
function versionMgr.versionVerify(url,callback)		
	local downdir = cc.FileUtils:getInstance():getWritablePath()
	mlog("-=----")
	mlog(downdir)
	mlog("-=----")
		require("src.base.http.HttpRequest").postJSON(require("src.app.config.server.server_config").apihost..'res/version', {}, function(result, data)
				if result ~=0 then
					--请求失败
					mlog(DEBUG_S,"<versionMgr>: verson verify fail!!")
					callback(1)
					return
				end
				
				local server_data = {}
				--请求成功
				if  data and data.data then
					server_data = data.data

									--这里也应该判断一下版本号 如果服务器版本号大于本地的 开始下载 如果相等直接进入游戏
					-- local version = require("src.version")
					-- -- if(version == data.sversion)then
					-- -- 	self:enterNextScene()
					-- -- 	return
					-- -- end
					-- mlog(server_data.sversion)
					-- mlog(version)
					-- if server_data.sversion == version then --这里应该判断一下版本号把。。。。
					-- 	mlog(string.format("<versionMgr>:request server version: %s",server_data.version))
					-- else
					-- 	mlog(string.format("<versionMgr>:local version equal server version!"))
					-- end
				end
				callback(0,server_data)
			end)

	-- require("src.base.http.HttpRequest").request(
	-- 	url,
	-- 	function(result,data) 			
	-- 		if result ~=0 then
	-- 			--请求失败
	-- 			mlog(DEBUG_S,"<versionMgr>: verson verify fail!!")
	-- 			callback(1)
	-- 			return
	-- 		end
	-- 		local server_data = {}
	-- 		--请求成功
	-- 		if  data and data ~= "" then
	-- 			server_data = require("src.cocos.cocos2d.json"):decode(data)
	-- 			if server_data.update then --这里应该判断一下版本号把。。。。
	-- 				mlog(string.format("<versionMgr>:request server version: %s",server_data.version))
	-- 			else
	-- 				mlog(string.format("<versionMgr>:local version equal server version!"))
	-- 			end
	-- 		end
	-- 		callback(0,server_data)
	-- 	end
	-- )
end
--刷新本地版本号
function versionMgr.writeVersion(version)
	local downdir = cc.FileUtils:getInstance():getWritablePath()
	SystemManager:getInstance():createDir(string.format("%s%s",downdir,"src/"))
	--保存版本号
	io.writefile(
		string.format("%ssrc/version.lua",downdir),
		string.format("local version = '%s'\nreturn version",version)
	)
	--清理版本号缓存
	package.loaded["src.version"] = nil
end

--获取本机所在地区区域号
function versionMgr.getLocalCode()
	local localarea = SystemManager:getInstance():getCountry()
	if localarea == 0 then
		return "sc"
	elseif localarea == 1 then
		return "tc"
	elseif localarea == 2 then
		return "en"
	end
end

setmetatable(versionMgr,{
	__index = {},
	__newindex = function(t,k,v)
		error(string.format("<versionMgr> attempt to read undeclared variable <%s>",k))
	end
})
return versionMgr
