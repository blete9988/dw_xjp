local YouMeng = {}

local luaj = require "src.cocos.cocos2d.luaj" --引入luaj

--初始化
function YouMeng:init()
	-- body
end

local function callbackLua()
    
end

--登录
function YouMeng:login()
	local className = "org/cocos2dx/lua/AppActivity"
	local args = { "xxx" }  
    local sigs = "(Ljava/lang/String;)V" --传入string参数，无返回值  
        --display.showMsg("调用友盟登录")  

	    --luaj 调用 Java 方法时，可能会出现各种错误，因此 luaj 提供了一种机制让 Lua 调用代码可以确定 Java 方法是否成功调用。  
    --luaj.callStaticMethod() 会返回两个值  
    --当成功时，第一个值为 true，第二个值是 Java 方法的返回值（如果有）  
    --当失败时，第一个值为 false，第二个值是错误代码  
    local ok = luaj.callStaticMethod(className,"auth",args,sigs)  

    display.showMsg(ok)
    if not ok then  
    

    end  
end

--退出
function YouMeng:SignOut( ... )
	-- body
end

--支付购买
function YouMeng:Buy( ... )
	-- body
end

return YouMeng