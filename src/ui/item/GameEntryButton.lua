--[[
*	进入游戏按钮
*	@author：lqh
]]
local GameEntryButton = class("GameEntryButton",require("src.base.extend.CCLayerExtend"),IEventListener,function() 
	local layer = display.newLayout(cc.size(210,210))
	layer:setAnchorPoint( cc.p(0.5,0.5) )
	layer:setScale(1.05)
	layer:setTouchEnabled(true)
	return layer
end)

function GameEntryButton:ctor(data)
	self:super("ctor")
	display.extendButtonToSound(self)
	self:addEvent(ST.COMMAND_GAME_DOWNLOAD)
--	display.debugLayout(self)
	local bg =  display.newImage(data.background)
	self:addChild(Coord.ingap(self,bg,"CC",0,"CC",0))
	
	local effect1 = display.newSprite("p_ui_bg_effect_1.png")
	bg:addChild(Coord.ingap(bg,effect1,"CC",0,"CC",0))
	effect1:setScale(1.1)
	effect1:setOpacity(0)
	effect1:runAction(cc.Sequence:create({
		cc.DelayTime:create(math.random()*2),
		cc.CallFunc:create(function(t) 
			if not t then return end
			effect1:runAction(cc.RepeatForever:create(cc.Sequence:create({
				cc.FadeIn:create(0.5),
				cc.Spawn:create({
					cc.ScaleTo:create(4,0),
					cc.FadeOut:create(4)
				}),
				cc.DelayTime:create(1),
				cc.CallFunc:create(function(t) 
					if not t then return end
					effect1:setScale(1.05)
				end),
			})))
		end)
	}))
	
	local effect2 = display.newSprite("p_ui_bg_effect_2.png")
	bg:addChild(Coord.ingap(bg,effect2,"CC",0,"CC",0))
	local angle = math.random(0,360)
	effect2:setRotation(angle)
	effect2:runAction(cc.RepeatForever:create(cc.Sequence:create({
		cc.RotateTo:create(5,(angle + 180)),
		cc.RotateTo:create(5,(angle + 360)),
	})))
	
	local namepanel = display.newImage(data.namepanel)
	bg:addChild(Coord.ingap(bg,namepanel,"CC",0,"BB",15))
	
	local namepic = display.newImage(data.namepic)
	bg:addChild(Coord.outgap(namepanel,namepic,"CC",0,"CC",0))
	
	local icon = display.newImage(data.icon)
	bg:addChild(Coord.outgap(namepanel,icon,"CC",0,"TB",0))
	
	self:addTouchEventListener(function(t,e) 
		if e == ccui.TouchEventType.began then 
			self:setScale(1.15)
		elseif e == ccui.TouchEventType.canceled then 
			self:setScale(1.1)
		elseif e == ccui.TouchEventType.ended then 
			self:setScale(1.1)
			if self.m_data:isdownload() then
				ConnectMgr.connect("gamehall.GameRoomConnect" , self.m_data,function(result) 
					if result ~= 0 then return end
					display.showWindow("src.ui.window.room.RoomWindows",self.m_data)
					Player.setGameSid(self.m_data.sid)
				end)
			else

				if Player.gameMgr.on_downloadGame then
					display.showMsg(display.trans("##2037",Player.gameMgr.on_downloadGame.name))
					return 
				end

				--开始下载
				self:setTouchEnabled(false)
				local loadbar = display.newProgress("p_ui_1007.png")
				loadbar:setDirection(2)
				loadbar:setPercent(0)
				bg:addChild(Coord.outgap(namepanel,loadbar,"CC",0,"CC",0))
				
				local gameimgs = {}
				gameimgs.bg = bg
				gameimgs.icon = icon
				self.m_data.gameimgs = gameimgs
				local txt = display.newRichText(display.trans("##2008",0),30,cc.c3b(0xe9,0xd4,0x5f))
				txt:enableOutline(cc.c4b(0,0,0,255),2)
				bg:addChild(Coord.outgap(namepanel,txt,"CC",0,"CC",0))
				self.m_loadbar = loadbar
				self.m_txt = txt
				Player.gameMgr:downloadResrouce(self.m_data)
			end
		end		
	end)
	
	
	local values = string.splitNumber(require("src.base.tools.storage").getXML("gamedownload_type"))
	local isXZ = false --是否已经下载
	for i,v in ipairs(values) do
		if(tonumber(data.sid) == tonumber(v))then
			isXZ = true
			break
		end
	end
	if(not isXZ)then
		mlog(data.sid,"sid")
		-- self:SpriteSetGray(bg)
		require("src.base.tools.openglTools").setGray(bg)
		require("src.base.tools.openglTools").setGray(icon)
	end
	self.m_data = data

end

function GameEntryButton:SpriteSetGray(sprite)
    if sprite then
        if GrayProgram == nil then
            local program = cc.GLProgram:create("res/gray.vsh", "res/gray.fsh")
            program:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION) 
            program:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
            program:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)
            program:link()
            program:updateUniforms()
GrayProgram = program
        end
        sprite:setGLProgram(GrayProgram)
    end
end

--@override
function GameEntryButton:handlerEvent(event,arg)
	if self.m_data ~= arg.data then return end
		
	if arg.type == 1 then
		self.m_txt:setString(display.trans("##2008",arg.progress))
		self.m_loadbar:setPercent(1 - arg.progress/100)
		if not arg.progress then
			self.m_txt:setString(display.trans("##2009"))
		end
	else
		self:setTouchEnabled(true)
		self.m_loadbar:removeFromParent(true)
		self.m_txt:removeFromParent(true)
		self.m_loadbar,self.m_txt = nil
		if arg.type == 2 then
			display.showMsg(display.trans("##2010"))
		end
	end
end
function GameEntryButton:onCleanup()
	self:removeAllEvent()
end

return GameEntryButton