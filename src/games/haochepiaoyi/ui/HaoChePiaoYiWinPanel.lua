--[[
 *	胜利弹窗
 *	@author gwj
]]
local HaoChePiaoYiWinPanel = class("HaoChePiaoYiWinPanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil
local MULTIPLE_IMG = {
	{multiple = "fcpy_icon_10.png",car = "fcpy_big_car_1.png"},
	{multiple = "fcpy_icon_10.png",car = "fcpy_big_car_2.png"},
	{multiple = "fcpy_icon_10.png",car = "fcpy_big_car_3.png"},
	{multiple = "fcpy_icon_10.png",car = "fcpy_big_car_4.png"},
	{multiple = "fcpy_icon_4.png",car = "fcpy_big_car_1.png"},
	{multiple = "fcpy_icon_3.png",car = "fcpy_big_car_2.png"},
	{multiple = "fcpy_icon_12.png",car = "fcpy_big_car_3.png"},
	{multiple = "fcpy_icon_11.png",car = "fcpy_big_car_4.png"}
}
function HaoChePiaoYiWinPanel:ctor(sid,selfWinMoney,bankerName,bankerWinMoney,datas)
	SoundsManager.playSound("fcpy_win")
	--播放光
	local guang_image = display.newImage("fcpy_result_guang.png")
	Coord.ingap(self,guang_image,"CC",0,"CC",0)
	guang_image:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,35)))
	guang_image:setScale(5)
	self:addChild(guang_image,0)
	self.bg_layout = nil

	local data = MULTIPLE_IMG[sid]

	local function createBackground()
		--背景
		local bg_img = display.newImage("fcpy_result_win_bg.png")
		local layout_size = cc.size(bg_img:getContentSize().width*2,bg_img:getContentSize().height*2)
		--背景层
		local bg_layout = display.newLayout(layout_size)
		bg_layout:setAnchorPoint(cc.p(0.5,0.5))
		bg_layout:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2 + 50))
		bg_img:setScale(2)
		bg_img:setPosition(cc.p(layout_size.width/2,layout_size.height/2))
		bg_layout:addChild(bg_img)
		self:addChild(bg_layout,0)
		bg_layout:setScale(0.1)
		self.bg_layout = bg_layout
		self.bg_layout:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.5,1)))
	end

	local function createTitle()
		local title_image = display.newImage("fcpy_result_title.png")
		title_image:setPosition(cc.p(440,558))
		title_image:setScale(0)
		self.bg_layout:addChild(title_image)
		title_image:runAction(cc.EaseBackOut:create(cc.ScaleTo:create(0.5,1)))
	end

	local function createSign()
		local sign_image = display.newImage(data.car)
		sign_image:setPosition(cc.p(210,330))
		sign_image:setScale(1.2)
		self.bg_layout:addChild(sign_image)
		-- sign_image:runAction(cc.Sequence:create({
		-- 	cc.ScaleTo:create(0.25,2),
		-- 	cc.ScaleTo:create(0.25,1.2)
		-- }))
		local multiple_image = display.newImage(data.multiple)
		multiple_image:setPosition(210,290)
		self.bg_layout:addChild(multiple_image)
		multiple_image:runAction(cc.Sequence:create({
			cc.ScaleTo:create(0.25,2),
			cc.ScaleTo:create(0.25,1)
		}))
	end

	local function createStar()
		local star_image = display.newImage("fcpy_result_star.png")
		star_image:setPosition(cc.p(253,375))
		self.bg_layout:addChild(star_image)
		star_image:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,35)))
		star_image:runAction(cc.RepeatForever:create(cc.Sequence:create({
			cc.FadeTo:create(1,20),
			cc.FadeIn:create(1)
		})))
	end

	local function createSelf()
		local self_icon_image = display.newImage("fcpy_icon_44.png")
		self_icon_image:setPosition(cc.p(90,202))
		self.bg_layout:addChild(self_icon_image)

		local self_name_label = display.newText(Player.name,24,Color.GWJ_IIII)
		self_name_label:setPosition(cc.p(251,200))
		self.bg_layout:addChild(self_name_label)

		local self_result_image = display.newImage("fcpy_icon_46.png")
		self_result_image:setPosition(cc.p(251,150))
		self.bg_layout:addChild(self_result_image)

		local self_value_label = display.newText(selfWinMoney,24,Color.GWJ_IIII)
		self_value_label:setPosition(cc.p(251,93))
		self.bg_layout:addChild(self_value_label)
	end

	local function createZhuang()
		local zhuang_icon_image = display.newImage("fcpy_icon_39.png")
		zhuang_icon_image:setPosition(cc.p(477,201))
		self.bg_layout:addChild(zhuang_icon_image)

		local zhuang_name_label = display.newText(bankerName,24,Color.GWJ_IIII)
		zhuang_name_label:setPosition(cc.p(641,200))
		self.bg_layout:addChild(zhuang_name_label)

		local zhuang_icon_str = "fcpy_icon_46.png"

		if bankerWinMoney < 0 then
			zhuang_icon_str = "fcpy_icon_47.png"
		end

		local zhuang_result_image = display.newImage(zhuang_icon_str)
		zhuang_result_image:setPosition(cc.p(641,150))
		self.bg_layout:addChild(zhuang_result_image)

		local zhuang_value_label = display.newText(math.abs(bankerWinMoney),24,Color.GWJ_IIII)
		zhuang_value_label:setPosition(cc.p(641,93))
		self.bg_layout:addChild(zhuang_value_label)
	end

	local function createItem(index,name,value)
		local item = display.newLayout(cc.size(450,40))
		local index_label = nil
		if index == 1 then
			index_label = display.newImage("fcpy_icon_32.png")
			index_label:setScale(0.8)
		elseif index == 2 then
			index_label = display.newImage("fcpy_icon_33.png")
			index_label:setScale(0.8)
		elseif index == 3 then
			index_label = display.newImage("fcpy_icon_34.png")
			index_label:setScale(0.8)
		else
			index_label = display.newText(index,24,Color.GWJ_FFF)
		end
		item:addChild(index_label)
		index_label:setPosition(cc.p(17,20))
		local name_label = display.newText(name,24,Color.GWJ_FFF)
		item:addChild(name_label)
		name_label:setAnchorPoint(cc.p(0,0.5))
		name_label:setPosition(cc.p(49,20))
		local value_label = display.newText(value,24,Color.GWJ_FFF)
		item:addChild(value_label)
		value_label:setAnchorPoint(cc.p(1,0.5))
		value_label:setPosition(cc.p(445,20))
		return item
	end

	local function createList()
		for i=1,#datas do
			local item = createItem(i,datas[i].name,datas[i].userResultMoney)
			item:setPosition(373,418 - (i - 1)*46.5)
			self.bg_layout:addChild(item)
		end
	end


	self:runAction(cc.Sequence:create({
		cc.CallFunc:create(createBackground),
		cc.DelayTime:create(0.3),
		cc.CallFunc:create(createTitle),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(createSign),
		cc.DelayTime:create(0.5),
		cc.CallFunc:create(function()
			createStar()
			createSelf()
		end),
		cc.DelayTime:create(0.2),
		cc.CallFunc:create(createZhuang),
		cc.DelayTime:create(0.2),
		cc.CallFunc:create(createList),
		cc.DelayTime:create(5),
		cc.CallFunc:create(function()
			self:removeFromParent(true)
			instance = nil
		end)
	}))
end

function HaoChePiaoYiWinPanel.show(sid,selfWinMoney,bankerName,bankerWinMoney,datas)
	if instance == nil then
		instance = HaoChePiaoYiWinPanel.new(sid,selfWinMoney,bankerName,bankerWinMoney,datas)
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return HaoChePiaoYiWinPanel
