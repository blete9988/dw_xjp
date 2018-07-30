--[[
*	XMLParse解析后的实例化Node对象
*	记录每个标签的属性，并提供反射属性接口
]]
local ParseNode = class("ParseNode")

-- -------------------------------------私有静态方法--------------------------------------------
--字符串转换成cc.c3b颜色值，缺省的 颜色位用 0 补齐
local function toc3b(str)
	if str:len() < 6 then
		str = string.format("%s%s",str,"000000")
	end
	return {
				r = tonumber(str:sub(1,2),16) or 0,
				g = tonumber(str:sub(3,4),16) or 0,
				b = tonumber(str:sub(5,6),16) or 0,
		   }
end
--字符串 转换成cc.c4b颜色值{r,g,b,a}，缺省的颜色位用 0 补齐，缺省的alpha位用 f 补齐
local function toc4b(str)
	local strlen = str:len()
	if strlen < 8 then
		local t = {}
		for i = strlen + 1,8 do
			if i > 6 then
				table.insert(t,"f")
			else
				table.insert(t,"0")
			end
		end
		str = str .. concat(t,"")
	end
	return {
				r = tonumber(str:sub(1,2),16) or 0,
				g = tonumber(str:sub(3,4),16) or 0,
				b = tonumber(str:sub(5,6),16) or 0,
				a = tonumber(str:sub(7,8),16) or 255
		   }
end
--分割字符串
local function split(str,delimiter)
	if (delimiter=='') then return {str} end
	local pos,tb = 0, {}
	for sp,ep in function() return str:find(delimiter, pos, true) end do
		table.insert(tb, str:sub(pos, sp - 1))
        pos = ep + 1
	end
	table.insert(tb,str:sub(pos))
	return tb
end

-- ------------------------------------------class-----------------------------------------
function ParseNode:ctor()
	self.tag_proprity = {}
end
--保存key，value
function ParseNode:saveKey(key,value)
	self.tag_proprity[key] = value
end
function ParseNode:getKey(key)
	return self.tag_proprity[key]
end
--设置文本内容
function ParseNode:saveText(str)
	self.text_ = str
end
--获取文本内容
function ParseNode:getText()
	return self.text_
end
--保存标签头
function ParseNode:saveTag(str)
	self.tag_ = str
end
--获取标签头
function ParseNode:getTag()
	return self.tag_
end
--获取int
function ParseNode:getInt(key)
	local keyValue = self.tag_proprity[key]
	if not keyValue then return end
	return tonumber(keyValue)
end
--获取boolean
function ParseNode:getBoolean(key)
	local value = self.tag_proprity[key]
	if not value then return false end
	if value == "true" then return true end
	return false
end
--获取color3B
function ParseNode:getC3b(key)
	local keyValue = self.tag_proprity[key]
	if not keyValue then return end
	
	return toc3b(keyValue)
end
--获取color4B
function ParseNode:getC4b(key)
	local keyValue = self.tag_proprity[key]
	if not keyValue then return end
	
	return toc4b(keyValue)
end
--获取cc.size
function ParseNode:getContentSize(key)
	local keyValue = self.tag_proprity[key]
	if not keyValue then return end
	
	local value = split(keyValue,",")
	value = {width = tonumber(value[1]) or 0,height = tonumber(value[2]) or 0}
	return value
end
--获取字符串s
function ParseNode:getString(key)
	return self.tag_proprity[key] or ""
end
function ParseNode:setNewline(value)
	self.isNewline = value
	return self
end
function ParseNode:getNewline()
	return self.isNewline
end

--[[
*	克隆
*	@cloneNode: ParseNode对象，如果为空，则生成一个新的ParseNode对象
]]
function ParseNode:clone(cloneNode)
	cloneNode = cloneNode or ParseNode.new()
	for k,v in pairs(self.tag_proprity) do
		cloneNode.tag_proprity[k] = v
	end
	cloneNode.tag_ = self.tag_
	return cloneNode
end
return ParseNode