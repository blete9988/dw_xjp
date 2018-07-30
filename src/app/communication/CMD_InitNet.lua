local T={}

function T:def()
	self._url = ""
	self._completeCallback=nil
end

function T:exec(url,callback)
	self._url = url
	self._completeCallback=callback

	self:getSecretsKey()
end

function T:getSecretsKey()
	ConnectMgr.connect("src.app.connect.gamehall.ServerKeyConnect" , function(code)
--		self._completeCallback(1)
	
		if code ~= 0 then
			--错误信息已被处理
			return
		end

		self:connectServer()
	end)
end

function T:connectServer()
	local socketID = require("src.app.connect.LoginManager").createSocket(self._url,function(socketID)
		print(socketID)
		self._completeCallback(socketID)
	end)

	if socketID < 0 then
		print("socket 小于0了！！！！！！！！！！！！！！！")
		return
	end
	ConnectMgr.saveSocketID(self._url,socketID)
end

return T
