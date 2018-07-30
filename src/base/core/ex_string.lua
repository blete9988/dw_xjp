--[[
*	扩展string
*	添加一些常用的字符串解析，拆分方法，数值转换方法
]]


local qrep = {["\\"]="\\\\", ["'"]="\\'",['\n']='\\n',['\t']='\\t',['\r'] = '\\r'}
--[[
*	table to string，表转换为带格式的字符串
*	@param:tb 	原始表
*	@param:b 	制表符（格式控制，不用传参）
]]
function string.t2s(tb,b--[[ = nil]])  
	b = b or ""
	b = b .. "\t"
	
	local t
	local str = "{ "
	local style = "%s\n" .. b .. "%s = %s%s"
	for k,v in pairs(tb) do
		t = type(v)
		if type(k) == "number" then k = string.format("[%d]",k) end
		if t == "number" or t == "boolean" then  
			str = string.format(style,str,k,tostring(v),",")
		elseif t == "string" then  
			v = string.gsub(v, "['\\\n\t\r]", qrep)
			str = string.format(style,str,k,string.format("'%s'",v),",")
		elseif t == "table" then 
			str = string.format(style,str,k,string.t2s(v,b),",")
		end
	end
	return string.format("%s\n%s}",string.sub(str,1,-2),string.sub(b,1,-2))
end
--数值简化，将大数值简化成中国单位 千，万，亿
function string.cnspNmbformat(value)
	local unitstr,signstr,temp = "","",math.abs(value)
	if value < 0 then
		signstr = "-"
		value = -value
	end
	if value >= 100000000 then
		unitstr = "亿"
		temp = value * 0.00000001
	elseif value >= 10000 then
		unitstr = "万"
		temp = value * 0.0001
	else
		return signstr .. value
	end
	
	if temp < 10 then
		return signstr .. math.floor(temp*100)*0.01 .. unitstr
	elseif temp < 100 then
		return signstr .. math.floor(temp*10)*0.1 .. unitstr
	else
		return signstr .. math.floor(temp) .. unitstr
	end
end
--数值简化，将大数值简化为带单位的数值(b,m,k)
function string.nmbformat(value)
	local unitstr,signstr,temp = "","",math.abs(value)
	if value < 0 then
		signstr = "-"
		value = -value
	end
	if value >= 1000000000 then
		unitstr = "b"
		temp = value * 0.000000001
	elseif value >= 1000000 then
		unitstr = "m"
		temp = value * 0.000001
	elseif value >= 1000 then
		unitstr = "k"
		temp = value * 0.001
	else
		return signstr .. value
	end
	if temp < 10 then
		return signstr .. math.floor(temp*100)*0.01 .. unitstr
	elseif temp < 100 then
		return signstr .. math.floor(temp*10)*0.1 .. unitstr
	else
		return signstr .. math.floor(temp) .. unitstr
	end
end
--数字转换成千分位格式
function string.thousandsformat(value)
	local formatted,k = tostring(value)
    while true do
        formatted, k = string.gsub(formatted, "(%d+)(%d%d%d)", '%1,%2',1)
        if k == 0 then break end
    end
    return formatted
end
--倒计时格式化，转换成带单位的时间格式，值保留两个有效单位，最大单位为：d
function string.cdforamt(t)
    if t >= 86400 then
    	return string.format("%dd%dh",math.floor(t/86400),math.floor((t%86400)/3600))
    elseif t >= 3600 then
    	return string.format("%dh%dm",math.floor(t/3600),math.floor((t%3600)/60))
    elseif t >= 60 then
    	return string.format("%dm%ds",math.floor(t/60),(t%60))
    else
    	return t .. "s"
    end
end
--[[
*	数字转换日期格式
*	number：数字值
*	separator:分割符（默认 ：号）
*	flag：是否为24小时格式(只显示时分)
]]
function string.dateformat(t,separator,flag)	
	separator = separator or ":"
	if not flag then
		return string.format("%02d%s%02d%s%02d",math.floor(t/3600),separator,math.floor((t%3600)/60),separator,t%60)
	end
	return string.format("%02d%s%02d",math.floor(t/3600),separator,math.floor((t%3600)/60))
end

--[[
*	utf-8是对unicode字符集的编码方案。因此其变长编码方式为：
*	一字节：0*******
*	两字节：110*****，10******
*	三字节：1110****，10******，10******
*	四字节：11110***，10******，10******，10******
*	五字节：111110**，10******，10******，10******，10******
*	六字节：1111110*，10******，10******，10******，10******，10******
*	因此，拿到字节串后，想判断UTF8字符的byte长度，按照上文的规律，只需要获取该字符的首个Byte，根据其值就可以判断出该字符由几个Byte表示。
]]
local utftag = {0xc0, 0xe0, 0xf0, 0xf8, 0xfc}	--192,224,240,248,252

--计算字符串长度，英文字符占1个长度，其余占2个长度
function string.strlen(str)	
	local strlen = string.len(str)
	local count,i = 0,1
	local utflen = 0
	local asc2,k
	while i <= strlen  do
		asc2,k = string.byte(str, i),1
		while utftag[k] do
			i = i + 1
			if asc2 < utftag[k] then
                break
            end
			k = k + 1
		end
		utflen = utflen + 1
		if k == 1 then --英文字符+1
			count = count + 1
		else			--非英文字符+2
			count = count + 2
		end
	end
	return count,utflen
end
--[[
*	对UTF8 字符串进行精确截断
*	@param：str 源字符串
*	@param：pos 指定截取位置（该位置需要通过 上面 string.strlen 计算后得出的截断位置）
]]
function string.splitUTF8(str,pos)	
	local strlen = string.len(str)
	if pos <= 0 then return "",str,0 end
	
	local count,i = 0,1
	local asc2,k
	while i <= strlen  do
		asc2,k = string.byte(str, i),1
		while utftag[k] do
            i = i + 1
			if asc2 < utftag[k] then
                break
            end
            k = k + 1
		end
		if k == 1 then --英文字符+1
			count = count + 1
		else			--非英文字符+2
			count = count + 2
		end
		
		if count >= pos then
			return string.sub(str,1,i - 1),string.sub(str,i),count
		end
	end
	return str,"",count
end
function string.utf8len(str)
	local strlen = string.len(str)
	local count,i = 0,1
	local asc2,k
	while i <= strlen  do
		asc2,k = string.byte(str, i),1
		while utftag[k] do
			i = i + 1
			if asc2 < utftag[k] then
                break
            end
			k = k + 1
		end
		count = count + 1
	end
	return count
end
--分割字符串
function string.split(str, delimiter,plain)
    if (delimiter=='') then return false end
    if plain == nil then 
    	plain = true
    else
	    plain = tobool(plain)
    end
    local pos,arr = 0, {}
    -- for each divider found
    for st,sp in function() return string.find(str, delimiter, pos, plain) end do
        table.insert(arr, string.sub(str, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(str, pos))
    return arr
end
--解析数字
function string.splitNumber(str,delimiter)
	local parse = str:split(delimiter or ",")
	local list = {}
	for i = 1,#parse do
		list[i] = tonumber(parse[i])
	end
	return list
end
--去除百分号
function string.trimpercent(str)
	return string.gsub(str,"[%%]","&#001;")
end
--还原百分号
function string.untrimpercent(str)
	return string.gsub(str,"&#001;","%%")
end
--去除空格制表换行符
function string.trim(str)
	return string.gsub(str, "[ \t\n\r]+", "")
end
--转换首字符为大写
function string.ucfirst(str)
    return string.upper(string.sub(str, 1, 1)) .. string.sub(str, 2)
end

--xml解析特殊字符库
local xmlspchar = {['"'] = "&#034;",["'"] = "&#039;",["<"] = "&#060;",["="] = "&#061;",[">"] = "&#062;",[" "] = "&#032;"}
--编码 内部XMLParse属性可以识别的字符串
function string.codeXml(str)
	str = str:gsub('%%',"&#037;")
	for k,v in pairs(xmlspchar) do
		str = str:gsub(k,v)
	end
	return str
end
--解码 内部XMLParse属性的特殊字符串
function string.parseXml(str)
	for k,v in pairs(xmlspchar) do
		str = str:gsub(v,k)
	end
	return str:gsub("&#037;",'%%')
end
