--[[
*	多行文本，可以滚动
*	LabelArea:setString(str,immediately)					设置文字
*	LabelArea:appendText(txt)								添加文字
*	LabelArea:setFontSize(size)								设置默认字体大小（默认全局设置的字体大小）
*	LabelArea:getContentSize()								@override native 获取尺寸
*	LabelArea:setContentSize(size)							@override native 设置尺寸
*	LabelArea:setFontName(name)								设置默认字体名（默认全局设置的系统字体）
*	LabelArea:setFontColor(color)							设置默认字体颜色（默认全局设置的字体颜色）
*	LabelArea:setFontPath(str)								设置字体文件目录（默认res/fonts）
*	LabelArea:setWidth(width)								设置行宽（默认单行无限宽）
*	LabelArea:setEdgeSmoothing(value)						设置是否平滑边缘（默认平滑边缘）
*	LabelArea:setUnderLine(value)							设置超链接是否显示下滑下（默认显示）
*	LabelArea:setLeading(value)								设置行间隔（默认2）
*	LabelArea:setStyle(style)								设置style表
*	LabelArea:setHorType(value)								设置水平对齐方式（默认左对齐）
*	LabelArea:setVerType(value)								设置垂直对齐方式（默认顶部对齐）
*	LabelArea:enableGlow(c4b)								设置外发光
*	LabelArea:enableOutline(c4b,outlinesize)				设置描边
*	LabelArea:enableShadow(c4b,size,blur)					设置阴影
*
*
*	html格式 详细见LabelElement说明
*
*
*	@author：lqh
]]
local LabelArea = class("LabelArea",function() 
	local container = ccui.ScrollView:create()
	container:setScrollBarEnabled(false)
	container:setTouchEnabled(true)
	container.m_setContentSize = container.setContentSize
	container.m_getContentSize = container.getContentSize
	return container
end,require("src.base.control.label.LabelElement"),require("src.base.event.EventDispatch"))

-- ----------------------event 事件-------------------------------------
LabelArea.EVT_LINK = "evt_link"			--超链接监听
-- ---------------------------------------------------------------------
--[[
 *	构造函数
 *	@param：text 文本
 *	@param：fontsize 字体大小
 *	@param：fontcolor 字体颜色
 *	@param：fontname 字体名
 *	@param：style 样式表
 *	@param size：文本宽高
]]
function LabelArea:ctor(text,fontsize,fontcolor,fontname,style,size)
	self.m_fontSize = fontsize or self.m_fontSize
	self.m_fontColor = fontcolor or self.m_fontColor
	self.m_fontName = fontname or self.m_fontName
	self:setAnchorPoint(self.m_anchorPoint)
	if size then
		self:setContentSize(size)
	end
	self.m_style = style
	self.m_vertype = "top"
	
	self.m_elements = {}
	--label承载层
	self.m_labellayout = ccui.Layout:create()
	self.m_labellayout:setContentSize(cc.size(1,1))
	self.m_labellayout.useheight = 2
	self.m_labellayout:setPositionX(2)
	self:addChild(self.m_labellayout)
	
	self:setString(text)
end
function LabelArea:setContentSize(size)
	self:m_setContentSize(size)
	self:setWidth(size.width - 4)
	self:m_hasdrity()
end
--添加文本
function LabelArea:appendText(txt)
	txt = txt or ""
	self.m_text = self.m_text or ""
	self.m_text = self.m_text .. txt
	self:m_updateView(txt,false)
end
--设置垂直对齐方式
function LabelArea:setVerType(value)		
	if self.m_vertype ~= value then
		self.m_vertype = value
		self:m_hasdrity()
	end
end
--子文本超链接监听
function LabelArea:m_labelLinkHandler(e,info)
	self:dispatchEvent(e,info)
end

--立即绘制
function LabelArea:draw()
	if not self.m_drityhandler then return end
	timestop(self.m_drityhandler)
	self.m_drityhandler = nil
	self:m_updateView(self.m_text,true)
end
--@private
function LabelArea:m_hasdrity()
	if self.m_drityhandler then return end
	self.m_drityhandler = timeout(function()
		--判断 self.m_leading 防止label被移除后，监听还在
		if not self or not self.m_leading then return end
		self.m_drityhandler = nil
		self:m_updateView(self.m_text,true)
	end)
end
--@private 刷新对齐方式
function LabelArea:m_refreshAlign(label)
	table.insert(self.m_elements,label)
	
	local allHeight = self.m_labellayout.useheight
	
	label:setPositionY(-allHeight)
	self.m_labellayout:addChild(label)
	allHeight = allHeight + label:getContentSize().height
	self.m_labellayout.useheight = allHeight
	
	local size = self:getContentSize()
	allHeight = allHeight + 2
	
	if allHeight > size.height then
		--大于显示高
		self:setBounceEnabled(true)
		self:getInnerContainer():setContentSize(cc.size(size.width,allHeight))
		self:getInnerContainer():setPositionY(size.height - allHeight)
		
		self.m_labellayout:setPositionY(allHeight)
	else
		--小于显示高
		self:setBounceEnabled(false)
		self:getInnerContainer():setContentSize(size)
		self:getInnerContainer():setPositionY(0)
		
		if self.m_vertype == "center" then
			self.m_labellayout:setPositionY(size.height - (size.height - allHeight)*0.5)
		elseif self.m_vertype == "top" then
			self.m_labellayout:setPositionY(size.height)
		elseif self.m_vertype == "bottom" then
			self.m_labellayout:setPositionY(size.height - allHeight)
		end
	end
end
--[[
*	@private
*	刷新文本
*	@param text 		文本
*	@param flushall		是否刷新全部文本，默认是
]]
function LabelArea:m_updateView(text,flushall--[[=true]])
	if flushall then
		self.m_labellayout:removeAllChildren()
		self.m_labellayout.useheight = 2
		self.m_elements = {}
		
		if not text or text == "" then return end
	else
		if not text or text == "" then return end
	end
	
	local label = require("src.base.control.label.LabelElement").new()
	label:setAnchorPoint(cc.p(0, 1))
	label:setFontSize(self.m_fontSize)
	label:setFontName(self.m_fontName)
	label:setFontColor(self.m_fontColor)
	label:setWidth(self.m_dimentWidth)
	label:setEdgeSmoothing(self.m_edgeSmoothing)
	label:setUnderLine(self.m_underline)
	label:setLeading(self.m_leading)
	label:setStyle(self.m_style)
	label:setAltasProperty(self.m_altaswidth,self.m_altasheight,self.m_altaschar)
	label:enableGlow(self.m_glowcolor)
	label:enableOutline(self.m_outlinecolor,self.m_outlinesize)
	label:enableShadow(self.m_shadowcolor,self.m_shadowsize,self.m_blur)
	label:setHorType(self.m_hortype)
	label:addEventListener(label.EVT_LINK,self.m_labelLinkHandler,self)
	label:setString(text,true)
	
	self:m_refreshAlign(label)
end
return LabelArea