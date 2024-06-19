local class = require("class")
local table_util = require("table_util")
local simplify_notechart = require("libchart.simplify_notechart")

---@class sphere.DiffcalcContext
---@operator call: sphere.DiffcalcContext
local DiffcalcContext = class()

---@param chartdiff table
---@param chart ncdk2.Chart
---@param rate number
function DiffcalcContext:new(chartdiff, chart, rate)
	self.chartdiff = chartdiff
	self.chart = chart
	self.rate = rate
end

---@return table
function DiffcalcContext:getSimplifiedNotes()
	return table_util.get_or_create(self, "notes", simplify_notechart, self.chart)
end

return DiffcalcContext
