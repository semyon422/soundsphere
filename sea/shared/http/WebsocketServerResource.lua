local IResource = require("web.framework.IResource")
local Websocket = require("web.ws.Websocket")

---@class sea.WebsocketServerResource: web.IResource
---@operator call: sea.WebsocketServerResource
local WebsocketServerResource = IResource + {}

WebsocketServerResource.uri = "/ws"

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function WebsocketServerResource:GET(req, res, ctx)
	local ws = Websocket(req.soc, req, res, "server")

	function ws.protocol:text(payload, fin)
		self.ws:send("text", payload:reverse())
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

return WebsocketServerResource
