
Gbv.Command={}
--根据名称返回SpriteFrame
function Command.getSpriteFrameByName(name)
	local pFrame = cc.SpriteFrameCache:getInstance():spriteFrameByName(name)
	return pFrame
end

--创建json node
function Command.createNodeByjsonName(name)
	local jsonUrl=Command.uijson[name]
	if jsonUrl then
		local json=ccs.GUIReader:getInstance():widgetFromJsonFile(jsonUrl)
		UILayerExtend.extend(json)
		return json
	end
end

function Command.max(num1,num2)
	if num1>num2 then
		return num1
	else
		return num2
	end
end

function Command.min(num1,num2)
	if num1<num2 then
		return num1
	else
		return num2
	end
end

--上次计算的时间
Command.lastTime=0
function Command.random(rannum)
	local ostime=os.time()
	if Command.lastTime~=ostime then
		math.randomseed(ostime)
	end
	Command.lastTime=ostime
	local romNum=math.random(rannum)
	return romNum
end

--随机几率
function Command.probability(percent)
	if not percent then return false end
	local temp=Command.random(10000)
	if temp<percent*100 or temp==percent*100 then
		return true
	end
	return false
end

--取n个数的随机
function Command.getRandomNumber(value)
	local baselist={}
	for i=1,value do
		table.insert(baselist,i)
	end

	local numberlist={}
	for i=1,value do
		local number=Command.random(#baselist)
		table.insert(numberlist,baselist[number])
		table.remove(baselist,number)
	end
	return numberlist
end

--[[
	检查两个坐标是否相等
]]
function Command.checkPoint(point1,point2)
	if point1.x==point2.x and point1.y==point2.y then
		return true
	end
	return false
end

--[[
连接table
]]
function Command.connectTable(table1,table2)
	for k,v in pairs(table2) do
		table.insert(table1,v)
	end
end

--根据属性名称和值
function Command.getTableByTname(datas,tname,value)
	for k,v in pairs(datas) do
		if v[tname]==value then
			return v
		end
	end
end

function Command.performWithDelay(host,backfunction,delay)
	local action = cc.Sequence:create({
        cc.DelayTime:create(delay),
        cc.CallFunc:create(backfunction)
    })
    host:runAction(action)
    return action
end

--[[
	获取动画播放时间
]]	
function Command.getAnimationDuration(key)
	if not key then return end
	local animCache = CCAnimationCache:sharedAnimationCache()
	local animation=animCache:animationByName(key)
	--如果key发生错误
	if not animation then
		print("getAnimationDuration is key Does not exist key:"..key)
		return nil
	end
	return animation:getDuration()
end

--[[
	分隔字符串
	szFullString 字符串
	szSeparator 分隔符
]]
function Command.Split(szFullString, szSeparator)
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
	   local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
	   if not nFindLastIndex then  
		nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))  
		break  
	   end  
	   nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)  
	   nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
	   nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end

--lua代理
function Command.gameProxy(code,value,backfunction)
	if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID  then
		local luaj=require("luaj")
		luaj.callStaticMethod(
				"org.cocos2dx.lua.JniHelperManager",
				"gameProxy",
				{code,value,backfunction},
				"(Ljava/lang/String;Ljava/lang/String;)V"
			)
    else
        Cashier:getInstance():gameProxy(code,value,backfunction)
	end
end

function Command.IsPtInPoly(pt, pts)
    local count  = 0
    local x, y   = pt.x, pt.y
    local x1, y1 = pts[1].x, pts[1].y
    local x1Part = (y1 > y) or ((x1 - x > 0) and (y1 == y))
    local x2, y2
    for i = 1, #pts do
        local point  = pts[i]
        local x2, y2 = point.x, point.y
        local x2Part = (y2 > y) or ((x2 > x) and (y2 == y))
        if x2Part == x1Part then
            x1, y1 = x2, y2
        else
            local mul = (x1 - x)*(y2 - y) - (x2 - x)*(y1 - y)
            if mul > 0 then
                count = count + 1
            elseif mul < 0 then
                count = count - 1
            end
            x1, y1 = x2, y2
            x1Part = x2Part
        end
    end
    if count == 2 or count == -2 then
        return true
    end
    return false
end
