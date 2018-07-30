--[[
*	转账记录 请求
*	分页请求，每页20个，不到20个就是尾页
*	端口号：1100
]]
local TransferRecordConnect = class("TransferRecordConnect",BaseConnect)
TransferRecordConnect.port = Port.PORT_NORMAL
TransferRecordConnect.type = 14

function TransferRecordConnect:ctor(pageIndex,callback)
	self.pageIndex = pageIndex
	self.callback = callback
end
function TransferRecordConnect:writeData(data)
	data:writeInt(self.pageIndex) 
end
function TransferRecordConnect:readData(data)
	local result = data:readUnsignedByte()
	local records = {}
	if result ~= 0 then
		self:showTips(result)
	else
		local len = data:readByte()
		for i = 1,len do
			records[i] = {
				type = data:readByte(),		--0转入，1转出
				fromID = data:readInt(),
				toID = data:readInt(),
				gold = data:readLong(),
				date = data:readInt()
			}
		end
	end
	self.params = {result = result,records = records}
end

return TransferRecordConnect