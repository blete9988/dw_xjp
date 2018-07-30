--动态图片，图片被移除时会自动清理该纹理，只支持显示非plist 纹理
local DynamicImage = class("DynamicImage",require("src.base.extend.CCLayerExtend"),function(path,status) 
	local image = display.newImage()
	image._loadTexture = image.loadTexture
	return image
end)
function DynamicImage:ctor(path,status)
	self:super("ctor")
	
	self:loadTexture(path,status)
end
function DynamicImage:loadTexture(path,status)
	if not path or (self.m_path and self.m_path == path) then return end
	
	if self.m_path then
		display.removeTexture(self.m_path)
		self.m_path = nil
	end
	status = status or 0
	self:_loadTexture(path,0)
	if status == 0 then
		self.m_path = path
	end
end
function DynamicImage:onCleanup()
	if self.m_path then
		display.removeTexture(self.m_path)
	end
end
return DynamicImage
