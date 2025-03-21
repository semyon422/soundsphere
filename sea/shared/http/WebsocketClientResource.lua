local IResource = require("web.framework.IResource")

---@class sea.WebsocketClientResource: web.IResource
---@operator call: sea.WebsocketClientResource
local WebsocketClientResource = IResource + {}

WebsocketClientResource.uri = "/ws.html"

---@param views web.Views
function WebsocketClientResource:new(views)
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function WebsocketClientResource:GET(req, res, ctx)
	local vc = "aqua/web/ws/test.html"
	ctx.url = "ws://127.0.0.1:8180/ws"
	local s = self.views:render(vc, ctx)

	res.headers:set("Content-Type", "text/html")
	res:send(s)
end

return WebsocketClientResource
