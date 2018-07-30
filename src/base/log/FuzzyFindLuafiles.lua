--[[
*	字符串匹配，模糊查找lua文件
]]
local FuzzyFindLuafiles = {}

--正在查找的关键字
local onfindkey
--[[
*	设置查找字典
*	@param data 数据格式为key-value
]]
function FuzzyFindLuafiles:init()
	onfindkey = {}
	local files = self:getLoadedLuaFiles()
	if not self.dic then self.dic = {} end
	
	local t = self.dic
	local str
	for k,v in pairs(files) do
		str = k:sub(1,1)
		if not t[str] then
			t[str] = {}
		end
		if not t[str][k] then 
			t[str][k] = v
		end
	end
end
function FuzzyFindLuafiles:find(str)
	if not str or str == "" then return {} end
	str = str:lower()
	local len = str:len()
	if len == 1 then
		return table.values(self.dic[str] or {})
	end
	if onfindkey[str] then return table.values(onfindkey[str]) end
	
	local ct = self.dic[str:sub(1,1)]
	if not ct then return {} end
	
	local index = 2
	while index <= len do
		local kw = str:sub(1,index)
		if onfindkey[kw] then
			ct = onfindkey[kw]
		else
			local tempt = {}
			local len = 0
			for k,v in pairs(ct) do
				if k:sub(1,index) == kw then
					tempt[k] = v
					len = len + 1
				end
			end
			if len == 0 then return {} end
			ct = tempt
			onfindkey[kw] = ct
			--数量为1，结束
			if len == 1 then break end
		end
		index = index + 1
	end
	return table.values(ct)
end
--获取已经加载的lua文件，只获取app,ui,command下的文件
function FuzzyFindLuafiles:getLoadedLuaFiles()
	local function check(str)
		local temp = string.reverse(str)
		local st,_ = string.find(temp,"%.")
		return st - 2
	end
	local tb = {}
	for k,v in pairs(package.loaded) do
		if string.sub(k,1,7) == "src.app" or string.sub(k,1,11) == "src.command" or string.sub(k,1,6) == "src.ui" or string.sub(k,1,9) == "src.games" then
			tb[string.lower(string.sub(k,string.len(k) - check(k)))] = k
		end
	end
	return tb
end
return FuzzyFindLuafiles