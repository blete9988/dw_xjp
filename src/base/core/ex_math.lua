--[[
*	math扩展
*	添加所有的位操作方法
]]


--四舍五入
function math.round(num)
	return math.floor(num + 0.5)
end
--与运算
function math.band(n1,n2)
	return bitUtils.bitand(n1,n2)
end
--或运算
function math.bor(n1,n2)
	return bitUtils.bitor(n1,n2)
end
--异或运算
function math.bxor(n1,n2)
	return bitUtils.bitxor(n1,n2)
end
--非运算
function math.bnot(n)
	return bitUtils.bitnot(n)
end
--左移运算
function math.bls(n,b)
	return bitUtils.leftshift(n,b)
end
--右移运算
function math.brs(n,b)
	return bitUtils.rightshift(n,b)
end