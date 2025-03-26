local table_util = require("table_util")
local json = require("web.json")
local http_util = require("web.http.util")
local IResource = require("web.framework.IResource")
local Leaderboard = require("sea.leaderboards.Leaderboard")
local LeaderboardDifftable = require("sea.leaderboards.LeaderboardDifftable")

---@class sea.LeaderboardEditResource: web.IResource
---@operator call: sea.LeaderboardEditResource
local LeaderboardEditResource = IResource + {}

LeaderboardEditResource.uri = "/leaderboards/:leaderboard_id/edit"

---@param leaderboards sea.Leaderboards
---@param views web.Views
function LeaderboardEditResource:new(leaderboards, views)
	self.leaderboards = leaderboards
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LeaderboardEditResource:GET(req, res, ctx)
	ctx.leaderboard = self.leaderboards:getLeaderboard(tonumber(ctx.path_params.leaderboard_id))
	if not ctx.leaderboard then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end
	self.views:render_send(res, "sea/leaderboards/http/leaderboard_edit.etlua", ctx, true)
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function LeaderboardEditResource:POST(req, res, ctx)
	local body_params, err = http_util.get_form(req)
	if not body_params then
		res.status = 400
		return
	end

	local leaderboard_id = tonumber(ctx.path_params.leaderboard_id)
	if not leaderboard_id then
		res.status = 404
		self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
		return
	end

	local lb = Leaderboard()

	lb.id = leaderboard_id
	lb.name = body_params.name
	lb.description = body_params.description

	lb.rating_calc = body_params.rating_calc
	lb.scores_comb = body_params.scores_comb
	lb.scores_comb_count = tonumber(body_params.scores_comb_count) or 0

	lb.nearest = body_params.nearest
	lb.result = body_params.result
	lb.allow_custom = body_params.allow_custom == "on"
	lb.allow_const = body_params.allow_const == "on"
	lb.allow_pause = body_params.allow_pause == "on"
	lb.allow_reorder = body_params.allow_reorder == "on"
	lb.allow_modifiers = body_params.allow_modifiers == "on"
	lb.allow_tap_only = body_params.allow_tap_only == "on"
	lb.allow_free_timings = body_params.allow_free_timings == "on"
	lb.allow_free_healths = body_params.allow_free_healths == "on"
	lb.mode = body_params.mode
	lb.rate = json.decode_safe(body_params.rate)
	lb.chartmeta_inputmode = json.decode_safe(body_params.chartmeta_inputmode)
	lb.chartdiff_inputmode = json.decode_safe(body_params.chartdiff_inputmode)

	local difftable_ids = json.decode_safe(body_params.difftable_ids)
	if type(difftable_ids) ~= "table" then
		difftable_ids = {}
	end
	---@cast difftable_ids integer[]
	for _, id in ipairs(difftable_ids) do
		local lb_dt = LeaderboardDifftable()
		lb_dt.difftable_id = id
		table.insert(lb.leaderboard_difftables, lb_dt)
	end

	ctx.leaderboard = lb

	local valid, errs = lb:validate()
	if not valid then
		ctx.errors = errs
		self.views:render_send(res, "sea/leaderboards/http/leaderboard_edit.etlua", ctx, true)
		return
	end

	local leaderboard, err = self.leaderboards:update(ctx.session_user, leaderboard_id, lb)
	if not leaderboard then
		ctx.errors = {err}
		self.views:render_send(res, "sea/leaderboards/http/leaderboard_edit.etlua", ctx, true)
		return
	end

	res.status = 302
	res.headers:set("Location", "/leaderboards/" .. leaderboard.id)
end

return LeaderboardEditResource
