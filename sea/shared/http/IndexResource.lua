local IResource = require("web.framework.IResource")

---@class sea.IndexResource: web.IResource
---@operator call: sea.IndexResource
local IndexResource = IResource + {}

IndexResource.uri = "/"

---@param views web.Views
function IndexResource:new(views)
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function IndexResource:GET(req, res, ctx)
	self.views:render_send(res, "sea/shared/http/index.etlua", ctx, true)
end

return IndexResource
