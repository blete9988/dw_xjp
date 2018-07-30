这是一个人工智能模糊逻辑块的定义与实现
要使用此模块，需要去了解模糊逻辑

模糊逻辑的好坏全凭设计者的设计，一个好的设计者，设计的模糊集合，经过运算，总接近于人的思维方式得出的结论

列子：
//首先应该实例化模糊逻辑块
local fm = require("src.maxcore.ai.fuzzy.FuzzyModule").new()

//创建一个目标距离的模糊逻辑变量
local fv1 = fm:createFLV("TargetDistance")
//靠近目标
local closeTarget = fv1:addFuzzyLeftShoulder("closeTarget",0,10,25)
//目标 中等距离
local mediumTarget = fv1:addFuzzyTriangle("mediumTarget",20,35,50)
//目标在很远
local farTarget = fv1:addFuzzyRightShoulder("farTarget",40,60,200)

//创建一个弹药剩余的模糊逻辑变量
local fv2 = fm:createFLV("Bullet")
//弹药稀少
local bulletLittle = fv2:addFuzzyLeftShoulder("little",0,5,10)
//弹药一般
local bulletNormal = fv2:addFuzzyTriangle("normal",7,14,21)
//弹药充足
local bulletMuch = fv2:addFuzzyRightShoulder("much",18,25,50)

//创建一个期望值的模糊逻辑变量
local fv3 = fm:createFLV("Expection")
//很不期望
local expectionLow = fv3:addFuzzyLeftShoulder("low",0,20,40)
//一般期望
local expectionNormal = fv3:addFuzzyTriangle("normal",30,50,70)
//非常期望
local expectionVery = fv3:addFuzzyRightShoulder("very",60,80,100)

//向模糊模块中添加规则
fm:addRules({
	{closeTarget,expectionNormal},
	{mediumTarget,expectionVery},
	{farTarget,expectionLow},
	{bulletLittle,expectionLow},
	{bulletNormal,expectionNormal},
	{bulletMuch,expectionVery}
})
/*fm:addRules({
	//如果靠近且弹药充足，非常期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(closeTarget,bulletMuch),expectionVery},
	//如果靠近且弹药一般，一般期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(closeTarget,bulletNormal),expectionNormal},
	//如果靠近且弹药很少，很不期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(closeTarget,bulletLittle),expectionLow},
	//如果距离适中且弹药充足，非常期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(mediumTarget,bulletMuch),expectionVery},
	//如果距离适中且弹药一般，很不期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(mediumTarget,bulletNormal),expectionLow},
	//如果距离适中且弹药很少，很不期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(mediumTarget,bulletLittle),expectionLow},
	//如果距离远中且弹药充足，一般期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(farTarget,bulletMuch),expectionNormal},
	//如果距离远中且弹药一般，很不期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(farTarget,bulletNormal),expectionLow},
	//如果距离远中且弹药很少，很不期望
	{require("src.maxcore.ai.fuzzy.operate.FzoAnd").new(farTarget,bulletLittle),expectionLow},
})*/
local expectionValue = fm:calculate(
	//第一个参数是选顶模糊变量进行模糊计算
	{
		{name = "TargetDistance",value = 45},			//对距离就行模糊运算
		{name = "Bullet",value = 8},					//对弹药量进行模糊运算
	},
	//第二参数选定模糊变量进行反模糊化计算
	{{name = "Expection",method = 2}}					//通过规则对期望进行反模糊运算，method = 2采用中心点法的反模糊化计算
)
//以上过程通过目标距离和当前自身的健康状况，使用模糊计算，的出一个行动的期望值




