local IResource = require("web.framework.IResource")

---@class sea.DifftableEditResource: web.IResource
---@operator call: sea.DifftableEditResource
local DifftableEditResource = IResource + {}

DifftableEditResource.uri = "/difftables/:difftable_id/edit"

---@param difftables sea.Difftables
---@param views web.Views
function DifftableEditResource:new(difftables, views)
	self.difftables = difftables
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftableEditResource:GET(req, res, ctx)
	ctx.difftable = self.difftables:getDifftable(tonumber(ctx.path_params.difftable_id))
	if not ctx.difftable then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end
	self.views:render_send(res, "sea/difftables/http/difftable_edit.etlua", ctx, true)
end

return DifftableEditResource
