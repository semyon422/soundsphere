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
	local _obj = setmetatable({}, {__index = obj}) --[[@as sea.IServerRemote]]
	_obj.remote = Remote(th, peer) --[[@as sea.ClientRemote]]
	_obj.user = select(1, ...) --[[@as sea.User]]
	_obj.session = select(2, ...) --[[@as sea.Session]]
	---@cast _obj +sea.IServerRemote
	return _obj, select(3, ...)
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

	---@param msg icc.Message
	local function handle_msg(msg)
		if msg.ret then
			task_handler:handleReturn(msg)
		else
			msg:insert(ctx.session_user, 3)
			msg:insert(ctx.session, 4)
			task_handler:handleCall(peer, msg)
		end
	end

	function ws.protocol:text(payload, fin)
		if not fin then return end

		local msg = peer:decode(payload)
		if not msg then return end

		local ok, err = xpcall(handle_msg, debug.traceback, msg)
		if not ok then
			print("icc error ", err)
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
