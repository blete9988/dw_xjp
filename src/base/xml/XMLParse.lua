--[[
*	xml解析器
*	可解析嵌套包含，支持非标签内容出现任何字符
*	## 注意
*		<span name="test=a">xxx</span> 错误写法，无法正常解析，因为属性值中出现 = 符号
*		<span text="bb">xxx</span> 错误写法，text关键字是默认内容 属性变量名
*	## 特殊字符应使用转意字符表示
*		属性标签中的特殊字符串应用相应的转义符替换
*			替换特殊字符可以调用 string.codeXml(str) 方法
*			还原转义符可以调用 string.parseXml(str) 方法
*	## 属性标签中 的值是否使用 " 包含，暂无特殊要求
*		如果使用 " 则必须成对出现，否则出错
*	
*	@author：lqh
]]
local XMLParse = {}

local ParseNode = require("src.base.xml.ParseNode")
--标签栈，用于记录标签
local p_tagStack = {}

--定义合法的标签头
XMLParse.DefineTAG = {
	span = "span",
	p = "p",
	event = "event",
	img = "img",
	custom = "custom",
}
--独立标签，该类标签不需要结束标签 作为结束
local SingleTAG = {
	img = "img",
	custom = "custom"
}

local function CloneNode(node)
	if not node then return ParseNode.new() end
	return node:clone()
end
--[[
*	将字符串数组 实例化，并放入实例队列
*	@param strList 字符串数组
*	@param objlist 实例队列
*	@param templete 模板实例
]]
local function PushObjectList(strList,objlist,templeteNode)
	local node
	for i = 1,#strList do
		node = CloneNode(templeteNode)
		node:saveText(strList[i])
		if i > 1 then
			table.insert(objlist,node:setNewline(true))
		else
			table.insert(objlist,node)
		end
	end
end

--[[
*	解析换行符
*	@return 拆分换行符后的字符串列表
]]
function XMLParse.parseNewline(str)
	if str == "" then return {} end
	local list,sp,ep = {},1
	while true do
		ep = str:find("\n",sp,true)
		if not ep then
			table.insert(list,str:sub(sp))
			break
		end
		table.insert(list,str:sub(sp,ep - 1))
		sp = ep + 1
	end
	return list
end
--[[
*	解析标签
*	@return 是解析正确，标签对象，是否尾标签
]]
function XMLParse.parseHtmlTag(str)
	if str == "" then return false end
	--上一个标签
	local front_tag = p_tagStack[#p_tagStack]
	
	--尾标签
	if str:sub(1,1) == "/" then
		--结束标签 与上一个标签不匹配
		if not front_tag or front_tag:getTag() ~= str:sub(2) then return false end
		return true,nil,true
	end
	
	--通过空格拆分标签内容
	local list,sp,ep = {},1
	while true do
		ep = str:find(" ",sp,true)
		if not ep then
			table.insert(list,str:sub(sp))
			break
		end
		table.insert(list,str:sub(sp,ep - 1))
		sp = ep + 1
	end
	--检测标签头是否定义
	if not XMLParse.DefineTAG[list[1]] then return false end
	
	--继承父标签
	local node,index,len,temp = CloneNode(front_tag),2,#list
	node:saveTag(list[1])
	
	--解析标签属性
	while index <= len do
		temp = list[index]
		if temp ~= "" and temp ~= "/" then
			sp = temp:find("=",1)
			--标签头属性解析出错
			if not sp then return false end
			--拆分key,value 并去除 引号，转换value中的转意字符
			node:saveKey(temp:sub(1,sp - 1),temp:sub(sp + 1):gsub("[\"']",""):parseXml())
		end
		index = index + 1
	end
	
	return true,node
end
--[[
*	html 解析方法
*	html解析与xml解析分离，html涉及一些复杂的容错还原 原始文本的功能，需要单独处理
*	返回一个 属性结构体 数组
]]
function XMLParse.parsehtml(str)
	--标签栈，内容栈
	p_tagStack = {}
	
	local parselist,leadcharlist,sp = {},{},1
	--查找所有 < 符号的位置
	while true do
		--查找 指定符号，关闭匹配模式
		sp = str:find("<",sp,true)
		if not sp then break end
		table.insert(leadcharlist,sp)
		sp = sp + 1
	end
	--未使用html样式
	if #leadcharlist == 0 then
		PushObjectList(XMLParse.parseNewline(str),parselist)
		return parselist 
	end
	--当前 < 记录数组的下标，标签内解析是否出错，标签数据，是否尾标签
	local currentlen,isright,node,isTailTag = 1
	--当前解析位置
	local cp,temp_cp = 1
	sp = 1
	while true do
		sp = str:find(">",sp,true)
		if not sp then 
			PushObjectList(XMLParse.parseNewline(str:sub((temp_cp or cp))),parselist,p_tagStack[#p_tagStack])
			break 
		end
		
		--判断 "<" 出现的位置和  ">" 是否对应
		if leadcharlist[currentlen] and sp > leadcharlist[currentlen] then
			while true do
				--当下一个"<" 标签位置大于当前 ">"位置 视为正确标签
				if not leadcharlist[currentlen + 1] or (leadcharlist[currentlen + 1] > sp) then
					
					--首先解析标签头
					isright,node,isTailTag = XMLParse.parseHtmlTag(str:sub(leadcharlist[currentlen] + 1,sp - 1))
					--标签头出错
					if not isright then 
						temp_cp = temp_cp or cp 
						break 
					end
					
					PushObjectList(XMLParse.parseNewline(str:sub((temp_cp or cp),leadcharlist[currentlen] - 1)),parselist,p_tagStack[#p_tagStack])
					cp , temp_cp = sp + 1 , nil
					
					
					if isTailTag then
						--尾标签 出栈
						node = table.remove(p_tagStack,#p_tagStack)
						if node:getTag() == XMLParse.DefineTAG.p then 
							--段落标 ，插入一个换行符
							table.insert(parselist,ParseNode.new():setNewline(true))
						end
					else
						if SingleTAG[node:getTag()] then
							--单标签 直接放入 结果队列中
							table.insert(parselist,node)
						else
							--放入标签栈中
							table.insert(p_tagStack,node)
							if node:getTag() == XMLParse.DefineTAG.p then 
								--防止连续出现p标签多次换行
								if not parselist[#parselist] or not parselist[#parselist]:getNewline() then
									--段落标 ，向结果队列插入一个换行符
									table.insert(parselist,ParseNode.new():setNewline(true))
								end
							end
						end
					end
					
					break
				end
				currentlen = currentlen + 1
			end
			currentlen = currentlen + 1
		end
		sp = sp + 1
	end
	
	return parselist
end


return XMLParse