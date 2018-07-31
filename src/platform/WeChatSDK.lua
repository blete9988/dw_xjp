local WeChatSDK = {}

local doLogin = function(loginType, username, password)
	--保存账号密码
	local storage = require("src.base.tools.storage")
	storage.saveXML('acc_loginType', loginType)
	storage.saveXML('acc_username', username)
	storage.saveXML('acc_password', password)

	-- local server = "tcp://192.168.31.100:6001"
	local server = require("src.app.config.server.server_config").server
	require("src.app.connect.LoginManager").launch(server, loginType, username, password)
end

function WeChatSDK.init(wechatSettings)
	local device = require('src.cocos.framework.device')
	if device.isIOS() then
		require("src.cocos.cocos2d.luaoc").callStaticMethod("WechatSDK", "init", {appid='wx69363b336120f9e0'})
	end
end

local function onGetOpenId(code)
	timeout(function()
		mlog(DEBUG_W,"发送code:"..code.." 到服务器")
		require("src.base.http.HttpRequest").postJSON(require("src.app.config.server.server_config").apihost..'wechat/auth', {
				['code'] = code
			}, function(result, data)

				dump(data)
				if data == nil then
					display.showMsg("注册失败")
					return
				end

				if data["errno"] ~= 0 then
					display.showMsg(data["errmsg"] or "授权失败")
					return
				end
	    		
				if(data["data"]["openid"])then
					doLogin("user", data["data"]["openid"],data["data"]["openid"])
				else
					mlog(DEBUG_W,"openid为mull")
				end

			end)
		end,1)
end

local function onBack(msg)
    mlog(DEBUG_W,"返回code-=------------------"..msg)

    onGetOpenId(msg)

end
function WeChatSDK.auth(callback)

	local device = require('src.cocos.framework.device')
	if device.isIOS() then 
		local luaoc = require "src.cocos.cocos2d.luaoc"

		local ok = luaoc.callStaticMethod("WechatSDK","auth",{callback=function(result)
			local resp = require("src.cocos.cocos2d.json"):decode(result)
			dump(resp)
			if resp == nil or resp.result ~= "0" then
				display.showMsg("登录失败")
				return
			end

			onBack(resp.msg)
		end})

		if not ok then
			display.showMsg("微信登陆")	
		end
	elseif device.isAndroid() then 
		local luaj = require "src.cocos.cocos2d.luaj" --引入luaj

		local className = "org/cocos2dx/lua/AppActivity"
		local args = { "callbacklua",onBack }  
	    local sigs = "(Ljava/lang/String;I)V" --传入string参数，无返回值  
	        --display.showMsg("调用友盟登录")  

		    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
	    --luaj.callStaticMethod() 会返回两个值  
	    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
	    --当失败时，第一个值为 false，第二个值是错误代码  
	    local ok,ret= luaj.callStaticMethod(className,"auth",args,sigs)  

	    display.showMsg(ok)
	    if not ok then  
			display.showMsg("微信登陆")	
	    else

	    end  
	else
		display.showMsg("平台错误")
	end

end

return WeChatSDK