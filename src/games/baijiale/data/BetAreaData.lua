--[[
*	桌面下注区域 配置
*	@author lqh
]]

local BetAreaData = class("BetAreaData")

local XTest = require("src.base.tools.XTest")
local randomInTriangle

function BetAreaData:ctor(config)
	for k,v in pairs(config) do
		self[k] = v
	end
	self.toucharea = json:decode(config.toucharea)
	--未转换到屏幕的坐标
	self.betarea = json:decode(config.betarea)
	self.pos = json:decode(config.pos)
	self.txtpos = json:decode(config.txtpos)
end
function BetAreaData:transCoord(target)
	for i = 1,#self.betarea do
		self.betarea[i] = target:convertToWorldSpace(self.betarea[i])
	end
	for i = 1,#self.toucharea do
		self.toucharea[i] = target:convertToWorldSpace(self.toucharea[i])
	end
--	self.pos = target:convertToNodeSpace(self.pos)
end
--点是否在触摸区域内
function BetAreaData:isIntouchArea(point)
	return XTest.pXd(self.toucharea,point)
end
--在下注区域获取一个点
function BetAreaData:getBetPosition()
	return {
		x = math.random(self.betarea[1].x,self.betarea[2].x),
		y = math.random(self.betarea[1].y,self.betarea[2].y),
	}
end

--@static
function BetAreaData.getAllData()
	local cfs = require("src.games.baijiale.app.betarea_config")
	local list = {}
	for i = 1,#cfs do
		list[i] = BetAreaData.new(cfs[i])
	end
	return list
end
return BetAreaData