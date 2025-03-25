local IResource = require("web.framework.IResource")

---@class sea.DifftableResource: web.IResource
---@operator call: sea.DifftableResource
local DifftableResource = IResource + {}

DifftableResource.uri = "/difftables/:difftable_id"

---@param difftables sea.Difftables
---@param views web.Views
function DifftableResource:new(difftables, views)
	self.difftables = difftables
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftableResource:GET(req, res, ctx)
	ctx.difftable = self.difftables:getDifftable(tonumber(ctx.path_params.difftable_id))
	if not ctx.difftable then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end
	self.views:render_send(res, "sea/difftables/http/difftable.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftableResource:DELETE(req, res, ctx)
	local difftable_id = tonumber(ctx.path_params.difftable_id)

	if difftable_id then
		self.difftables:delete(ctx.session_user, difftable_id)
	end

	res.status = 302
	res.headers:set("HX-Location", "/difftables")
end

return DifftableResource
