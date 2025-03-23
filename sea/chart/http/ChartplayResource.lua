local IResource = require("web.framework.IResource")

---@class sea.ChartplayResource: web.IResource
---@operator call: sea.ChartplayResource
local ChartplayResource = IResource + {}

ChartplayResource.uri = "/chartplays/:chartplay_id"

---@param chartplays sea.Chartplays
---@param views web.Views
function ChartplayResource:new(chartplays, views)
	self.chartplays = chartplays
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function ChartplayResource:GET(req, res, ctx)
	-- ctx.chartplay = self.chartplays:getChartplay(tonumber(ctx.path_params.chartplay_id))
	-- if not ctx.chartplay then
	-- 	res.status = 404
	-- 	self.views:render_send(res, "sea/shared/http/not_found.etlua", ctx, true)
	-- 	return
	-- end
	self.views:render_send(res, "sea/chart/http/chartplay.etlua", ctx, true)
end

return ChartplayResource
