--[[
*	语言转换工具
*	@author:lqh
]]
local LanguageTranform = {}
--当前加载的语言
local languagedata
--加载语言
function LanguageTranform.setLanguage(data)
	languagedata = data
end
--[[
*	检查id正确性，id格式不对直接返回该id
*	@paran:id id格式可以是纯数字，也可以是以 ## + 数字组合
*	@param:... 参数匹配列表，会自动替换语言包中以 #+数字（从1开始递增） 的关键字
]]
function LanguageTranform.transform(id,...)	
	if not id then return "" end
	local rid
	if type(id) == "string" then
		local s,e = string.find(id,"##")
		if e ~= 2 then 
			rid = tonumber(id)
		else
			rid = tonumber(string.sub(id,3))
		end
	else
		rid = id
	end
	if not rid then return id end
	
	local msg = languagedata[rid]
	if msg then
		local tempstr
		if ... then
			local arg = {...}
			for i = 1 , #arg do
				tempstr = string.trimpercent(arg[i])
				msg = string.gsub(msg,"#" .. i,tempstr)
			end
		end
		tempstr = string.untrimpercent(msg)
		return tempstr
	end
	mlog(DEBUG_W,string.format("<LanguageTranform>:can not get info by id = %s",rid))
	return languagedata[1] .. rid
end

setmetatable(LanguageTranform,{
	__index = {},
	__newindex = function(t,k,v)
		error(string.format("<LanguageTranform> attempt to read undeclared variable <%s>",k))
	end
})
return LanguageTranform