--[[
 *	数字成长特效
 *	@author gwj
]]
local NumberEffect = {}

function NumberEffect.extend(object)
	object.targetValue = 0 --最终结果
    object.isNotEffect = false --不播放动画
    function object:closeEffect()
        self.isNotEffect = true
    end

    function object:setNumer(value,time,speed,sound)
    	if type(value) ~= "number" then
    		print("NumberEffect value is not number")
    		return
    	end
        if self.number_action then
            self:stopAllActions()
            self:setFormatNumber(self.targetValue)
            self.number_action = nil
            self.targetValue = 0
            return
        end
    	self.targetValue = value
    	local currentValue = self:getNumber()
    	if type(value) ~= "number" then
    		currentValue = 0
    		self:setFormatNumber(currentValue)
    	else
    		currentValue = tonumber(currentValue)
    	end
    	if self.targetValue == currentValue then return end
        if self.targetValue < currentValue then
            self:setFormatNumber(self.targetValue)
            return
        end
    	local d_value = self.targetValue - currentValue
    	local time = time or 50
    	local speed = speed or 0.05	--速度
    	local single = math.ceil(d_value/time)
        if sound then
            SoundsManager.playSound(sound)
        end

    	self.number_action = self:runAction(cc.RepeatForever:create(
    		cc.Sequence:create({
				cc.DelayTime:create(speed),
				cc.CallFunc:create(function(sender)
					currentValue = currentValue + single
					if currentValue >= sender.targetValue  then
						currentValue = sender.targetValue
                        self:stopAllActions()
                        self.number_action = nil
                        if sound then
                            SoundsManager.stopAudio(sound)
                        end
					end
					sender:setFormatNumber(currentValue)
				end)
			})))
    end

    function object:stopEffect()
        if self.number_action then
            self:stopAllActions()
            self.number_action = nil
            self:setFormatNumber(self.targetValue)
        end
    end

    function object:setFormatNumber(value)
        self.number = value
        if self.isNotEffect then
            self:setString(self.number)
            return 
        end
        local length = string.len(value)
        if length <= 3 then
            self:setString(value)
        else
            local count = math.floor(length/3)
            local newStr = ""
            local str_array = {}
            local index_1 = length
            for i=1,count do
                table.insert(str_array,","..string.sub(value,index_1 - 2,index_1))
                index_1 = index_1 - 3
            end
            local surplus = length%3
            if surplus > 0 then
                table.insert(str_array,string.sub(value,1,surplus))
            end
            for i=#str_array,1,-1 do
                newStr = newStr .. str_array[i]
            end
            if surplus == 0 then
                newStr = string.sub(newStr,2,-1)
            end
            self:setString(newStr)
        end
    end

    function object:getNumber()
        if self.number then
            return self.number
        else
            return tonumber(self:getString())
        end
    end
    return object
end
return NumberEffect