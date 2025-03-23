local IResource = require("web.framework.IResource")

---@class sea.DifftablesCreateResource: web.IResource
---@operator call: sea.DifftablesCreateResource
local DifftablesCreateResource = IResource + {}

DifftablesCreateResource.uri = "/difftables/create"

---@param difftables sea.Difftables
---@param views web.Views
function DifftablesCreateResource:new(difftables, views)
	self.difftables = difftables
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftablesCreateResource:GET(req, res, ctx)
	self.views:render_send(res, "sea/difftables/http/difftables_create.etlua", ctx, true)
end

return DifftablesCreateResource
