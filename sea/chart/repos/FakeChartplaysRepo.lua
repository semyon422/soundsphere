local IChartplaysRepo = require("sea.chart.repos.IChartplaysRepo")
local TestModel = require("rdb.TestModel")

---@class sea.FakeChartplaysRepo: sea.IChartplaysRepo
---@operator call: sea.FakeChartplaysRepo
local FakeChartplaysRepo = IChartplaysRepo + {}

function FakeChartplaysRepo:new()
	self.chartplays = TestModel()
end

---@param id integer
---@return sea.Chartplay?
function FakeChartplaysRepo:getChartplay(id)
	return self.chartplays:find({id = id})
end

---@return sea.Chartplay[]
function FakeChartplaysRepo:getChartplays()
	return self.chartplays:select()
end

---@param events_hash string
---@return sea.Chartplay?
function FakeChartplaysRepo:getChartplayByEventsHash(events_hash)
	return self.chartplays:find({events_hash = events_hash})
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function FakeChartplaysRepo:createChartplay(chartplay)
	return self.chartplays:create(chartplay)
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function FakeChartplaysRepo:updateChartplay(chartplay)
	return self.chartplays:update(chartplay, {id = chartplay.id})[1]
end

return FakeChartplaysRepo
