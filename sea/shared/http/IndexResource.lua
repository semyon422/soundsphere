local IResource = require("web.framework.IResource")

---@class sea.IndexResource: web.IResource
---@operator call: sea.IndexResource
local IndexResource = IResource + {}

IndexResource.routes = {
	{"/", {
		GET = "getIndex",
	}},
}

---@param views web.Views
function IndexResource:new(views)
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function IndexResource:getIndex(req, res, ctx)
	ctx.ignore_footer = true
	ctx.ignore_main_container = true
	self.views:render_send(res, "sea/shared/http/index.etlua", ctx, true)
end

return IndexResource
