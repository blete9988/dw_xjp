--[[
 *	得奖弹窗
 *	@author gwj
]]
local FeiQingZouShouResultPanel = class("FeiQingZouShouResultPanel",function() 
	local layout = display.extend("CCLayerExtend",display.newMask(cc.size(D_SIZE.width,D_SIZE.height)))
	return layout
end)
local instance = nil

local function createItem(index,name,value)
	local item = display.newLayout(cc.size(600,30))
	local index_label = display.newText(index,24,Color.GWJ_III)
	item:addChild(index_label)
	index_label:setPosition(cc.p(30,15))
	local name_label = display.newText(name,24,Color.GWJ_III)
	item:addChild(name_label)
	name_label:setPosition(cc.p(310,15))
	local value_label = display.newText(value,24,Color.GWJ_III)
	item:addChild(value_label)
	value_label:setPosition(cc.p(590,15))
	return item
end

function FeiQingZouShouResultPanel:ctor(self_isBet,animalSid,bankerResultMoney,bankerName,self_winMoney,userdatas,overfunction)
	local data = require("src.games.feiqingzoushou.data.FeiQingZouShou_element_data").new(animalSid)
	self.overfunction = overfunction
	self.self_winMoney = self_winMoney
	local function showBg()
		if self.self_winMoney > 0  then
			local guang_image = display.newImage("fqzs_goldshark_icon_5.png")
			Coord.ingap(self,guang_image,"CC",0,"CC",0)
			guang_image:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,35)))
			guang_image:setScale(2)
			self:addChild(guang_image,0)
		end
		--背景
		local bg_img = display.newImage("#game/feiqingzoushou/fqzs_result_bg.png")
		local layout_size = cc.size(bg_img:getContentSize().width*2,bg_img:getContentSize().height*2)
		--背景层
		local bg_layout = display.newLayout(layout_size)
		bg_layout:setAnchorPoint(cc.p(0.5,0.5))
		bg_layout:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2 + 50))
		bg_img:setScale(2)
		bg_img:setPosition(cc.p(layout_size.width/2,layout_size.height/2))
		bg_layout:addChild(bg_img)
		self:addChild(bg_layout,0)
		self.bg_layout = bg_layout

		local tit_img = display.newImage("fqzs_icon_6.png")
		self.bg_layout:addChild(tit_img)
		Coord.ingap(bg_layout,tit_img,"CC",0,"TT",0)
		--本轮开奖
		local runLottery_title = display.newText("本轮开奖:",24,Color.GWJ_IIII)
		self.bg_layout:addChild(runLottery_title)
		Coord.ingap(bg_layout,runLottery_title,"LL",180,"TB",-140)
		--自己的情况
		local self_layout = display.newImage("fqzs_icon_8.png")
		display.setS9(self_layout,cc.rect(5,5,5,5),cc.size(370,170))
		Coord.ingap(bg_layout,self_layout,"LL",60,"TT",-170)
		self.bg_layout:addChild(self_layout)
		local self_icon = display.newImage("fqzs_icon_9.png")
		Coord.ingap(self_layout,self_icon,"LL",10,"TT",-10)
		self_layout:addChild(self_icon)
		local self_name_label = display.newText(Player.name,24,Color.GWJ_IIII)
		Coord.ingap(self_layout,self_name_label,"CC",0,"TT",-15)
		self_layout:addChild(self_name_label)
		if not self_isBet then  --未下注
			local weixiazhu_icon = display.newImage("fqzs_icon_12.png")
			Coord.ingap(self_layout,weixiazhu_icon,"CC",0,"CC",-20)
			self_layout:addChild(weixiazhu_icon)
		else
			local self_win_icon = nil
			if self.self_winMoney > 0  then
				self_win_icon = display.newImage("fqzs_icon_11.png")
				SoundsManager.playSound("fqzs_element_10")
			else
				self_win_icon = display.newImage("fqzs_icon_10.png")
			end
			Coord.ingap(self_layout,self_win_icon,"CC",0,"CC",5)
			self_layout:addChild(self_win_icon)
			local self_number_label = ccui.TextAtlas:create(self.self_winMoney,"game/feiqingzoushou/fqzs-number-24-34.png",24,34,0)
		    Coord.ingap(self_layout,self_number_label,"CC",0,"CC",-50)
		    self_layout:addChild(self_number_label)
		end
		--庄家的情况
		local zhuangjia_layout = display.newImage("fqzs_icon_7.png")
		display.setS9(zhuangjia_layout,cc.rect(5,5,5,5),cc.size(370,170))
		Coord.ingap(bg_layout,zhuangjia_layout,"RR",-60,"TT",-170)
		self.bg_layout:addChild(zhuangjia_layout)
		local zhuang_icon = display.newImage("fqzs_icon_1.png")
		Coord.ingap(zhuangjia_layout,zhuang_icon,"LL",10,"TT",-5)
		zhuangjia_layout:addChild(zhuang_icon)
		local zhuang_label = display.newText(bankerName,24,Color.GWJ_IIII)
		Coord.ingap(zhuangjia_layout,zhuang_label,"CC",0,"TT",-15)
		zhuangjia_layout:addChild(zhuang_label)
		local zhuang_win_icon = nil
		if bankerResultMoney > 0 then
			zhuang_win_icon = display.newImage("fqzs_icon_11.png")
		else
			zhuang_win_icon = display.newImage("fqzs_icon_10.png")
		end
		Coord.ingap(zhuangjia_layout,zhuang_win_icon,"CC",0,"CC",5)
		zhuangjia_layout:addChild(zhuang_win_icon)
		local zhuang_number_label = ccui.TextAtlas:create(bankerResultMoney,"game/feiqingzoushou/fqzs-number-24-34.png",24,34,0)
	    Coord.ingap(zhuangjia_layout,zhuang_number_label,"CC",0,"CC",-50)
	    zhuangjia_layout:addChild(zhuang_number_label)

		for i=1,#userdatas do
			local data = userdatas[i]
			local item = createItem(i,data.name,data.userResultMoney)
			item:setPosition(100,220 - (i - 1)*36.5)
			self.bg_layout:addChild(item)
		end
		self:schedule(function()
			if self.overfunction then
				self.overfunction()
			end
			self:removeFromParent(true)
			instance = nil
		end,5)
	end
	local function showGoldShark()
		local shark_layout = display.newLayout(cc.size(D_SIZE.width,D_SIZE.height))
		self:addChild(shark_layout)
		display.extend("CCNodeExtend",shark_layout)
		local guang_image = display.newImage("fqzs_goldshark_icon_5.png")
		Coord.ingap(shark_layout,guang_image,"CC",0,"CC",0)
		guang_image:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5,35)))
		guang_image:setScale(2)
		shark_layout:addChild(guang_image,0)

		local jinquan_image = display.newImage("fqzs_goldshark_icon_1.png")
		Coord.ingap(shark_layout,jinquan_image,"CC",0,"CC",0)
		shark_layout:addChild(jinquan_image,1)

		local goldShark_sprite = display.newSprite()
		goldShark_sprite:setPosition(cc.p(689,463))
		goldShark_sprite:setScale(2)
		goldShark_sprite:runAction(resource.getAnimateByKey(data.animation,true))
		shark_layout:addChild(goldShark_sprite,2)

		local goldShark_font_image = display.newImage("fqzs_goldshark_icon_4.png")
		goldShark_font_image:setPosition(cc.p(680,317))
		shark_layout:addChild(goldShark_font_image,2)
		local goldShark_yaodai_image = display.newImage("fqzs_goldshark_icon_3.png")
		goldShark_yaodai_image:setPosition(cc.p(680,239))
		shark_layout:addChild(goldShark_yaodai_image,2)
		local goldShark_font_sprite = display.newSprite()
		goldShark_font_sprite:setPosition(cc.p(673,321))
		goldShark_font_sprite:runAction(resource.getAnimateByKey("fqzs_wenzi_jinsha",true))
		shark_layout:addChild(goldShark_font_sprite,3)
		local star_points = {cc.p(533,533),cc.p(757,430),cc.p(849,562),cc.p(757,348)}
		for i=1,#star_points do
			local star_image = display.newImage("fqzs_goldshark_icon_2.png")
			star_image:setPosition(cc.p(star_points[i]))
			shark_layout:addChild(star_image,4)
			star_image:runAction(cc.RepeatForever:create(cc.Sequence:create({
				cc.DelayTime:create(math.random(1,10)/10),
				cc.FadeTo:create(1,20),
				cc.FadeIn:create(1)
			})))
		end
		local temp = 0
		shark_layout:schedule(function()
			temp = temp + 1
			if temp > 40 then
				return
			end
			for i=1,1 do
				local gold_sprite = display.newSprite()
				local bx = math.random(300,1100)
				local by = 845
				gold_sprite:setPosition(cc.p(bx,by))
				gold_sprite:runAction(resource.getAnimateByKey("fqzs_gold",true))
				gold_sprite:runAction(cc.MoveTo:create(3,cc.p(bx,-70)))
				shark_layout:addChild(gold_sprite,5)
			end
		end,0.05)

		shark_layout:runAction(cc.Sequence:create({
			cc.DelayTime:create(5),
			cc.CallFunc:create(function(sender)
				sender:stopAllActions()
				showBg()
				local goldshark_image = display.newImage("fqzs_goldshark_01.png")
				goldshark_image:setPosition(cc.p(goldShark_sprite:getPositionX(),goldShark_sprite:getPositionY()))
				sender:getParent():addChild(goldshark_image)
				goldshark_image:runAction(cc.MoveTo:create(0.5,cc.p(D_SIZE.width/2 - 120,D_SIZE.height/2 + 225)))
				goldshark_image:runAction(cc.ScaleTo:create(0.5,0.25))
				sender:removeFromParent(true)
			end)
		}))
	end
	local function showNormalAnimal()
		--文字
		local left_font = display.newImage("fqzs-font-"..data.sid..".png")
		self:addChild(left_font,2)
		local right_font = nil
		if data.belong > 0 then
			right_font = display.newImage("fqzs-font-"..data.belong..".png")
			self:addChild(right_font,2)
		end

		local effect_sprite = display.newSprite()
		effect_sprite:setPosition(cc.p(D_SIZE.width/2,D_SIZE.height/2))
		self:addChild(effect_sprite,1)
		effect_sprite:runAction(cc.Sequence:create({
			resource.getAnimateByKey(data.animation,false,false),
			cc.CallFunc:create(function(sender)
				left_font:removeFromParent(true)
				if right_font then
					right_font:removeFromParent(true)
				end
				showBg()
				sender:runAction(cc.MoveTo:create(0.5,cc.p(D_SIZE.width/2 - 120,D_SIZE.height/2 + 225)))
				sender:runAction(cc.ScaleTo:create(0.5,0.25))
			end)
		}))
		if right_font then
			Coord.outgap(effect_sprite,right_font,"RR",0,"BT",-80)
			Coord.outgap(effect_sprite,left_font,"LL",0,"BT",-80)
		else
			Coord.outgap(effect_sprite,left_font,"CC",0,"BT",-80)
		end
	end
	SoundsManager.playSound(data.sound)
	if data.sid == 10 then
		showGoldShark()
	else
		if #data.animation > 0 then
			showNormalAnimal()
		else
			showBg()
		end
	end
end

function FeiQingZouShouResultPanel.show(self_isBet,animalSid,bankerResultMoney,bankerName,self_winMoney,userdatas,overfunction)
	if instance == nil then
		instance = FeiQingZouShouResultPanel.new(self_isBet,animalSid,bankerResultMoney,bankerName,self_winMoney,userdatas,overfunction)
		display.getRunningScene():addChild(instance)
	end
	return instance
end

return FeiQingZouShouResultPanel
