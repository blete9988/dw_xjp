
--通用base64加密串
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
--[[
*	base64编码
*	@author lqh
]]
local base64 = {}
--[[
*	加密
*	@param source_str 数据源
*	@param key 密钥(可省略)
]]
function base64.encode(source_str,key)
	key = key or b64chars
	local s64 = ''
	local len = source_str:len()
	for i = 1,len,3 do
		local bufer = 0
		for k = 0,2 do
			--位移操作
			bufer = bufer * 256
			if i + k <= len then
				bufer = bufer + source_str:byte(i + k)
			end
		end
		local code,point = ""
		for n = 1,4 do
			point = bufer%64
			if point < 1 then
				code = "=" .. code
			else
				code = key:sub(point + 1,point + 1) .. code
			end
			--位移操作
			bufer = math.floor(bufer/64)
		end
		s64 = s64 .. code
	end

	return s64
end
--[[
*	解密
*	@param str64 数据源
*	@param key 密钥(可省略)
]]
function base64.decode(str64,key)
	if str64:len()%4 ~= 0 then return "error base64 code" end
	key = key or b64chars
	local str = ""

	local dic = {['='] = 0}
	for i = 1,64 do
		dic[key:sub(i,i)] = i - 1
	end

	for i = 1,str64:len(),4 do
		local bufer = 0
		for k = 0,3 do
			--位移操作
			bufer = bufer * 64 + dic[str64:sub(i + k,i + k)]
		end
		local code,point = ""
		for n = 1,3 do
			point = bufer%256
			if point ~= 0 then
				code = string.char(point) .. code
			end
			--位移操作
			bufer = math.floor(bufer/256)
		end
		str = str .. code
	end

	return str
end

Gbv.base64 = base64

return base64