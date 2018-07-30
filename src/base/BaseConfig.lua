--[[
 *	数据对象模板类
 *
 *	@author:lqh
]]
local BaseConfig = class("BaseConfig")
--[[
*	模板数据路径变量
*	
*	##
*		子类如果需要调用父类的构造函数，必须给变量赋值
]]
BaseConfig.samplepath_ = nil
--[[
*	构造函数
*	
*	##
*		继承对象如果复写了构造函数应该调用 self:super("ctor",sid)方法，实现对模板数据的构造
*	@param:sid 模板数据sid
]]
function BaseConfig:ctor(sid)
	if not sid then return end
	
	local templete = require(self.samplepath_)
	local config = templete[sid] or table.findKeyOfItem(templete,"sid",sid)
	if not config then
	  	mlog(DEBUG_E,string.format("<%s>:config data instantiation faile,config path is:%s ,sid is: %s",self.__cname,self.samplepath_,sid))
		return
	end
	self.m_config = config
	
	setmetatableex(self, config)
--	table.merge(self,config)
end
--[[
*	获取模板原始值
*	@param key 键名
]]
function BaseConfig:getOriginal(key)
	return self.m_config[key]
end
--[[
*	获取指定sid模板数据
*	@param:sid 如果sid为空，则获取当前对象的模板数据
]]
function BaseConfig:getConfig(sid)
	sid = sid or self.sid
	local config = {}
	setmetatable(config,{__index = require(self.samplepath_)[sid]})
	return config
end
--[[
*	获取所有 模板数据
*	@param:isobj 是否实例化为对象（默认false）
]]
function BaseConfig:getAllConfig(isobj)
	local list,templete = {},require(self.samplepath_)
	for k,v in pairs(templete) do
		if isobj then
			list[k] = v
		else
			list[k] = self.new(k)
		end
	end
	return list
end
function BaseConfig:getName()
	return self.name
end
function BaseConfig:getDesc()
	return self.desc
end
--[[
*	重载运算符，只能在类模板构造时调用，不能在对象实例化时使用
*	@param:operator 运算符（==，+，-，*，/）
*	@param:f 重载方法
]]
function BaseConfig:overrideOperator_(operator,f)
	if operator == "==" then
		self.__eq = f
	elseif operator == "+" then
		self.__add = f
	elseif operator == "-" then
		self.__sub = f
	elseif operator == "*" then
		self.__mul = f
	elseif operator == "/" then
		self.__div = f
	end
end
function BaseConfig:bytesWrite(data)
	data:writeData(self.sid)
end
function BaseConfig:bytesRead(data)
end

Gbv.BaseConfig = BaseConfig

return BaseConfig