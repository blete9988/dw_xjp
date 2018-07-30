--[[
*	进入游戏按钮
*	@author：lqh
]]
local ScreenScrollMsg = class("ScreenScrollMsg",require("src.base.extend.CCLayerExtend"),IEventListener,function() 
	local layer = display.newLayout(cc.size(730,45))
	layer:setAnchorPoint( cc.p(0.5,0.5) )
	layer:setClippingEnabled(true)
	return layer
end)

local speed = 100

function ScreenScrollMsg:ctor(data)
	self:super("ctor")
	self:addEvent(ST.COMMAND_GAME_SCROLL_MSG)
	
	local bg = display.newImage("p_ui_1066.png")
	bg:setScale(1.217)
	self:addChild(Coord.ingap(self,bg,"CC",0,"CC",0,true))
	self:setVisible(false)
	--等待播放的消息
	self.waitingMsg = {}
	--正在播放的消息
	self.runningMsg = {}
	self.count = 0
	
	self:init()
end
function ScreenScrollMsg:init()
	self.waitingMsg = Player.msgMgr:getMsgList()
	self:check()
end
function ScreenScrollMsg:addMsg(msglist)
	for i = 1,#msglist do
		table.insert(self.waitingMsg,msglist[i])
	end
	
	if #self.runningMsg == 0 then
		self:check()
	end
end
function ScreenScrollMsg:check()
	if #self.waitingMsg > 0 then
		self:showMsg(table.remove(self.waitingMsg,1))
	end
end
function ScreenScrollMsg:showMsg(msg)
	self:setVisible(true)
	table.insert(self.runningMsg,msg)
	
	self.count = self.count + 1
	local txt = display.newRichText(msg.txt,28)
	txt:setAnchorPoint( cc.p(0,0.5) )
	txt:setPosition( cc.p(730 + 200,25) )
	txt.data = msg
	self:addChild(txt)
	
	local width = txt:getContentSize().width
	
	txt:runAction(cc.Sequence:create({
		cc.MoveTo:create((width + 200)/speed,cc.p(730 - width,25)),
		cc.CallFunc:create(function(t) 
			if not t then return end
			table.remove(self.runningMsg,1)
			Player.msgMgr:removeMsg(t.data)
			self:check()
		end),
		cc.MoveTo:create((730 + 15)/speed,cc.p(-width - 15,25)),
		cc.CallFunc:create(function(t) 
			if not t then return end
			self.count = self.count - 1
			if self.count < 1 then
				self:setVisible(false)
			end
		end),
	}))
end
--@override
function ScreenScrollMsg:handlerEvent(event,arg)
	if event == ST.COMMAND_GAME_SCROLL_MSG then
		self:addMsg(arg)
	end
end

function ScreenScrollMsg:onCleanup()
	self:removeAllEvent()
end

function ScreenScrollMsg.show(targetScene,pos,order)
	local pos = pos or cc.p(D_SIZE.hw,D_SIZE.top(150))
	local order = order or 20
	
	local item = ScreenScrollMsg.new()
	item:setPosition( pos )
	item:setLocalZOrder(order)
	targetScene:addChild(item)
end

return ScreenScrollMsg