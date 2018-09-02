--[[
*	启动界面 <br/>
*	执行不同区域的服务器列表请求，版本号请求<br/>
*	@author:lqh<br/>
]]
local StartScene = class("StartScene",require("src.base.extend.CCSceneExtend"))
function StartScene:ctor()
	self:super("ctor")
	--加载基础语言包
	local beforeLanguage = tostring(require("src.base.tools.storage").getXML("language"))

	display.loadLanguage(beforeLanguage,"src.command.language.base_language")
	
	local background = display.newImage("#" .. display.getResolutionPath("loading_background.jpg"))
	self:addChild(Coord.scgap(background,"CC",0,"CC",0))
	self:addChild(Coord.scgap(require("src.base.log.debugKey")(),"LL",0,"BB",0))
	
	local tips = cc.LabelTTF:create(display.trans("##10"),Cfg.FONT,32)
	tips:enableStroke(cc.c3b(0xff,0xff,0xff),2)
	tips:enableShadow(cc.size(5,-3),0.3,1,true)
	tips:setColor(Cfg.COLOR)
	self:addChild(Coord.scgap(tips,"CC",0,"BC",150))
	self.tips = tips
end
function StartScene:onEnter()
	if require("src.cocos.framework.device").isWindows() then
		--windows直接登陆
		self:enterNextScene()
		-- self:examineLaunch()
	else
		--检测启动
		self:examineLaunch()
		-- self:enterNextScene()
	end
end

local function split( str,reps )
    local resultStrList = {}
    string.gsub(str,'[^'..reps..']+',function ( w )
        table.insert(resultStrList,w)
    end)
    return resultStrList
end

-- --获得验证码
-- --_type 1 小尾数更新  2 大版本更新
local function getSversion(sversion,_type)
	local sversion_list = split(sversion,".")
	-- for i,v in ipairs(sversion_list) do
	-- 	mlog(i,v)
	-- end
	return tonumber(sversion_list[_type])
end

--开始验证
function StartScene:examineLaunch()
	self.tips:setString(display.trans("##14"))
	-- local url = "http://127.0.0.1:8080/src.zip"
	local url = require("src.app.config.server.server_config").apihost.."res/version"
	local versionMgr = require("src.base.tools.versionMgr")
	
	versionMgr.versionVerify(url,function(status,data) 
		if status == 0 then
			--请求正常返回
			if not data.sversion then
				--正常登陆
				self:enterNextScene()
			else
				--比较版本
				
				--提示从平台重新下载
--				self.tips:setColor(Color.GREEN)
--				self.tips:setString(display.trans("##22"))
				

				--这里也应该判断一下版本号 如果服务器版本号大于本地的 开始下载 如果相等直接进入游戏
				local version = require("src.version")
				mlog("当前版本:",version)
				mlog("最新版本:",data.sversion)
				-- mlog("最新版本:",data.urr)

				local cur_ver = getSversion(version,2)
				local server_ver = getSversion(data.sversion,2)

				if(server_ver > cur_ver)then
					--提示从平台重新下载
					self.tips:setColor(Color.GREEN)
					self.tips:setString(display.trans("##22"))
					return
				end

				local cur_ver_3 = getSversion(version,3)
				local server_ver_3 = getSversion(data.sversion,3)
				-- mlog("cur_ver_3")
				-- mlog(cur_ver_3)
				-- mlog(server_ver_3)
				-- mlog("server_ver_3")
				if(cur_ver_3 >= server_ver_3)then
					mlog("版本相同直接进入游戏")
					self:enterNextScene()
					return
				end

				--在线更新
				self.tips:setString(display.trans("##16"))
				self:download(data)
			end
		elseif status == 1 then
			--请求返回失败
			display.showPop({
				info = display.trans("##11"),flag = 2,
				callback = function() self:examineLaunch() end,
			})
		end
	end)
end

--开始下载
function StartScene:download(data)	

	local version = require("src.version")

	self.tips:setString(display.trans("##18",1,1,0))
	local dowlist = data.update

	local count = 1
	
	local function lanuchdown(downdata)

		if(downdata)then
			mlog("更新地址：",downdata.url)
			mlog("更新版本：",downdata.sversion)

			local cur_ver_3 = getSversion(version,3)
			local server_ver_3 = getSversion(downdata.sversion,3)
			
			if(cur_ver_3 >= server_ver_3)then
				count = count+ 1
				lanuchdown(dowlist[count])
				return
			end
		else
			reload("src.reExcute")(function() 
				self:enterNextScene()
			end)
		end
		
		require("src.base.tools.zipdownload").download(downdata.url,
			function()
				self.tips:setString(display.trans("##27"))
				require("src.base.tools.versionMgr").writeVersion(downdata.sversion)
				count = count+ 1
				if not dowlist[count] then
					reload("src.reExcute")(function() 
						self:enterNextScene()
					end)
				else
					lanuchdown(dowlist[count])
				end
			end,
			function(percent) 
				if percent >= 100 then
					self.tips:setString(display.trans("##26"))
				else
					self.tips:setString(display.trans("##18",1,1,percent))
				end
			end,
			function(errorCode)
				local tiptext
		    	if errorCode == 0 then
		    		tiptext = display.trans("##25")
		    	elseif errorCode == 1 then
		    		tiptext = display.trans("##17")
		    	else
		    		tiptext = display.trans("##24")
		    	end
		    	display.showPop({
		    		info = tiptext,flag = 2,
		    		callback = function() 
	--	    			self.tips:setString(display.trans("##18",current,len,0))
	--	    			require("src.base.tools.UpdataManager").downloadPackage(onSuccess,onProgress,onError)
		    		end
		    	})
			end
		)
	end
	lanuchdown(dowlist[count])	
end

--跳转到下一页面
function StartScene:enterNextScene()
	timeout(function() 
		display.enterScene("src.ui.scene.login.LoadingScene")
	end,0.5)
	RestRandom()
end
function StartScene:onExit()
	
end
return StartScene
