--[[--
 * 水浒传数据
 * @author GWJ
 * 
]]

local ShuiHuZhuanController = class("ShuiHuZhuanController")
local instance = nil
-- datas
function ShuiHuZhuanController:ctor()
	self:init()
end

function ShuiHuZhuanController:init()
	self.action_array = {} --动作管理集合
	self.betinitMoney = 0	--基础下注数量
	self.maxBetMoney = 0	--最大下注额度
	self.betMoney = 0
end

function ShuiHuZhuanController:serBetMoney(value)
	self.betinitMoney = value 
	self.maxBetMoney =  value * 10
	self.betMoney = value
end

function ShuiHuZhuanController:addBetMoney()
	if self.betMoney == self.maxBetMoney then return end
	self.betMoney = self.betMoney + self.betinitMoney
end

function ShuiHuZhuanController:cutdownYaFen()
	if self.betMoney == self.betinitMoney then return end
	self.betMoney = self.betMoney - self.betinitMoney
end


function ShuiHuZhuanController:addActionHandler(handler)
	table.insert(self.action_array,handler)
end

function ShuiHuZhuanController:cleanActionHandler()
	self.action_array = {}
end

function ShuiHuZhuanController.getInstance()
	if instance == nil then
		instance = ShuiHuZhuanController.new()
	end
	return instance
end

return ShuiHuZhuanController