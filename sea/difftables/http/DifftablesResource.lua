local IResource = require("web.framework.IResource")
local http_util = require("web.http.util")
local Difftable = require("sea.difftables.Difftable")

---@class sea.DifftablesResource: web.IResource
---@operator call: sea.DifftablesResource
local DifftablesResource = IResource + {}

DifftablesResource.routes = {
	{"/difftables", {
		GET = "getDifftables",
	}},
	{"/difftables/create", {
		GET = "getCreateDifftable",
		POST = "createDifftable",
	}},
}

---@param difftables sea.Difftables
---@param views web.Views
function DifftablesResource:new(difftables, views)
	self.difftables = difftables
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftablesResource:getDifftables(req, res, ctx)
	ctx.difftables = self.difftables:getDifftables()
	self.views:render_send(res, "sea/difftables/http/difftables.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftablesResource:getCreateDifftable(req, res, ctx)
	self.views:render_send(res, "sea/difftables/http/difftables_create.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftablesResource:createDifftable(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		return
	end

	local dt = Difftable()

	dt.name = body_params.name
	dt.symbol = body_params.symbol
	dt.description = body_params.description
	dt.tag = body_params.tag
	if dt.tag == "" then
		dt.tag = nil
	end

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

return DifftablesResource
