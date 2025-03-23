local IResource = require("web.framework.IResource")

---@class sea.ChartsResource: web.IResource
---@operator call: sea.ChartsResource
local ChartsResource = IResource + {}

ChartsResource.uri = "/charts"

---@param charts sea.Charts
---@param views web.Views
function ChartsResource:new(charts, views)
	self.charts = charts
	self.views = views
end

---@param req web.IRequest
---@param res web.IResponse
---@param ctx sea.RequestContext
function ChartsResource:GET(req, res, ctx)
	-- ctx.charts = self.charts:getCharts()
	self.views:render_send(res, "sea/chart/http/charts.etlua", ctx, true)
end

return ChartsResource
