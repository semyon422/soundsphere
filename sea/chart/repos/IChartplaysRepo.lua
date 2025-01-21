local class = require("class")

---@class sea.IChartplaysRepo
---@operator call: sea.IChartplaysRepo
local IChartplaysRepo = class()

---@return sea.Chartplay[]
function IChartplaysRepo:getChartplays()
	return {}
end

---@param id integer
---@return sea.Chartplay?
function IChartplaysRepo:getChartplay(id)
	return {}
end

---@param events_hash string
---@return sea.Chartplay?
function IChartplaysRepo:getChartplayByEventsHash(events_hash)
	return {}
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function IChartplaysRepo:createChartplay(chartplay)
	return chartplay
end

---@param chartplay sea.Chartplay
---@return sea.Chartplay
function IChartplaysRepo:updateChartplay(chartplay)
	return chartplay
end

return IChartplaysRepo
