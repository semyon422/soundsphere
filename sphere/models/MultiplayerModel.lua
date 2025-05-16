local class = require("class")
local delay = require("delay")
local thread = require("thread")
local enet = require("enet")

local icc_co = require("icc.co")
local EnetPeer = require("icc.EnetPeer")
local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local Remote = require("icc.Remote")

local MultiplayerClientRemote = require("sea.multi.remotes.MultiplayerClientRemote")
local MultiplayerClient = require("sea.multi.MultiplayerClient")

---@class sphere.MultiplayerModel
---@operator call: sphere.MultiplayerModel
local MultiplayerModel = class()

---@param cacheModel sphere.CacheModel
---@param rhythmModel sphere.RhythmModel
---@param configModel sphere.ConfigModel
---@param selectModel sphere.SelectModel
---@param onlineModel sphere.OnlineModel
---@param osudirectModel sphere.OsudirectModel
---@param replayBase sea.ReplayBase
function MultiplayerModel:new(cacheModel, rhythmModel, configModel, selectModel, onlineModel, osudirectModel, replayBase)
	self.cacheModel = cacheModel
	self.rhythmModel = rhythmModel
	self.configModel = configModel
	self.selectModel = selectModel
	self.onlineModel = onlineModel
	self.osudirectModel = osudirectModel
	self.replayBase = replayBase

	self.status = "disconnected"

	self.client = MultiplayerClient({}, replayBase)
	self.client_remote = MultiplayerClientRemote(self.client)

	local function remote_handler_transform(_, th, peer, obj, ...)
		---@type sea.IMultiplayerClientRemote
		local _obj = setmetatable({}, {__index = obj})
		_obj.remote = Remote(th, peer) --[[@as sea.MultiplayerServerRemote]]

		return _obj, ...
	end

	self.remote_handler = RemoteHandler(self.client_remote)
	self.remote_handler.transform = remote_handler_transform

	self.task_handler = TaskHandler(self.remote_handler)
	self.timeout = 60
end

---@param icc_peer icc.IPeer
---@param msg icc.Message
function MultiplayerModel:handle_msg(icc_peer, msg)
	local task_handler = self.task_handler

	if msg.ret then
		task_handler:handleReturn(msg)
	else
		task_handler:handleCall(icc_peer, msg)
	end

	task_handler:update()
end

---@param peer icc.IPeer
---@param msg icc.Message
function MultiplayerModel:handle_peer(peer, msg)
	local ok, err = xpcall(self.handle_msg, debug.traceback, self, peer, msg)
	if not ok then
		print("icc error ", err)
	end
end

function MultiplayerModel:load()
	self.host = enet.host_create()
	self.stopRefresh = delay.every(0.5, self.refreshAsync, self)
end

function MultiplayerModel:unload()
	self:disconnect()
	self.host:flush()
	self.host = nil
	self.stopRefresh()
end

function MultiplayerModel:refreshAsync()
	local remote = self.remote
	if not remote then
		return
	end

	self.client:refreshAsync()

	local chartplay_computed = self.rhythmModel:getChartplayComputed()
	remote.mp_user:setChartplayComputed(chartplay_computed)
end

local toipAsync = thread.async(function(host)
	local socket = require("socket")
	return socket.dns.toip(host)
end)

local connecting = false
function MultiplayerModel:connect()
	if connecting or self.status == "connecting" then
		return
	end
	self.status = "connecting"
	connecting = true
	local url = self.configModel.configs.urls.multiplayer
	local host, port = url:match("^(.+):(.-)$")
	local ip = toipAsync(host or "")
	local status, err = pcall(self.host.connect, self.host, ("%s:%s"):format(ip, port))
	if not status then
		self.status = err
		return
	end
	self.server = err
	connecting = false
end
MultiplayerModel.connect = icc_co.callwrap(MultiplayerModel.connect)

function MultiplayerModel:disconnect()
	if self.status == "connected" then
		self.server:disconnect()
		self.status = "disconnecting"
	end
end

MultiplayerModel.pushPlayContext = icc_co.callwrap(function(self)
	if not self.peer then return end
	self.peer._setModifiers(self.replayBase.modifiers)
	self.peer._setRate(self.replayBase.rate)
	self.peer._setConst(self.replayBase.const)
end)

MultiplayerModel.pushNotechart = icc_co.callwrap(function(self)
	if not self.peer then
		return
	end

	local chartview = self.selectModel.chartview
	if not chartview then
		return
	end

	self.chartview = chartview
	self.peer._setNotechart(chartview)
	self.peer._setNotechartFound(true)
end)

function MultiplayerModel:loginOfflineAsync()
	local user = self.configModel.configs.online.user

	local name = "username"
	if user and user.name then
		name = user.name
	end

	self.remote:loginOffline(name)
end

---@param peer_id string
---@param icc_peer icc.IPeer
function MultiplayerModel:peerconnected(peer_id, icc_peer)
	print("multiplayer connected")
	self.status = "connected"

	local server_remote = Remote(self.task_handler, icc_peer) --[[@as sea.MultiplayerServerRemote]]
	self.remote = server_remote
	self.client.server_remote = server_remote

	server_remote:print("hello", peer_id)

	self:loginOfflineAsync()
	self.client:pullUserAsync()
end
MultiplayerModel.peerconnected = icc_co.callwrap(MultiplayerModel.peerconnected)

---@param peer any
function MultiplayerModel:peerdisconnected(peer)
	print("disconnected")
	self.status = "disconnected"
end

function MultiplayerModel:update()
	if not self.server then
		return
	end

	local host = self.host
	local ok, event = pcall(host.service, host)
	while ok and event do
		if event.type == "connect" then
			local peer = EnetPeer(event.peer)
			self:peerconnected(tostring(event.peer), peer)
		elseif event.type == "disconnect" then
			self:peerdisconnected(tostring(event.peer))
		elseif event.type == "receive" then
			local peer = EnetPeer(event.peer)
			local msg = peer:decode(event.data)
			if msg then
				self:handle_peer(peer, msg)
			end
		end
		ok, event = pcall(host.service, host)
	end

	self.task_handler:update()
end

function MultiplayerModel:findNotechartAsync()
	local selectModel = self.selectModel

	local hash = self.room.notechart.hash or ""
	local index = self.room.notechart.index or 0

	print("find", hash, index)
	selectModel:findNotechart(hash, index)
	local items = selectModel.noteChartSetLibrary.items

	selectModel:setLock(false)

	self.downloadingBeatmap = nil
	local chartview = items[1]
	if chartview then
		self.chartview = chartview
		selectModel:setConfig(chartview)
		selectModel:pullNoteChartSet(true)
		self.peer.setNotechartFound(true)
		return
	end
	selectModel:setConfig({
		chartfile_set_id = 0,
		chartfile_id = 0,
		chartmeta_id = 0,
	})
	self.chartview = nil
	selectModel:pullNoteChartSet(true)
	self.peer.setNotechartFound(false)
end

MultiplayerModel.downloadNoteChart = icc_co.callwrap(function(self)
	local setId = self.room.notechart.osuSetId
	if self.downloadingBeatmap or not setId then
		return
	end

	self.downloadingBeatmap = {
		id = setId,
		status = "",
	}
	self.osudirectModel:downloadAsync(self.downloadingBeatmap)
	self.downloadingBeatmap.status = "done"
	self.peer.setNotechartFound(false)

	self.cacheModel:startUpdateAsync("downloads", 1)
	self:findNotechartAsync()
end)

return MultiplayerModel
