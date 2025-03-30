local IResource = require("web.framework.IResource")

---@class sea.ChartmetaResource: web.IResource
---@operator call: sea.ChartmetaResource
local ChartmetaResource = IResource + {}

ChartmetaResource.routes = {
	{"/chartmetas/:chartmeta_id", {
		GET = "getChartmeta",
	}},
}

---@param chartmetas sea.Chartmetas
---@param views web.Views
function ChartmetaResource:new(chartmetas, views)
	self.chartmetas = chartmetas
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function ChartmetaResource:getChartmeta(req, res, ctx)
	-- ctx.chartmeta = self.chartmetas:getChartmeta(tonumber(ctx.path_params.chartmeta_id))
	-- if not ctx.chartmeta then
	-- 	res.status = 404
	-- 	self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
	-- 	return
	-- end
	self.views:render_send(res, "sea/chart/http/chartmeta.etlua", ctx, true)
end

return ChartmetaResource
