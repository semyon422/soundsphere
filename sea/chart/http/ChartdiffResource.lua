local IResource = require("web.framework.IResource")

---@class sea.ChartdiffResource: web.IResource
---@operator call: sea.ChartdiffResource
local ChartdiffResource = IResource + {}

ChartdiffResource.uri = "/chartdiffs/:chartdiff_id"

---@param chartdiffs sea.Chartdiffs
---@param views web.Views
function ChartdiffResource:new(chartdiffs, views)
	self.chartdiffs = chartdiffs
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function ChartdiffResource:GET(req, res, ctx)
	-- ctx.chartdiff = self.chartdiffs:getChartdiff(tonumber(ctx.path_params.chartdiff_id))
	-- if not ctx.chartdiff then
	-- 	res.status = 404
	-- 	self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
	-- 	return
	-- end
	self.views:render_send(res, "sea/chart/http/chartdiff.etlua", ctx, true)
end

return ChartdiffResource
