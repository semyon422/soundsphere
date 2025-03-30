local WebsocketPeer = require("icc.WebsocketPeer")
local TaskHandler = require("icc.TaskHandler")
local RemoteHandler = require("icc.RemoteHandler")
local Remote = require("icc.Remote")
local IResource = require("web.framework.IResource")
local Websocket = require("web.ws.Websocket")

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

local function remote_handler_transform(_, th, peer, obj, ...)
	local _obj = setmetatable({}, {__index = obj})
	_obj.remote = Remote(th, peer) --[[@as sea.ClientRemote]]
	_obj.user = (...) --[[@as sea.User]]
	---@cast _obj +sea.IServerRemote
	return _obj, select(2, ...)
end

---@param server_handler sea.ServerRemote
---@param views web.Views
function WebsocketResource:new(server_handler, views)
	self.remote_handler = RemoteHandler(server_handler)
	self.remote_handler.transform = remote_handler_transform
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function WebsocketResource:server(req, res, ctx)
	local ws = Websocket(req.soc, req, res, "server")
	local peer = WebsocketPeer(ws)
	local task_handler = TaskHandler(self.remote_handler)

	function ws.protocol:text(payload, fin)
		if not fin then return end

		local msg = peer:decode(payload)
		if not msg then return end

		if msg.ret then
			task_handler:handleReturn(msg)
		else
			msg:insert(ctx.session_user, 3)
			task_handler:handleCall(peer, msg)
		end
	end

	local ok, err = ws:handshake()
	if not ok then
		res:send(tostring(err))
		return
	end

	local ok, err = ws:loop()
	if not ok then
		print(err)
	end
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
