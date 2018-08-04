--[[
*	游戏管理
*	@author lqh
]]
local GameMgr = class("GameMgr")

function GameMgr:ctor()
	--已经初始化大厅记录
	self.m_hallInitStatus = 0
--	self.m_hallInitStatus = 2 + 4 + 6
	--大厅各类游戏人数
	self.m_gameHallPlayersCount = {
		[ST.TYPE_GAMEHALL_1] = 0,
		[ST.TYPE_GAMEHALL_2] = 0,
		[ST.TYPE_GAMEHALL_3] = 0,
	}
	--正在下载的游戏
	self.on_downloadGame = nil
	
	self:init()
end
function GameMgr:init()
	self.m_gamedatas = {}
	for k,v in pairs(require("src.app.config.game_define_config")) do
		self.m_gamedatas[k] = require("src.app.data.game.GameData").new(k)
	end
end

function GameMgr:updateGameHallPlayersCount(data)
	CommandCenter:sendEvent(ST.COMMAND_GAME_HALL_PLAYERS_UPDATE)
end
function GameMgr:getGameHallPlayersCount(gametype)
	return self.m_gameHallPlayersCount[gametype]
end
--是否初始化该大厅
function GameMgr:isInitGameHall(grouptype)
	return math.band(self.m_hallInitStatus,math.pow(2,grouptype)) ~= 0
end
function GameMgr:getGame(sid)
	return self.m_gamedatas[sid]
end

--获取同一类型的所有开放游戏
function GameMgr:getGames(grouptype)
	grouptype = grouptype or 0
	local backlist = {}
	for k,v in pairs(self.m_gamedatas) do
		if v.group == grouptype and v:isopen() then
			table.insert(backlist,v)
		end
	end
	table.sort(backlist,function(a,b) return b.order < a.order end)
	return backlist
end
--下载游戏资源
function GameMgr:downloadResrouce(data)
	
	if self.on_downloadGame then
		display.showMsg(display.trans("##2037",self.on_downloadGame.name))
		return 
	end

	if data:isdownload() then return end
	
	self.on_downloadGame = data
	-- data.url = "http://220.128.128.40:8001/hotupdate/hall_0_0_0.zip"
	mlog(data.sid,"=============-----")
	require("src.base.http.HttpRequest").postJSON(require("src.app.config.server.server_config").apihost..'res/game', {
		['sid'] = data.sid
		}, function(result, retgamedata)
			if result ~=0 then
				--请求失败
				mlog(DEBUG_S,"<GameMgr>: downloadResrouce url fail!!")
				return
			end
			mlog(result.."result......")
			mlog("retgamedata.url ",retgamedata.data.url)
			data.url = retgamedata.data.url
			mlog("data.url ",data.url)
			if data.url then
				self:on_download(data)
			else
				ConnectMgr.connect("gamehall.GetGameZipAddressConnect",data,function(result) 
					if result ~= 0 then return end
					self:on_download(data)
				end)
			end

	end)

end
function GameMgr:on_download(data)
	display.showMsg(display.trans("##2062",data.name))
	require("src.base.tools.zipdownload").download(data.url,
		function()
			--下载并解压完成
			display.showMsg(display.trans("##2038",data.name))
			self.on_downloadGame = nil
			
			local values = string.splitNumber(require("src.base.tools.storage").getXML("gamedownload_type"))
			table.insert(values,data.sid)
			require("src.base.tools.storage").saveXML("gamedownload_type", table.concat(values,","))
			CommandCenter:sendEvent(ST.COMMAND_GAME_DOWNLOAD,{data = data,type = 0})
			if(data.gameimgs)then
				require("src.base.tools.openglTools").resetProgram(data.gameimgs.bg)
				require("src.base.tools.openglTools").resetProgram(data.gameimgs.icon)
			end

		end,
		function(percent)
			--下载中
			CommandCenter:sendEvent(ST.COMMAND_GAME_DOWNLOAD,{data = data,type = 1,progress = math.ceil(percent)})
		end,
		function(errorCode)
			self.on_downloadGame = nil
			--下载出错
			CommandCenter:sendEvent(ST.COMMAND_GAME_DOWNLOAD,{data = data,type = 2,code = errorCode})
		end
	)
end
--重置所有游戏数据
function GameMgr:reset()
	self.m_hallInitStatus = 0
	for k,v in pairs(self.m_gamedatas) do
		v:updateStatus(ST.TYPE_GAME_CLOSE)
	end
end
--override
function GameMgr:bytesRead(data,grouptype)
	local games = {}
	for k,v in pairs(self.m_gamedatas) do
		if v.group == grouptype then
			games[k] = v
		end
	end
	
	local sizelen = data:readByte()
	for i = 1,sizelen do
		local sid = data:readUnsignedShort()
		if games[sid] then
			games[sid]:updateStatus(ST.TYPE_GAME_OPEN)
			games[sid] = nil
		end
	end
	
	for k,v in pairs(games) do
		--未开启的则设置为关闭
		v:updateStatus(ST.TYPE_GAME_CLOSE)
	end

	self.m_hallInitStatus = self.m_hallInitStatus + math.pow(2,grouptype)
end

return GameMgr