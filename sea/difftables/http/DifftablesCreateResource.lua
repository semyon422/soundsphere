local http_util = require("web.http.util")
local IResource = require("web.framework.IResource")
local Difftable = require("sea.difftables.Difftable")

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

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftablesCreateResource:POST(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		return
	end

	local dt = Difftable()

	dt.name = body_params.name
	dt.symbol = body_params.symbol
	dt.description = body_params.description

	ctx.difftable = dt

	local valid, errs = dt:validate()
	if not valid then
		ctx.errors = errs
		self.views:render_send(res, "sea/difftables/http/difftables_create.etlua", ctx, true)
		return
	end

	local difftable, err = self.difftables:create(ctx.session_user, dt)
	if not difftable then
		ctx.errors = {err}
		self.views:render_send(res, "sea/difftables/http/difftables_create.etlua", ctx, true)
		return
	end

	res.status = 302
	res.headers:set("Location", "/difftables/" .. difftable.id)
end

return DifftablesCreateResource
