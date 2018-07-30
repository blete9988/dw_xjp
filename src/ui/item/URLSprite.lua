--[[
*	显示网络图片
]]
local URLSprite = class("URLSprite",require("src.base.extend.CCLayerExtend"),require("src.base.event.EventDispatch"),function()
	return display.newSprite()
end)

URLSprite.EVT_LOADED_TEXTURE = "evt_loaded_texture"

local urlLoader = require("src.base.http.HttpRequest")

function URLSprite:ctor(url)
	self:super("ctor")
	self.m_living = true
	self:setUrl(url)
end
function URLSprite:setUrl(url)
	if not url then return end
	if self.m_url then
		display.removeTexture(self.m_url)
	end

	urlLoader.loadUrlImage(url,function(result,realUrl)
		if not self.m_living then return end
		if result ~= 0 then
			self:setSpriteFrame("imageFailureIcon.png")

			mlog(DEBUG_W,string.format("<URLSprite>:download \"%s\" url image failed !!",url))
		else
			self.m_url = realUrl
			self:setTexture(realUrl)
		end

		self:dispatchEvent(URLSprite.EVT_LOADED_TEXTURE,self)
	end)
end
function URLSprite:onCleanup()
	if not self.m_living then return end
	self.m_living = nil
	if not self.m_url then return end
	display.removeTexture(self.m_url)
end
return URLSprite
