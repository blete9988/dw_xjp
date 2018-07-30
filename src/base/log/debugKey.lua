return function() 
	--debug工具开启钥匙
	local debugKey = display.newLayout(cc.size(100,100))
	debugKey:setTouchEnabled(true)
	debugKey:addTouchEventListener(function(t,e) 
		if e ~= ccui.TouchEventType.ended then return end
		if Cfg.DEBUG_TAG then return end
		if not debugKey.m_stamp or os.millis() - debugKey.m_stamp > 2000 then 
			debugKey.m_stamp = os.millis() 
			debugKey.m_count = 0
		end
		debugKey.m_count = debugKey.m_count + 1
		if debugKey.m_count >= 5 then
			if os.millis() - debugKey.m_stamp <= 2000 then
				Cfg.DEBUG_TAG = true
				require("src.base.log.logUI").showdebug(display.getRunningScene())
			end
			debugKey.m_stamp,debugKey.m_count = nil
		end
	end)
	
	return debugKey
end