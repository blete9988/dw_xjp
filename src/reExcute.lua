--该文件在热更新后 被执行，用来reload一些已经加载的文件
return function(callback)
	--默认直接回掉
	display.enterScene("src.ui.scene.RelanuchScene")
	-- callback()
end