--[[
*	方法说明
*	LabelElement:setString(str,immediately)						设置文字
*	LabelElement:setFontSize(size)								设置默认字体大小（默认全局设置的字体大小）
*	LabelElement:getContentSize()								@override native 获取尺寸
*	LabelElement:setFontName(name)								设置默认字体名（默认全局设置的系统字体）
*	LabelElement:setFontColor(color)							设置默认字体颜色（默认全局设置的字体颜色）
*	LabelElement:setFontPath(str)								设置字体文件目录（默认res/fonts）
*	LabelElement:setWidth(width)								设置行宽（默认单行无限宽）
*	LabelElement:setEdgeSmoothing(value)						设置是否平滑边缘（默认平滑边缘）
*	LabelElement:setUnderLine(value)							设置超链接是否显示下滑下（默认显示）
*	LabelElement:setLeading(value)								设置行间隔（默认2）
*	LabelElement:setStyle(style)								设置style表
*	LabelElement:setHorType(value)								设置水平对齐方式（默认左对齐）
*	LabelElement:enableGlow(c4b)								设置外发光
*	LabelElement:enableOutline(c4b,outlinesize)					设置描边
*	LabelElement:enableShadow(c4b,size,blur)					设置阴影
*
*
*	------------------------------使用说明-------------------------------
*	富文本Label，支持html格式
*	支持html格式的嵌套使用,支持普通文本使用 <  > 和任意符号,支持\n换行
*	## 注意
*		该文本不能锁定高度，只能锁定宽，方法 setDimentWidth 可以设置行宽
*		标签属性内容 " 号可省略，但是建议使用引号包装属性值 如： size="20"
*		签中属性内容不能出特殊字符，如不能避免特殊字符的使用，请用转义字符代替
*		[%] = &#037; ["] = &#034; ['] = &#039; [<] = &#060; [>] = &#062; [=] =&#061; [ ] = &#032;
*		符号 ";" 属于转义字符
*	## html格式
*		<span name=Helvetica size=30 color=ff00>test</span>
*		<span name=arial.ttf size=30 color=60e334>test</span>
*		<span name=nmbBitmap_20X24.png width=20 height=30 startchar=0>1918</span>
*		<span name=futura-48.fnt>asdasd99</span>
*	支持描边，阴影，发光
*	描边：
*		<span name=Helvetica outlinecolor=ff0000ff outlinesize=1>test</span>
*	发光：
*		<span glowcolor=ff>test</span>
*	阴影：
*		<span shadowcolor=00 shadowsize=2,-2 blur=1>
*	同时具有描边阴影发光
*		<span name=Helvetica outlinecolor=ff0000ff glowcolor=ff shadowcolor=00 outlinesize=1>test</span>
*	段落标签：
*		<p align=center>test</p> 段落居中对齐
*	超链接标签：
*		<event e=asdasdtes>test</event> test可接受点击事件同时向外派发事件内容为e的值
*	图片标签(单标签)
*		<img src=res/images/icon.png imgtype=0>
*	自定义显示对象标签(单标签)
*		<custom key='test' param='1'>
*	标签中 所有属性都不是必须属性,即都可省略,如果没指定,将会使用该文本对象的缺省属性值
*
*	@author lqh
]]
local Attribute = {
	--可识别html 属性
	NAME = "name",						--字体名
	PATH = "path",						--字体路径
	COLOR = "color",					--字体颜色
	SIZE = "size",						--字体大小（只对系统字体和ttf字体有效）
	CLASS = "class",					--样式表
	WIDTH = "width",					--charmap字体宽
	HEIGHT = "height",					--charmap字体高
	STARCHAR = "startchar",				--charmap字体开始字符串
	OUTLINECOLOR = "outlinecolor",		--描边 c4b
	OUTLINESIZE = "outlinesize",		--描边距离（当outlinecolor不为空时有效）
	GLOWCOLOR = "glowcolor",			--发光 c4b
	SHADOWCOLOR = "shadowcolor",		--阴影 c4b
	SHADOWSIZE = "shadowsize",			--阴影位置 cc.csize （当shadowcolor不为空时有效）
	BLUR = "blur",						--阴影模糊（当shadowcolor不为空时有效）
	E = "e",							--事件 属性
	SRC = "src",						--图片路径
	dynamic = "dynamic",				--是否回收图片
	IMGTYPE = "imgtype",				--图片路径type：0 本地路径，1：纹理集
	ALIGN = "align",					--行对齐标识
	KEY = "key",						--自定义标签key属性
	PARAM = "param",					--自定义标签调用参数
	 --常量定义
	FONT_FILE = "res/fonts/",			--字体根目录
	DEFAULT_DIMENT = 99999,				--默认行宽（即不换行）
}
-- ----------------------------------常量定义------------------------------------------
--xml解析器
local XMLParse = require("src.base.xml.XMLParse")
--label 缓存
local LabelPools = require("src.base.control.label.LabelPools")
--c3b	比较函数
local function comparec3b(c1,c2)
	if not c1 or not c2 then return false end
	if c1.r == c2.r and c1.g == c2.g and c1.b == c2.b then return true end
end
--c4b	比较函数
local function comparec4b(c1,c2)
	if not c1 or not c2 then return false end
	if c1.r == c2.r and c1.g == c2.g and c1.b == c2.b and c1.a == c2.a then return true end
end
--size 	比较函数
local function comparesize(s1,s2)
	if not s1 or not s2 then return false end
	if s1.width == s2.width and s1.height == s2.height then return true end
end
--静态方法定义
local CreateLabel,CreateImage,CreateCustom,CreateLinkLayout,AlignContainer,AlginLabel,AlignCharmapLaebl,AlignBmpFnt,AlignImage
-- ----------------------------------------class-------------------------------------------
local LabelElement = class("LabelElement",function() 
	local layout = ccui.Layout:create()
	layout.m_getContentSize = layout.getContentSize
	return layout
end,require("src.base.event.EventDispatch"))

-- ----------------------event 事件-------------------------------------
LabelElement.EVT_LINK = "evt_link"			--超链接监听
-- ---------------------------------------------------------------------

--文本默认属性值
--字体大小
LabelElement.m_fontSize = Cfg.SIZE
--字体
LabelElement.m_fontName = Cfg.FONT
--字体颜色颜色
LabelElement.m_fontColor = Cfg.COLOR
--行宽（默认不换行）
LabelElement.m_dimentWidth = Attribute.DEFAULT_DIMENT
--水平左对齐
LabelElement.m_hortype = "left"
--锚点在
LabelElement.m_anchorPoint = cc.p(0.5, 0.5)
--行间距 
LabelElement.m_leading = 1
--描边距离 0.5（只有当设置了描边才有效）
LabelElement.m_outlinesize = 0.5
--阴影位置 右下 便宜 2,-2（只有当设置了阴影才有效）
LabelElement.m_shadowsize = cc.size(2,-2)
--阴影 模糊 0 （只有当设置了阴影才有效）
LabelElement.m_blur = 0
--charmap 字体 开始字体索引为 字符 "0"
LabelElement.m_altaschar = "0"
--charmap 字体宽
LabelElement.m_altaswidth = 0
--charmap 字体高
LabelElement.m_altasheight = 0
--边缘平滑
LabelElement.m_edgeSmoothing = true
--超链接是否显示下划线
LabelElement.m_underline = true
--[[
 *	构造函数
 *	@param：text 文本
 *	@param：fontsize 字体大小
 *	@param：fontcolor 字体颜色
 *	@param：fontname 字体名
 *	@param：style 样式表
]]
function LabelElement:ctor(text,fontsize,fontcolor,fontname,style)
	self.m_fontSize = fontsize or self.m_fontSize
	self.m_fontColor = fontcolor or self.m_fontColor
	self.m_fontName = fontname or self.m_fontName
	self.m_style = style
	self:setString(text)
	
	self:setAnchorPoint(self.m_anchorPoint)
	
	--超链接监听
	function self._eventhandler(t,e)
		if e ~= ccui.TouchEventType.ended then return end
		self:dispatchEvent(LabelElement.EVT_LINK ,t._event)
	end
end
--设置默认文本尺寸
function LabelElement:setFontSize(size)		
	if not size or size == self.m_fontSize then return end
	self.m_fontSize = size
	self:m_hasdrity()
end
--@override
function LabelElement:getContentSize()
	self:draw()
	return self:m_getContentSize()
end
--设置默认文本名字
function LabelElement:setFontName(name)			
	if not name or name == self.m_fontName then return end
	self.m_fontName = name
	self:m_hasdrity()
end
--设置文本颜色
function LabelElement:setFontColor(color)	
	if not color or comparec3b(color,self.m_fontColor) then return end
	self.m_fontColor = color 
	self:m_hasdrity()
end
--设置字体路径
function LabelElement:setFontPath(str)
	self.m_fontpath = str
end
--设置单排最大宽
function LabelElement:setDimentWidth(width)		
	if not width or self.m_dimentWidth == width then return end
	self.m_dimentWidth = width
	self:m_hasdrity()
end
function LabelElement:setWidth(width)
	self:setDimentWidth(width)
end
--设置是否需要边缘对齐
function LabelElement:setEdgeSmoothing(value)
	if self.m_edgeSmoothing == value then return end
	self.m_edgeSmoothing = value
	self:m_hasdrity()
end
function LabelElement:setUnderLine(value)
	if self.m_underline == value then return end
	self.m_underline = value
	self:m_hasdrity()
end
--设置行间距
function LabelElement:setLeading(value)			
	if not value or value == self.m_leading then return end
	self.m_leading = value
	self:m_hasdrity()
end
--设置样式表
function LabelElement:setStyle(style)			
	self.m_style = style
end
--获取样式表
function LabelElement:getStyleByKey(key)		
	if not self.m_style or not self.m_style[key] then
		mlog(DEBUG_W,string.format("<LabelElement>: can not get style by key:%s",key))
		return {}
	end
	return self.m_style[key]
end
--[[
*	设置 altas 字体属性
*	@param:width 每个字宽
*	@param:height 每个字高
*	@param:startchar 起始字符（可选参数，不填则默认为 0）
]]
function LabelElement:setAltasProperty(width,height,startchar)
	width = width or self.m_altaswidth
	height = height or self.m_altasheight
	if not startchar or startchar == "" then startchar = self.m_altaschar end
	startchar = tostring(startchar)
	if self.m_altaswidth == width and self.m_altasheight == height and self.m_altaschar == startchar then return end
	self.m_altaswidth = width
	self.m_altasheight = height
	self.m_altaschar = startchar
	self:m_hasdrity()
end
--[[
*	设置发光
*	@param c4b 发光颜色
]]
function LabelElement:enableGlow(c4b)
	if (not c4b and not self.m_glowcolor) or comparec4b(self.m_glowcolor,c4b) then return end
	self.m_glowcolor = c4b
	self:m_hasdrity()
end
--[[
*	描边
*	@param:c4b 描边颜色（必填参数）
*	@param:outlinesize 描边size（可选参数，不填则为默认值 OUT_LINE_SIZE）
]]
function LabelElement:enableOutline(c4b,outlinesize)
	outlinesize = outlinesize or self.m_outlinesize
	if outlinesize == self.m_outlinesize and ((not c4b and not self.m_outlinecolor) or comparec4b(self.m_outlinecolor,c4b)) then return end
	self.m_outlinecolor = c4b 
	self.m_outlinesize = outlinesize
	self:m_hasdrity()
end
--[[
*	阴影
*	@param:c4b 阴影颜色（必填参数）
*	@param:size 阴影位置（可选参数，不填则为默认值）
*	@param:blur 模糊（可选参数，不填则为默认值）
]]
function LabelElement:enableShadow(c4b,size,blur)
	size = size or self.m_shadowsize
	blur = blur or self.m_blur
	if comparesize(size,self.m_shadowsize) and blur == self.m_blur and ((not c4b and not self.m_shadowcolor) or comparec4b(self.m_shadowcolor,c4b)) then return end
	self.m_shadowcolor = c4b 
	self.m_shadowsize = size or self.m_shadowsize
	self.m_blur = blur or self.m_blur
	self:m_hasdrity()
end
--某些版本不允许改变layout的锚点，所以重写了改方法
--function LabelElement:setAnchorPoint(point)
--	self.m_anchorPoint = point
--	self:m_updataAnchor()
--end
--设置水平对齐方式
function LabelElement:setHorType(value)		
	value = value or self.m_hortype 	
	if value == self.m_hortype then return end
	self.m_hortype = value
	self:m_hasdrity()
end
--[[
*	设置文本
*	@param str 文本内容
*	@param immediately 是否立即渲染
]]
function LabelElement:setString(str,immediately)
	str = tostring(str)
	if str == self.m_text then return end
	self.m_text = str
	self:m_hasdrity()
	if immediately then self:draw() end
end
function LabelElement:getString()
	return self.m_text or ""
end

--立即绘制
function LabelElement:draw()
	if not self.m_drityhandler then return end
	timestop(self.m_drityhandler)
	self.m_drityhandler = nil
	self:m_updateView()
end
--@private
function LabelElement:m_hasdrity()
	if self.m_drityhandler then return end
	self.m_drityhandler = timeout(function()
		--判断 self.m_leading 防止label被移除后，监听还在
		if not self or not self.m_leading then return end
		self.m_drityhandler = nil
		self:m_updateView()
	end)
end
--@private 注册点更改更新(在不支持更改layout锚点的版本上使用)
--function LabelElement:m_updataAnchor()
--	if not self.m_container then return end
--	local size = self.m_container:getContentSize()
--	local position = cc.p(0,0)
--	if self.m_anchorPoint.x == 0.5 then
--		position.x = -size.width/2
--	elseif self.m_anchorPoint.x == 1 then
--		position.x = -size.width
--	end
--
--	if self.m_anchorPoint.y == 0.5 then
--		position.y = -size.height/2
--	elseif self.m_anchorPoint.y == 1 then
--		position.y = -size.height
--	end
--	self.m_container:setPosition(position)
--end
--@private 刷新视图
function LabelElement:m_updateView()			
	if not self.m_container then
		self.m_container = ccui.Layout:create()
		self:addChild(self.m_container)
	else
		self.m_container:removeAllChildren()
	end
	if not self.m_text or self.m_text == "" then 
		self:setContentSize(cc.size(1,1))
		return 
	end
	--解析文本,行列表,当前行
	local textnodes,rowlist,current_row = table.reverse(XMLParse.parsehtml(self.m_text)),{}
	local item,node,insertNode,lastname
	
	--向文本数据列表尾部插入数据
	local function insertNodedata(node)
		if not node then return end
		table.insert(textnodes,node)
	end
	
	while true do
		node = table.remove(textnodes,#textnodes)
		if not node then table.insert(rowlist,current_row) break end
		
		--有换行，或者当前行为空
		if node:getNewline() or not current_row then 
			if current_row then table.insert(rowlist,current_row) end
			node:setNewline(false)
			current_row = {freewidth = self.m_dimentWidth,maxheight = 3,maxwidth = self.m_dimentWidth,align = nil}
		end
		
		if node:getTag() == XMLParse.DefineTAG.img then
			--图片标签
			item = node.display or CreateImage(node)
			if item then
				insertNodedata(AlignImage(item,current_row))
			end
		elseif node:getTag() == XMLParse.DefineTAG.custom then
			--自定义标签
			item = node.display or CreateCustom(node)
			if item then
				insertNodedata(AlignImage(item,current_row))
			end
		elseif node:getText() and node:getText() ~= "" then
			--文字标签
			item = node.display or CreateLabel(node,self)
			if node:getKey("lastname") == ".png" then
				insertNodedata(AlignCharmapLaebl(item,self,current_row))
			elseif node:getKey("lastname") == ".fnt" then
				insertNodedata(AlignBmpFnt(item,current_row))
			else
				insertNodedata(AlginLabel(item,self,current_row))
			end
		end
	end
	
	AlignContainer(rowlist,self.m_container,self)
--	self:m_updataAnchor()
	
	--测试显示区域用
--	self.m_container:setBackGroundColor(cc.c3b(255,255,0))
--	self.m_container:setBackGroundColorOpacity(125)
--	self.m_container:setBackGroundColorType(1)
end
-- ---------------------------------------static function----------------------------------
--@static 排版整个容器
function AlignContainer(rowlist,container,father)
	local position,maxwidth = cc.p(0,0),father.m_dimentWidth
	--每行起始坐标，行容器，行对齐方式
	local row
	for i = #rowlist,1,-1 do
		row = rowlist[i]
		local scale = 1
		position.x = 0
		
		if maxwidth ~= Attribute.DEFAULT_DIMENT then
			if father.m_edgeSmoothing and (row.freewidth <= father.m_fontSize or (row.freewidth < 40 and row.freewidth/maxwidth <= 0.05)) then
				--平滑边缘
				scale = maxwidth/(maxwidth - row.freewidth)
			else
				local hortalign = row.align or father.m_hortype
				if row.freewidth < 0 then
					scale = maxwidth/(maxwidth - row.freewidth)
					row.freewidth = 0
				end
				
				if hortalign == "right" then
					position.x = row.freewidth
				elseif hortalign == "center" then
					position.x = row.freewidth*0.5
				end
			end
		end
		
		for k = 1,#row do
			local item = row[k]
			item:setScale(scale)
			item:setPosition(position)
			container:addChild(item)
			if item.node:getKey(Attribute.E) then
				container:addChild(CreateLinkLayout(item,position,father._eventhandler,father.m_underline,item.node:getC3b(Attribute.COLOR) or father.m_fontColor))
			end
			
			position.x = position.x + item.mwd * scale
			
			item.node.display,item.node = nil
		end
		position.y = position.y + row.maxheight + father.m_leading
	end
	local size = cc.size(0,position.y - father.m_leading)
	if maxwidth ~= Attribute.DEFAULT_DIMENT then
		size.width = maxwidth 
	else
		size.width = maxwidth - row.freewidth
	end
	container:setContentSize(size)
	father:setContentSize(size)
end
--@static 排版图片
function AlignImage(image,row)
	local size,node = image:getContentSize(),image.node
	--当图片尺寸大于剩余长度，且该行不为新行时，换行
	if size.width > row.freewidth and row.freewidth ~= row.maxwidth then 
		node.display = image
		node:setNewline(true)
		return node
	end
	
	row.align = row.align or node:getKey(Attribute.ALIGN)
	
	image.mwd = size.width
	row.freewidth = row.freewidth - size.width
	
	if row.maxheight < size.height then row.maxheight = size.height end
	--将显示对象放入行中
	table.insert(row,image)
end
--@static 排版系统或者ttf字体，并计算截断位置
function AlginLabel(label,father,row)
	local node = label.node
	local fontsize = node:getInt(Attribute.SIZE) or father.m_fontSize
	if row.freewidth < fontsize then
		--剩余宽度小于 字宽
		node.display = label
		node:setNewline(true)
		return node
	end
	local insertnode
	
	local text = node:getText()
	local factor = 2
	--字长,非ASC2 码占2个长度
	local len = text:strlen()
	--预估截断位置,比实际短,采用1.75
	local subindex = math.floor(row.freewidth/fontsize * factor)
	local text1,text2 = text,""
	--预估截断位置小于utf8 长度，即可截断
	if subindex < len then 
		text1,text2,subindex = text:splitUTF8(subindex) 
		
		local len1,uftlen = text1:strlen()
		local rt = len1/uftlen
		
		if rt <= 1.73 then
			if rt > 1.40 then 
				factor = 1.80 
			else 
				factor = 1.70 
			end
			subindex = math.floor(row.freewidth/fontsize * factor)
			text1,text2,subindex = text:splitUTF8(subindex) 
		end
	end
	
	label:setString(text1)
	local size = label:getContentSize()
	
	if row.freewidth - size.width >= fontsize then
		if factor ~= 2 then
			factor = 2.0 - factor
			factor = 2.0 + (row.freewidth - size.width)/row.freewidth*(1 + factor*0.33)
		end
		--长度不够补上
		subindex = subindex + math.round((row.freewidth - size.width) * factor/fontsize)
		if subindex > len then subindex = len end
		text1,text2 = text:splitUTF8(subindex) 
		label:setString(text1)
		size = label:getContentSize()
	end
	
	if text2 ~= "" then
		insertnode = node:clone()
		insertnode:setNewline(true)
		insertnode:saveText(text2)
	end
	
	row.align = row.align or node:getKey(Attribute.ALIGN)
	
	label.mwd = size.width
	row.freewidth = row.freewidth - size.width
	
	if Cfg.DEBUG_TAG and row.freewidth < -40 then
		--mlog(DEBUG_W,string.format("<LabelElement>字符串预估截断实际像素远远大于行宽度， 超出%s像素",row.freewidth))
	end
	
	if row.maxheight < size.height then row.maxheight = size.height end	
	table.insert(row,label)
	
	return insertnode
end
--@static 排版bmp字体，采用粗略估计截断位置，截断不精确，因为bmp字体每个字符都有自己的尺寸，尺寸不固定
function AlignBmpFnt(label,row)
	local node = label.node
	local text = node:getText()
	label:setString(text)
	local size,insertnode = label:getContentSize()
	
	if size.width > row.freewidth then
		local text1,text2 = text
		local subindex = math.floor(text:strlen()*row.freewidth/size.width)
		while true do
			if subindex < 1 then
				node.display = label
				node:setNewline(true)
				return node
			end
			text1,text2 = text:splitUTF8(subindex)
			label:setString(text1)
			size = label:getContentSize()
			if size.width <= row.freewidth then
				insertnode = node:clone()
				insertnode:setNewline(true)
				insertnode:saveText(text2)
				break
			end
			subindex = subindex - math.ceil((1 - row.freewidth/size.width)*subindex)
		end
	end
	
	row.align = row.align or node:getKey(Attribute.ALIGN)
	row.freewidth = row.freewidth - size.width 
	label.mwd = size.width
	
	if row.maxheight < size.height then row.maxheight = size.height end	
	table.insert(row,label)
	return insertnode
end
--@static 排版charmap字体（该字体只能显示ASC2 码）
function AlignCharmapLaebl(label,father,row)
	local node,insertnode = label.node
	local perwidth,height = node:getInt(Attribute.WIDTH) or father.m_altaswidth,node:getInt(Attribute.HEIGHT) or father.m_altasheight
	if row.freewidth < perwidth then
		--剩余宽度不够一个字符
		node.display = label
		node:setNewline(true)
		return node
	end
	
	local text,subindex = node:getText(),math.floor(row.freewidth/perwidth)
	
	if subindex >= text:len() then
		--剩余宽度足够显示
		label:setString(text)
		label.mwd = perwidth*text:len()
	else
		--剩余宽度不够现实
		label:setString(text:sub(1,subindex))
		insertnode = node:clone()
		insertnode:setNewline(true)
		insertnode:saveText(text:sub(subindex + 1))
	end
	row.freewidth = row.freewidth - label.mwd
	row.align = row.align or node:getKey(Attribute.ALIGN)
	
	if row.maxheight < height then row.maxheight = height end	
	table.insert(row,label)
	return insertnode
end
--@static 创建文本
function CreateLabel(node,father)
	local label = LabelPools:getLabel()--cc.Label:create()
	if node:getKey(Attribute.CLASS) then
		--csstyle 样式表，将克隆node
		local cloneNode = node:clone()
		cloneNode:saveText(node:getText())
		for k,v in pairs(father:getStyleByKey(node:getKey(Attribute.CLASS))) do
			cloneNode:saveKey(k,v)
		end
		node = cloneNode
	end
	local fontname = node:getKey(Attribute.NAME) or father.m_fontName
	local lastname = fontname:sub(-4,-1)
	if lastname == ".ttf" then
		label:setTTFConfig({
			fontFilePath = string.format("%s%s",Attribute.FONT_FILE,fontname),
			fontSize = node:getInt(Attribute.SIZE) or father.m_fontSize
		})
		label.outpool = true
	elseif lastname == ".fnt" then
		label:setBMFontFilePath(string.format("%s%s",(node:getKey(Attribute.PATH) or father.m_fontpath or Attribute.FONT_FILE),fontname))
		label.outpool = true
	elseif lastname == ".png" then
		label:setCharMap(
			string.format("%s%s",(node:getKey(Attribute.PATH) or father.m_fontpath or Attribute.FONT_FILE),fontname),
			node:getInt(Attribute.WIDTH) or father.m_altaswidth,
			node:getInt(Attribute.HEIGHT) or father.m_altasheight,
			string.byte(node:getKey(Attribute.STARCHAR) or father.m_altaschar)
		)
		label.outpool = true
	else
		label:setSystemFontName(fontname)
		label:setSystemFontSize(node:getInt(Attribute.SIZE) or father.m_fontSize)
	end
	
	label:setColor(node:getC3b(Attribute.COLOR) or father.m_fontColor)
	--描边
	local color = node:getC4b(Attribute.OUTLINECOLOR) or father.m_outlinecolor
	if color then
		label:enableOutline(color,node:getInt(Attribute.OUTLINESIZE) or father.m_outlinesize)
	end
	--发光
	color = node:getC4b(Attribute.GLOWCOLOR) or father.m_glowcolor
	if color then label:enableGlow(color) end
	--阴影
	color = node:getC4b(Attribute.SHADOWCOLOR) or father.m_shadowcolor
	if color then
		label:enableShadow(
			color,
			node:getContentSize(Attribute.SHADOWSIZE) or father.m_shadowsize,
			node:getInt(Attribute.BLUR) or father.m_blur
		)
	end
	
	label:setAnchorPoint(cc.p(0, 0))
	node:saveKey("lastname",lastname)
	label.node = node
	return label
end
--@static 创建自定义对象
function CreateCustom(node)
	if not node:getKey(Attribute.KEY) then return end
	local func = require("src.app.config.style.customstyle")[node:getKey(Attribute.KEY)]
	if not func then 
		mlog(DEBUG_E,string.format("<LabelElement>:can not get custom displayobject by name:%s",node:getKey(Attribute.KEY)))
		return 
	end
	local item = func(node:getKey(Attribute.PARAM))
	if not item then 
		mlog(DEBUG_E,string.format("<LabelElement>:can not create custom displayobject by name:%s",node:getKey(Attribute.KEY)))
		return 
	end
	
	item.node = node
	item:setAnchorPoint(cc.p(0, 0))
	return item
end
--@static 创建图片对象
function CreateImage(node)
	local path = node:getKey(Attribute.SRC)
	if not path then return end
	
	local imgtype,item = node:getInt(Attribute.IMGTYPE) or 1
	
	if imgtype == 0 then
		if node:getBoolean(Attribute.dynamic) then
			item = require("src.base.control.DynamicImage").new(path)
		else
			item = cc.Sprite:create(path)
		end
	else
		item = cc.Sprite:createWithSpriteFrameName(path)
	end
	item.node = node
	item:setAnchorPoint(cc.p(0, 0))
	return item
end
--@static 创建超链接
function CreateLinkLayout(item,position,listener,isUnderline,color)
	local layout = ccui.Layout:create()
	layout:setTouchEnabled(true)
	layout:addTouchEventListener(listener)
	layout._event = item.node:getKey(Attribute.E)
	local size = item:getContentSize()
	layout:setContentSize(size)
	if item.node:getText() ~= "" and isUnderline then
		local underline = ccui.Layout:create()
		underline:setContentSize(cc.size(size.width,2))
		underline:setBackGroundColor(color)
		underline:setBackGroundColorType(1)
		layout:addChild(underline)
	end
	layout:setScaleX(item:getScaleX())
	layout:setPosition(position)
	return layout
end
return LabelElement
