local IResource = require("web.framework.IResource")

---@class sea.DownloadResource: web.IResource
---@operator call: sea.DownloadResource
local DownloadResource = IResource + {}

DownloadResource.routes = {
	{"/download", {
		GET = "getPage",
	}},
}

---@param views web.Views
function DownloadResource:new(views)
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DownloadResource:getPage(req, res, ctx)
	self.views:render_send(res, "sea/shared/http/download.html", ctx, true)
end

return DownloadResource
