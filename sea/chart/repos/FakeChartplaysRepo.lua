local IChartplaysRepo = require("sea.chart.repos.IChartplaysRepo")

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
	for _, p in ipairs(self.chartplays) do
		if p.id == id then
			return p
		end
	end
end

---@return sea.Chartplay[]
function FakeChartplaysRepo:getChartplays()
	return self.chartplays
end

---@param events_hash string
---@return sea.Chartplay?
function FakeChartplaysRepo:getChartplayByEventsHash(events_hash)
	for _, p in ipairs(self.chartplays) do
		if p.events_hash == events_hash then
			return p
		end
	end
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function FakeChartplaysRepo:createChartplay(chartplay)
	table.insert(self.chartplays, chartplay)
	chartplay.id = #self.chartplays
	return chartplay
end

return FakeChartplaysRepo
