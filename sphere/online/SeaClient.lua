local class = require("class")
local delay = require("delay")
local ThreadRemote = require("threadremote.ThreadRemote")

local SphereWebsocket = require("sphere.online.SphereWebsocket")

local Subprotocol = require("web.ws.Subprotocol")

local WebsocketPeer = require("icc.WebsocketPeer")
local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local Remote = require("icc.Remote")

---@class sphere.SeaClient
---@operator call: sphere.SeaClient
local SeaClient = class()

SeaClient.threaded = true
SeaClient.reconnect_interval = 30

---@param client sphere.OnlineClient
---@param client_remote sea.ClientRemote
function SeaClient:new(client, client_remote)
	self.client = client

	self.protocol = Subprotocol()
	self.remote_handler = RemoteHandler(client_remote)

	function self.remote_handler:transform(th, peer, obj, ...)
		local _obj = setmetatable({}, {__index = obj})
		_obj.remote = Remote(th, peer) --[[@as sea.ServerRemote]]
		---@cast _obj +sea.IClientRemote
		return _obj, ...
	end

	local server_peer = WebsocketPeer({send = function() return nil, "not connected" end})
	self.server_peer = server_peer

	local task_handler = TaskHandler(self.remote_handler)
	self.task_handler = task_handler

	task_handler.timeout = 60

	local remote = Remote(self.task_handler, self.server_peer)
	---@cast remote -icc.Remote, +sea.ServerRemote
	self.remote = remote

	function self.protocol:text(payload, fin)
		if not fin then return end

		local msg = server_peer:decode(payload)
		if not msg then return end

		if msg.ret then
			task_handler:handleReturn(msg)
		else
			task_handler:handleCall(server_peer, msg)
		end

		task_handler:update()
	end

	self.connected = false
end

---@param url string
---@param on_connect function
function SeaClient:load(url, on_connect)
	self.url = url

	if not self.threaded then
		self.sphws = SphereWebsocket()
		self.sphws.protocol = self.protocol
		self.sphws_ret = self.sphws
	else
		local thread_remote = ThreadRemote("websocket", self.protocol)
		self.thread_remote = thread_remote
		thread_remote:start(function(protocol)
			local SphereWebsocket = require("sphere.online.SphereWebsocket")
			local sphws = SphereWebsocket(url)
			sphws.protocol = -protocol --[[@as web.Subprotocol]]
			return sphws
		end)
		local sphws = -thread_remote.remote
		local sphws_ret = thread_remote.remote
		---@cast sphws -icc.Remote, +sphere.SphereWebsocket
		---@cast sphws_ret -icc.Remote, +sphere.SphereWebsocket
		self.sphws = sphws
		self.sphws_ret = sphws_ret
	end

	self.reconnect_thread = coroutine.create(function()
		while true do
			local state = self.sphws_ret:getState()
			if state ~= "open" then
				self.client:setUser()
				print("connecting to websocket")
				local ok, err = self.sphws_ret:connect(url)
				if not ok then
					self.connected = false
					print("connection failed", err)
					delay.sleep(self.reconnect_interval)
				else
					self.connected = true
					self.server_peer.ws = self.sphws_ret.ws
					print("connected")
					on_connect()
					self.client:setUser(self.remote:getUser())
				end
			end
			delay.sleep(1)
		end
	end)
	assert(coroutine.resume(self.reconnect_thread))

	self.ping_thread = coroutine.create(function()
		while true do
			local state = self.sphws_ret:getState()
			if state == "open" then
				self.sphws_ret.ws:send("ping")
			end
			delay.sleep(10)
		end
	end)
	assert(coroutine.resume(self.ping_thread))
end

function SeaClient:update()
	if self.thread_remote then
		self.thread_remote:update()
	end
	if self.sphws then
		self.sphws:update()
	end
end

return SeaClient
