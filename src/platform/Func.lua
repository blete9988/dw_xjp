local Func = {}

function Func.copyToClipboard(text)
    local device = require('src.cocos.framework.device')
    if device.isIOS() then 
		local luaoc = require "src.cocos.cocos2d.luaoc"

        luaoc.callStaticMethod("Func","copyToClipboard",{["content"]=text})
    elseif(device.isAndroid())then
		local luaj = require "src.cocos.cocos2d.luaj" --引入luaj

		local className = "org/cocos2dx/lua/AppActivity"
		local args = { text }  
	    local sigs = "(Ljava/lang/String;)V" --传入string参数，无返回值  
	        --display.showMsg("调用友盟登录")  

		    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
	    --luaj.callStaticMethod() 会返回两个值  
	    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
	    --当失败时，第一个值为 false，第二个值是错误代码  
	    local ok,ret= luaj.callStaticMethod(className,"copyToClipboard",args,sigs)  
	end
end

return Func