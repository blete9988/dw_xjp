--[[
*	http请求
]]
local HttpRequest = {}

--创建一个网络图片文件夹
local fileUtils = cc.FileUtils:getInstance()
local downdir = fileUtils:getWritablePath() .. "urlimg/"
SystemManager:getInstance():createDir(downdir)
fileUtils:addSearchPath(downdir)

--实体池
local entitypools = {}
--内部通讯实体工具类
local inner = {}
--正在请求的图片列表
local ImgLoadingList = {}

local function encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

--创建一个链接实体
function inner.createEntity()
	local entity = {}
	function entity:init()
		local request = cc.XMLHttpRequest:new()
		request.timeout = 10
		request:registerScriptHandler(function() 
			local data,result
			if request.readyState == 4 and (request.status >= 200 and request.status < 207) then
				--请求成功
				result = 0
		        --mlog("Http Status Code:" .. xhr.statusText)
		        if request.responseType == cc.XMLHTTPREQUEST_RESPONSE_STRING then
		        	--字符串，直接返回
		        	data = request.response
		        elseif request.responseType == cc.XMLHTTPREQUEST_RESPONSE_ARRAY_BUFFER then
		        	--字节数组
		        	local response   = request.response
		            local size     = table.getn(response)
		            data = ""
		            for i = 1,size do
		                if 0 == response[i] then
		                    data = string.format("%s%s",data,"\'\\0\'")
		                else
		                    data = string.format("%s%s",data,string.char(response[i]))
		                end
		            end
		        elseif request.responseType == 5 then
		        	--图片
		        	data = downdir..request.response
		        elseif request.responseType == cc.XMLHTTPREQUEST_RESPONSE_JSON then
		        	--json 对象
		            data = json:decode(request.response,1)
		        end
		    else
		    	--请求失败
		        mlog(string.format("xhr.readyState is: %s    xhr.status is: %s",request.readyState,request.status))
		        result = 1
		    end
		    
		    inner.cache(self)
	        self:doListener(result,data)
		end)
		self.m_request = request
	end
	function entity:setListener(callback,target)
		self.m_callback = callback
		self.m_target = target
	end
	function entity:setRequestParams(params)
		self.m_params=params
	end
	function entity:doListener(result,data)
		local callback,target = self.m_callback,self.m_target
		local operateType = self.m_request.responseType
		local name = self.imgname
		
		self.m_callback,self.m_target,self.imgname = nil
		
		if callback then
			if target then
				callback(target,result,data)
			else
				callback(result,data)
			end
		end
		
		--请求的是图片
		if operateType == 5 then
			for i = #ImgLoadingList[name],1,-1 do
				local cell = ImgLoadingList[name][i]
				if cell.target then
					cell.callback(cell.target,result,data)
				else
					cell.callback(result,data)
				end
			end
			ImgLoadingList[name] = nil
		end
	end
	function entity:send(url,operateType,responseType)
		self.m_request.responseType = responseType

	    self.m_request:open(operateType, url)
	    self.m_request:send(self.m_params)
	end
	function entity:close()
		self.m_request:unregisterScriptHandler()
		self.m_request:release() 
	end
	entity:init()
	return entity
end
--获取一个连接实体
function inner.getEntity()
	if #entitypools > 0 then
		return table.remove(entitypools,#entitypools)
	else
		return inner.createEntity()
	end
end
function inner.cache(target)
	table.insert(entitypools,target)
end
function inner.clear()
	for i = 1,#entitypools do
		entitypools[i]:close()
		entitypools[i] = nil
	end
end
function inner.init()
	for i = 1,3 do
		entitypools[i] = inner.createEntity()
	end
end
--初始化3个实体
inner.init()

--[[
*	读取网络图片
*	@param url 			地址
*	@param callback 	回掉函数
*	@param target:		回掉对象
]]
function HttpRequest.loadUrlImage(url,callback,target)
	if url:sub(1,4) ~= "http" then
		--测试时使用本地图片
		if callback then 
			if target then
				callback(target,0,url) 
			else
				callback(0,url) 
			end
		end
		return 
	end
	
--	local len = string.len(url)
--    local pos = len
--    while pos > 0 do
--        local b = string.byte(url, pos)
--        if b == 47 then -- 47 = char "/"
--            break
--        end
--        pos = pos - 1
--    end
--	local name = url:sub(pos + 1)
	local name=cc.XMLHttpRequest:getImageFileName(url)
	if fileUtils:isFileExist(name) then
		if callback then 
			if target then
				callback(target,0,name) 
			else
				callback(0,name) 
			end
		end
	else
		if not ImgLoadingList[name] then
			--将正在请求的图片名保存到列表
			ImgLoadingList[name] = {}
			
			local entity = inner.getEntity()
			entity.imgname = name
			entity:setListener(callback,target)
			entity:send(url,"GET",5)
		else
			table.insert(ImgLoadingList[name],{callback = callback,target = target})
		end
	end
end
--[[
*	外部调用请求方法
*	@param url：				链接地址
*	@param callback：		回掉函数
*	@param target:			回掉对象
*	@param operateType：		请求type，"GET"/"POST"，默认GET
*	@param responseType：	返回类型，默认 string字符串
]]
function HttpRequest.request(url,callback,target,operateType,responseType)
	local entity = inner.getEntity()
	entity:setListener(callback,target)
	entity:send(url,operateType or "POST",responseType or cc.XMLHTTPREQUEST_RESPONSE_STRING)
end

function HttpRequest.post(url,params,callback,target)
--	url="http://127.0.0.1:8081/login"
--	params={
--		uid="123",
--		pwd="3242354"
--	}

	local entity = inner.getEntity()
	entity:setListener(callback,target)
	entity:setRequestParams(params)
	entity:send(url,"POST",cc.XMLHTTPREQUEST_RESPONSE_STRING)
end

function HttpRequest.postJSON(url, params, callback, target)
	local entity = inner.getEntity()

	local lang = require("src.base.tools.storage").getXML("language")
	if(lang == "sc")then
		lang = "th"
	end
	local _params = "lang="..lang.."&"

	for key, value in pairs(params) do
		_params = _params .. key.."="..encodeURI(value).."&"
	end

	_params = string.sub(_params, 1, string.len(_params)-1)

	mlog(DEBUG_E, "params = ", _params)

	entity:setListener(callback,target)


	entity:setRequestParams(_params)
	entity:send(url,"POST",cc.XMLHTTPREQUEST_RESPONSE_JSON)
end

function HttpRequest.debugInfo()
	mlog(string.format("<HttpRequest>:entity len is : %s",#entitypools))
end

setmetatable(HttpRequest,{
	__index = HttpRequest,
	__newindex = function() 
		error(string.format("<HttpRequest> attempt to read undeclared variable <%s>",k))
end})
return HttpRequest