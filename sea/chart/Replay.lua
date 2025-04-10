local ChartplayBase = require("sea.chart.ChartplayBase")
local json = require("json")
local ReplayNanoChart = require("sphere.models.ReplayModel.ReplayNanoChart")
-- local ReplayConverter = require("sphere.models.ReplayModel.ReplayConverter")
local TimingsDefiner = require("sea.timings.TimingsDefiner")
local Timings = require("sea.chart.Timings")
local Subtimings = require("sea.chart.Subtimings")

---@class sea.Replay: sea.ChartplayBase
---@operator call: sea.Replay
---@field timing_values sea.TimingValues for backward compatibility
---@field events string encoded
---@field created_at integer
local Replay = ChartplayBase + {}

---@return true?
---@return string|util.Errors?
function Replay:validate()
	return true
end

---@param s string
---@return sea.Replay?
---@return string?
function Replay.decode(s)
	return Replay()
end

---@param replay sea.Replay
---@return string
function Replay.encode(replay)
	return ""
end

return Replay
