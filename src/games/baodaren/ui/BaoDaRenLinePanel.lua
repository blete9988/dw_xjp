--[[
 *	连线层
 *	@author gwj
]]
local BaoDaRenLinePanel = class("BaoDaRenLinePanel",function() 
	local layout = display.extend("CCLayerExtend",display.newLayout())
	return layout
end,require("src.base.event.EventDispatch"))

function BaoDaRenLinePanel:ctor(lineList)
	self:setContentSize(cc.size(966,580))
	self.items = {}
	local length = #lineList
	for i=1,length do
		local item = display.newDynamicImage("game/baodaren/line/FS_Line_"..lineList[i]..".png")
		item:setAnchorPoint(cc.p(0,0))
		self:addChild(item)
		table.insert(self.items,item)
	end
end

--轮流显示
function BaoDaRenLinePanel:takeTurns()
	local length = #self.items
	for i=1,length do
		self.items[i]:setVisible(false)
	end
	local index = 0
	local time_action = self:schedule(function()
		if index <= length then
			index = index+1
			self.items[index]:setVisible(true)
			self.items[index]:runAction(cc.Sequence:create({
				cc.DelayTime:create(0.5),
				cc.CallFunc:create(function(sender)
					sender:setVisible(false)
				end)}))
		else
			self:stopAction(time_action)
		end
	end,0.5)

end

return BaoDaRenLinePanel
