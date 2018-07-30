Cfg = {
	--是否打印debug信息
	DEBUG_TAG = true,
	--是否显示帧率
	FPS_SHOW_STATUS = false,
	--是否开启内存打印 
	DEBUG_MEM = false,
	--是否不允许添加 全局变量
	CC_DISABLE_GLOBAL = true,
	--默认语言
	LANGUAGE = "CN",
	--是否为APP官方提交测试模式（自动动态设定）
	TEST_MODE = false,
	--当前项目外部公共储存 名称
	STORAGE_NAME = "chexuan_storage",
	--默认字体
	FONT = "Helvetica",
	--默认字号
	SIZE = 28,
	--默认颜色
	COLOR = {r = 255,g = 255,b = 255}
}

--[[
*	design resolution size
*	设计分辨率定义
]]
D_SIZE = {
	width = 1360,
	height = 765,
	--缩放比例
	zoomFactor = 1,
	--适配方式
	autoscale = "EXACT_FIT",
	--适配自定义回掉方法
	customExecute = function(framesize)
		return {}
	end
}
