local IChartplaysRepo = require("sea.chart.repos.IChartplaysRepo")
local table_util = require("table_util")

---@class sea.FakeChartplaysRepo: sea.IChartplaysRepo
---@operator call: sea.FakeChartplaysRepo
local FakeChartplaysRepo = IChartplaysRepo + {}

function FakeChartplaysRepo:new()
	---@type sea.Chartplay[]
	self.chartplays = {}
end

---@param id integer
---@return sea.Chartplay?
function FakeChartplaysRepo:getChartplay(id)
	return table_util.value_by_field(self.chartplays, "id", id)
end

---@return sea.Chartplay[]
function FakeChartplaysRepo:getChartplays()
	return self.chartplays
end

---@param events_hash string
---@return sea.Chartplay?
function FakeChartplaysRepo:getChartplayByEventsHash(events_hash)
	return table_util.value_by_field(self.chartplays, "events_hash", events_hash)
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function FakeChartplaysRepo:createChartplay(chartplay)
	table.insert(self.chartplays, chartplay)
	chartplay.id = #self.chartplays
	return chartplay
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function FakeChartplaysRepo:updateChartplay(chartplay)
	local _chartplay = table_util.value_by_field(self.chartplays, "id", chartplay.id)
	table_util.copy(chartplay, _chartplay)
	return _chartplay
end

return FakeChartplaysRepo
