--[[
 *	得奖弹窗
 *	@author gwj
]]
local FireRewardPanel = class("FireRewardPanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil
function FireRewardPanel:ctor(value,overfunction)
	self.overfunction = overfunction
	SoundsManager.stopAllSounds()
	SoundsManager.playSound("firecrack_free_over")
	local main_layout = display.newImage("#game/firecracker/firecracker_reward.png")
	local main_size = main_layout:getContentSize()
	self:addChild(main_layout)
	main_layout:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
	self.main_layout = main_layout
	print("value-----------------------",value)
	local score_label = ccui.TextAtlas:create(value,"game/firecracker/fontnumber_27X37.png",27,37,0)
	score_label:setPosition(cc.p(255,83))
	self.main_layout:addChild(score_label)
	self:setTouchEnabled(true)
	self.score_label = score_label
	self:setTimeOver(3)
	-- self:addTouchEventListener(function(sender,eventype)
	--     if eventype ~= ccui.TouchEventType.ended then
	-- 		self.main_layout:runAction(cc.Sequence:create({
	-- 			cc.MoveTo:create(0.2,cc.p(D_SIZE.width/2,D_SIZE.height + main_size.height/2)),
	-- 			cc.CallFunc:create(function()
	-- 				if self.overfunction then
	-- 					self.overfunction()
	-- 				end
	-- 				instance = nil
	-- 				self:removeFromParent(true)
	-- 			end)
	-- 		}))
	    	
 --        end
 --    end)
end

function FireRewardPanel:setTimeOver(delay)
	self:performWithDelay(function()
		if self.overfunction then
			self.overfunction()
		end
    	self:destroy()
	end,delay)
end

function FireRewardPanel:destroy()
	self:removeFromParent(true)
	instance = nil
end

function FireRewardPanel.show(value,overfunction)
	if instance == nil then
		instance = FireRewardPanel.new(value,overfunction)
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return FireRewardPanel
