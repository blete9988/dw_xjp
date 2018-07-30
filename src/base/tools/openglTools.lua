local openglTools = {}

local vertDefaultSource_nomvp = "\n".."\n" ..
						"attribute vec4 a_position;\n" ..
						"attribute vec2 a_texCoord;\n" ..
						"attribute vec4 a_color;\n\n" ..
						"\n#ifdef GL_ES\n" .. 
						"varying lowp vec4 v_fragmentColor;\n" ..
						"varying mediump vec2 v_texCoord;\n" ..
						"\n#else\n" ..
						"varying vec4 v_fragmentColor;" ..
						"varying vec2 v_texCoord;" ..
						"\n#endif\n" ..
						"void main()\n" ..
						"{\n" .. 
						"   gl_Position = CC_PMatrix * a_position;\n"..
						"   v_fragmentColor = a_color;\n"..
						"   v_texCoord = a_texCoord;\n" ..
						"} \n"
local vertDefaultSource	= "\n".."\n" ..
						"attribute vec4 a_position;\n" ..
						"attribute vec2 a_texCoord;\n" ..
						"attribute vec4 a_color;\n\n" ..
						"\n#ifdef GL_ES\n" .. 
						"varying lowp vec4 v_fragmentColor;\n" ..
						"varying mediump vec2 v_texCoord;\n" ..
						"\n#else\n" ..
						"varying vec4 v_fragmentColor;" ..
						"varying vec2 v_texCoord;" ..
						"\n#endif\n" ..
						"void main()\n" ..
						"{\n" .. 
						"   gl_Position = CC_MVPMatrix * a_position;\n"..
						"   v_fragmentColor = a_color;\n"..
						"   v_texCoord = a_texCoord;\n" ..
						"} \n"
local fshDefaultSource 	= "\n\n" .. 
						"\n#ifdef GL_ES" ..
						"\nprecision mediump float;\n" ..
						"\n#endif\n" ..
						"\nvarying vec4 v_fragmentColor;" ..
						"\nvarying vec2 v_texCoord;" .. 

						"\nvoid main(void)"..
						"\n{\n"..
						"\n	 gl_FragColor = texture2D(CC_Texture0, v_texCoord);" ..
						"\n}\n"
--置灰shader
local graySource 		= "#ifdef GL_ES \n" ..
						"precision mediump float; \n" ..
						"#endif \n" ..
						"varying vec4 v_fragmentColor; \n" ..
						"varying vec2 v_texCoord; \n" ..
						"void main(void) \n" ..
						"{ \n" ..
						"vec4 c = texture2D(CC_Texture0, v_texCoord); \n" ..
						"gl_FragColor.xyz = vec3(0.4*c.r + 0.4*c.g +0.4*c.b); \n"..
						"gl_FragColor.w = c.w; \n"..
						"}"
						

local fshs = {
	
}
local function GetRealyRender(node)
	if node:getDescription() == "Button" then
		return node:getRendererNormal()
	end
	return node
end
--还原默认shader
function openglTools.resetProgram(node)
	local glProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource_nomvp, fshDefaultSource)
	glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    glProgram:link()
    glProgram:updateUniforms()
	GetRealyRender(node):setGLProgram(glProgram)
end
--置灰
function openglTools.setGray(node)
	node = GetRealyRender(node)
	local glProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource_nomvp, graySource)
	glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    glProgram:link()
    glProgram:updateUniforms()
    node:setGLProgram(glProgram)
end
--置灰
function openglTools.setFreeze(node)
	node = GetRealyRender(node)
	if not fshs["freeze"] then
		fshs["freeze"] = cc.FileUtils:getInstance():getStringFromFile("res/shaders/example_Freeze.fsh")
	end
	local glProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource_nomvp, fshs["freeze"])
	glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    glProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    glProgram:link()
    glProgram:updateUniforms()
    node:setGLProgram(glProgram)
end

--[[
*	模糊
*	@param blurRadius 模糊半径 默认10
*	@param sampleNum  强度默认4
]]
function openglTools.setBlur(node,blurRadius,sampleNum)
	node = GetRealyRender(node)
	blurRadius = blurRadius or 7.0
	sampleNum = sampleNum or 4.0
	if not fshs["blur"] then
		fshs["blur"] = cc.FileUtils:getInstance():getStringFromFile("res/shaders/example_Blur.fsh")
	end
	local glProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource_nomvp, fshs["blur"])
	glProgram:link()
    glProgram:updateUniforms()
	node:setGLProgram(glProgram)
	local glProgramState = node:getGLProgramState()
	local size = node:getContentSize()
	local p = cc.p(size.width,size.height)
	glProgramState:setUniformVec2("resolution", p)
	glProgramState:setUniformFloat("blurRadius", blurRadius)
	glProgramState:setUniformFloat("sampleNum", sampleNum)
end
--[[
*	设置水波效果
*	@return 时间handler
]]
function openglTools.setWater(node,waterTexture,resolution--[[=nil]])
	if not fshs["water"] then
		fshs["water"] = cc.FileUtils:getInstance():getStringFromFile("res/shaders/example_WaterEffect.fsh")
	end
	
	local glProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource_nomvp, fshs["water"])
	glProgram:link()
    glProgram:updateUniforms()
	node:setGLProgram(glProgram)
	local glProgramState = node:getGLProgramState()
	local size = node:getContentSize()
	local p = cc.p(size.width,size.height)
	glProgramState:setUniformVec2("resolution", p)
--	glProgramState:setUniformTexture("tex0", 00)
	glProgramState:setUniformTexture("tex0", waterTexture)
	local alltime = 0
--	local handler = timeup(function(tm) 
--		alltime = alltime + tm
--		glProgramState:setUniformFloat("time", alltime)
--	end,0.013)
--	return handler
end
--截屏
--cc.utils:captureScreen(function(succeed, outputFile) 
--	if not succeed then print(">>>>>>>>>>>") end
--	local sp = cc.Sprite:create(outputFile)
--	local listener = cc.EventListenerCustom:create("event_renderer_recreated", function (eventCustom)
--    end)
--    sp:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, sp)
--    self:addChild(sp)
--    sp:setPosition(320,590)
--end, "test.png")

Gbv.openglTools = openglTools

return openglTools