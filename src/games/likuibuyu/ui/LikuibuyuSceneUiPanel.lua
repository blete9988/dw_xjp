local LikuibuyuUiPanel = class("LikuibuyuUiPanel",function()
	local layout = display.extend("CCLayerExtend",display.newLayout())
	layout:setContentSize(cc.size(D_SIZE.width,D_SIZE.height))
	return layout
end,require("src.base.event.EventDispatch"))

function LikuibuyuUiPanel:ctor()
	local game_bg = display.newImage("#game/likuibuyu/game_bg_0.png")
	game_bg:setAnchorPoint(cc.p(0,0))
	self:addChild(game_bg)
	self.game_bg = game_bg

    --底栏菜单栏
    local menuBG = display.newImage("#game/likuibuyu/game_buttom.png")
    menuBG:setAnchorPoint(0.5,0.0)
    menuBG:setScaleY(0.9)
    -- menuBG:setPosition(667, -6)
    self:addChild(Coord.ingap(self,menuBG,"CC",0,"BB",0),109,20)
    self.menuBG = menuBG

end

return LikuibuyuUiPanel