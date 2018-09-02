--[[
*	储存工具
*	@author:lqh
]]
local utils = {}
--[[
*	外部储存
*	## 该表不会随着app删除而被删除，属于健壮的储存
*	默认有一个public 公用表
]]
local datas
--[[
*	内部xml格式 数据储存
*	## 该表会随着app的删除而一起被系统删除掉，不适合保存永久性数据
]]
local userDefault = cc.UserDefault:getInstance()
--base64 
local key = 'rsCDEFGHIlmnopqKLMNOPQz01RSTUVWXu234YZvwxyabcdefgJABijkht56789+/'

--@private static  保存数据到外部，外部储存都是以表的形式储存
local function SaveExternalStorage()
	UserData:getInstance():save(
		require("src.base.tools.base64").encode(
			require("src.cocos.cocos2d.json"):encode(datas)
			,key
		)
	,Cfg.STORAGE_NAME)
end
--@private static 读取外部储存的数据
local function GetExternalStorange()
	local str,data = UserData:getInstance():loadLocalData(Cfg.STORAGE_NAME)
	if str ~= "" then
		pcall(function() 
			data = require("src.cocos.cocos2d.json"):decode(
				require("src.base.tools.base64").decode(str,key)
			) 
		end)
	else
		data = {}
		--默认公用表
		data.public = {}
	end
	return data
end
--[[
*	保存数据到内部xml数据表中
*	@param key 键
*	@param value 值
]]
function utils.saveXML(key,value)
	userDefault:setStringForKey(key,tostring(value))
end
--[[
*	获取内部 xml表中的值
*	@param key 键
*	@return 值
]]
function utils.getXML(key)
	if(key == "language")then
		local lang = tostring(userDefault:getStringForKey(key))
		if(lang == "")then
			userDefault:setStringForKey(key,tostring("en"))
		end
	end

	return userDefault:getStringForKey(key)
end
--[[
*	将键值保存到 外部储存public表中
*	@param key 键
*	@param value 值
]]
function utils.savePublic(key,value)
	datas.public[key] = value
	SaveExternalStorage()
end
--[[
*	获取 外部储存public表中的属性
*	@param key 键
*	@return 值
]]
function utils.getPublic(key)
	return datas.public[key]
end
-- 自定义表-----------------
function utils.getCustom(tbname,key)
	if not datas[tbname] then 
		datas[tbname] = {}
	end
	return datas[tbname][key]
end
function utils.saveCustom(tbname,key,value)
	if not datas[tbname] then datas[tbname] = {} end
	datas[tbname][key] = value

	mlog("saveCustom", datas)
	SaveExternalStorage()
end
--初始化公用表
function utils.init()
	datas = GetExternalStorange()

	mlog("storage.init", datas)
end
utils.init()
return utils