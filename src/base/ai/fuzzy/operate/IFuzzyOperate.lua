--[[
*	模糊逻辑 逻辑操作代理类，接口
*	代理操作 模糊逻辑 与 或 最 等运算
*	@author lqh
]]
local IFuzzyOperate = class("IFuzzyOperate")
function IFuzzyOperate:ctor()
	error("can not new this interface!!")
end
--need override
function IFuzzyOperate:getDOM()
end
--need override
function IFuzzyOperate:clearDOM()
end
--need override
function IFuzzyOperate:orWithDOM(value)
end
--need override
function IFuzzyOperate:clone()
end
return IFuzzyOperate