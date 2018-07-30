--[[
 *	数字飘扬特效
 *	@author gwj
]]
local NumberFly = {}

function NumberFly.extend(object)
    function object:showFlyNumber(value,position,color,size)
    	if type(value) ~= "number" then
    		print("NumberEffect value is not number")
    		return
    	end
        print("value--------------------------------",value)
        if value == 0 then
            return
        end
        local symbols = "+"
        if value < 0 then
            symbols = "-"
        end
        local fly_label = display.newText(symbols..value,size,color)
        fly_label:setPosition(position)
        self:addChild(fly_label,99)
        fly_label:runAction(cc.FadeOut:create(2))
        fly_label:runAction(cc.Sequence:create({
            cc.EaseBackOut:create(cc.MoveTo:create(2,cc.p(fly_label:getPositionX(),fly_label:getPositionY() + 50))),
            cc.CallFunc:create(function(sender)
                sender:removeFromParent(true)
            end)}))
    end
    return object
end
return NumberFly