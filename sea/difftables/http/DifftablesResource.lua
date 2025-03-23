local IResource = require("web.framework.IResource")

---@class sea.DifftablesResource: web.IResource
---@operator call: sea.DifftablesResource
local DifftablesResource = IResource + {}

DifftablesResource.uri = "/difftables"

---@param difftables sea.Difftables
---@param views web.Views
function DifftablesResource:new(difftables, views)
	self.difftables = difftables
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftablesResource:GET(req, res, ctx)
	ctx.difftables = self.difftables:getDifftables()
	self.views:render_send(res, "sea/difftables/http/difftables.etlua", ctx, true)
end

return DifftablesResource
