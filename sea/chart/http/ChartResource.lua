local IResource = require("web.framework.IResource")
local ChartPage = require("sea.chart.http.ChartPage")
local Chartplay = require("sea.chart.Chartplay")

---@class sea.ChartResource: web.IResource
---@operator call: sea.ChartResource
local ChartResource = IResource + {}

ChartResource.routes = {
	{"/charts/:id", {
		GET = "getPage",
	}},
}

---@param views web.Views
function ChartResource:new(views)
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function ChartResource:getPage(req, res, ctx)
	local chartmeta = {
		artist = "Artist not unicode",
		artist_unicode = "Artist unicode",
		title = "Title not unicode",
		title_unicode = "Title unicode",
		creator = "Creator",
		name = "Diff",
		source = "Source",
		inputmode = "4key",
		tempo = 120,
		tempo_avg = 120,
		tempo_min = 60,
		tempo_max = 240
	}

	local cpv = Chartplay()
	cpv.accuracy = 0.944
	cpv.judges = {2847, 847, 341, 13, 0}
	cpv.not_perfect_count = 1337
	cpv.miss_count = 9
	cpv.rating = 20
	cpv.rating_pp = 400
	cpv.rating_msd = 27
	cpv.modifiers = {}
	cpv.rate = 1.2
	cpv.const = false
	cpv.tap_only = false
	cpv.submitted_at = 1747465769

	local chartplays = {cpv}

	ctx.chart_page = ChartPage(ctx.session_user, chartmeta, chartplays)

	self.views:render_send(res, "sea/chart/http/chart.etlua", ctx, true)
end

return ChartResource
