--[[
*	颜色定义
]]
local Color = {}
--置灰使用颜色
Color.SET_GRAY		= cc.c3b(0x79,0x79,0x79)
Color.WHITE 		= cc.c3b(255, 255, 255)
Color.BLACK 		= cc.c3b(0, 0, 0)
Color.RED   		= cc.c3b(0xfa,0x49,0x3c)
Color.GREEN 		= cc.c3b(0x60,0xe3,0x34)
Color.BLUE  		= cc.c3b(0x40,0xb2,0xe8)
Color.YELLOW  		= cc.c3b(0xf0,0xd6,0x46)
Color.GREY 			= cc.c3b(0x6b,0x6a,0x6a)
Color.BROWN 		= cc.c3b(0x52,0x18,0x02)
Color.ORANGE 		= cc.c3b(0xb3,0x91,0x38)
Color.dantuhuangse  = cc.c3b(0xb1,0xa6,0x66) 	--淡土黄色
Color.danrubaise  	= cc.c3b(0xfc,0xda,0xa3) 	--淡乳白色
--gwj
Color.GWJ_I 		= cc.c3b(0xfd,0xde,0x8a)
Color.GWJ_II 		= cc.c3b(0x4f,0x1c,0x01)
Color.GWJ_III 		= cc.c3b(0x92,0x80,0x66)
Color.GWJ_IIII 		= cc.c3b(0xdf,0xc7,0x77)
Color.GWJ_F 		= cc.c3b(0x73,0x8c,0x18)
Color.GWJ_FF 		= cc.c3b(0x84,0xF8,0xF8)
Color.GWJ_FFF 		= cc.c3b(0x75,0x44,0x3d)
Gbv.Color = {}
setmetatable(Gbv.Color,{
	__index = function(t,k) 
		if not Color[k] then mlog(DEBUG_E,string.format("<Color>:attempt to read undeclared variable, key = <%s>",k)) end
		return Color[k]
	end,
	__newindex = function(t,k,v)
		if Color[k] then
			mlog(DEBUG_E,string.format("<Color>:can not change ST property(%s) value!",k))
			return
		end
		mlog(DEBUG_E,string.format("<Color> attempt to write new variable ,key = <%s>",k))
  	end,
  	__metatable = "You cannot get the protect metatable"
})

return Gbv.Color