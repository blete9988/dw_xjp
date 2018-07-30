--[[
*	调用UIWidgetExtend.new(target) target必须问哦widget显示对象，不能为空
]]
local UIWidgetExtend = class("UIWidgetExtend", require("src.base.extend.CCNodeExtend"),function(target) 
	return target
end)
function UIWidgetExtend.extend(target)
	setmetatableex(target,UIWidgetExtend)
    return target
end

--通过name返回一个child,child的类型自动匹配,并且自动添加扩展接口不再只是widget对象
function UIWidgetExtend:getChild(name)
	if not name then 
		mlog(DEBUG_E,"<UIWidgetExtend> error in function getChild, name is nil.")
	end
    local uiwidget = self:getChildByName(name)
	if not uiwidget then
		mlog(DEBUG_E,"<UIWidgetExtend> can not getChildByName with " .. name)
	end
	if uiwidget._istolua then return uiwidget end
	local className = "ccui." .. uiwidget:getDescription()
	if className == "ccui.Label" then
		className = "ccui.Text"
	end
    if not className then
		mlog(DEBUG_E,"<UIWidgetExtend> uiwidget:getDescription() = nil")
	end
    uiwidget = tolua.cast(uiwidget,className)
	local language
	if className == "ccui.Text" then
		uiwidget:setFontName(Cfg.FONT)
		language = uiwidget:getString()
		if language then
			uiwidget:setString(display.trans(language))
		end
	elseif className == "ccui.Button" then
		language = uiwidget:getTitleText()
		if language then
			uiwidget:setTitleFontName(Cfg.FONT)
			uiwidget:setTitleText(display.trans(language))
		end
	elseif className == "ccui.TextField" then
		uiwidget:setFontName(Cfg.FONT)
		language = uiwidget:getPlaceHolder()
		if language then
			uiwidget:setPlaceHolder(display.trans(language))
		end
	end
    uiwidget._istolua = true
    return uiwidget
end
return UIWidgetExtend