local http_util = require("web.http.util")
local IResource = require("web.framework.IResource")
local Difftable = require("sea.difftables.Difftable")

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

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function DifftableEditResource:POST(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		return
	end

	local difftable_id = tonumber(ctx.path_params.difftable_id)
	if not difftable_id then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local dt = Difftable()

	dt.name = body_params.name
	dt.description = body_params.description
	dt.symbol = body_params.symbol

	ctx.difftable = dt

	local valid, errs = dt:validate()
	if not valid then
		ctx.errors = errs
		self.views:render_send(res, "sea/difftables/http/difftable_edit.etlua", ctx, true)
		return
	end

	local difftable, err = self.difftables:update(ctx.session_user, difftable_id, dt)
	if not difftable then
		ctx.errors = {err}
		self.views:render_send(res, "sea/difftables/http/difftable_edit.etlua", ctx, true)
		return
	end

	res.status = 302
	res.headers:set("Location", "/difftables/" .. difftable.id)
end

return DifftableEditResource
