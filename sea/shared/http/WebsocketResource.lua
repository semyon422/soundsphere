local WebsocketPeer = require("icc.WebsocketPeer")
local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local Remote = require("icc.Remote")
local IResource = require("web.framework.IResource")
local Websocket = require("web.ws.Websocket")
local ClientRemoteValidation = require("sea.app.remotes.ClientRemoteValidation")

local whitelist = require("sea.app.remotes.whitelist")

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

---@param server_handler sea.ServerRemote
---@param views web.Views
---@param user_connections sea.UserConnections
function WebsocketResource:new(server_handler, views, user_connections)
	self.remote_handler = RemoteHandler(server_handler, whitelist)
	self.views = views
	self.user_connections = user_connections
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function WebsocketResource:server(req, res, ctx)
	local ws = Websocket(req.soc, req, res, "server")
	local peer = WebsocketPeer(ws)
	local task_handler = TaskHandler(self.remote_handler)

	ws.max_payload_len = 1e7
	task_handler.timeout = 60

	local remote_ctx = {
		remote = ClientRemoteValidation(Remote(task_handler, peer)),
		user = ctx.session_user,
		session = ctx.session,
		ip = ctx.ip,
		port = ctx.port,
	}

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

	self.user_connections:onConnect(remote_ctx.ip, remote_ctx.port, remote_ctx.user.id)

	local ok, err = ws:loop()
	if not ok then
		print(err)
	end

	self.user_connections:onDisconnect(remote_ctx.ip, remote_ctx.port, remote_ctx.user.id)
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
