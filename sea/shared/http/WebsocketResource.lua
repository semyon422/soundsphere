local WebsocketPeer = require("icc.WebsocketPeer")
local Remote = require("icc.Remote")
local TaskHandler = require("icc.TaskHandler")
local IResource = require("web.framework.IResource")
local Websocket = require("web.ws.Websocket")
local Peer = require("sea.app.Peer")

---@class sea.WebsocketResource: web.IResource
---@operator call: sea.WebsocketResource
local WebsocketResource = IResource + {}

WebsocketResource.routes = {
	{"/ws", {
		GET = "server",
	}},
	{"/ws.html", {
		GET = "client",
	}},
}

---@param domain sea.Domain
---@param views web.Views
function WebsocketResource:new(domain, views)
	self.domain = domain
	self.views = views
	self.user_connections = domain.user_connections
	self.task_handler = self.user_connections.task_handler
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function WebsocketResource:server(req, res, ctx)
	local ws = Websocket(req.soc, req, res, "server")
	local peer = WebsocketPeer(ws)
	local task_handler = self.task_handler

	ws.max_payload_len = 1e7
	task_handler.timeout = 60

	local remote_ctx = Peer(task_handler, peer, ctx.session_user, ctx.ip, ctx.port, ctx.session)

	function ws.protocol:text(payload, fin)
		if not fin then return end

		local msg = peer:decode(payload)
		if not msg then return end

		local ok, err = xpcall(task_handler.handle, debug.traceback, task_handler, peer, remote_ctx, msg)
		if not ok then
			print("icc error ", err)
		end
	end

	local ok, err = ws:handshake()
	if not ok then
		res:send(tostring(err))
		return
	end

	self.domain:onConnect(remote_ctx)

	local co = ngx.thread.spawn(function()
		while true do
			local ok, err = xpcall(self.user_connections.processQueue, debug.traceback, self.user_connections, ctx.peer_id, remote_ctx.remote)
			if not ok then
				print("queue process error", err)
				break
			end
			ngx.sleep(0.01)
		end
	end)

	local ok, err = ws:loop()
	if not ok then
		print(err)
	end

	ngx.thread.kill(co)

	self.domain:onDisconnect(remote_ctx)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function WebsocketResource:client(req, res, ctx)
	local vc = "aqua/web/ws/test.html"
	ctx.url = "ws://127.0.0.1:8180/ws"
	local s = self.views:render(vc, ctx)

	res.headers:set("Content-Type", "text/html")
	res:send(s)
end

return WebsocketResource
