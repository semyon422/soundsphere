local class = require("class")

---@class rizu.GameplayChart
---@operator call: rizu.GameplayChart
local GameplayChart = class()

---@param config sphere.SettingsConfig
---@param replayBase sea.ReplayBase
---@param computeContext sea.ComputeContext
---@param fs fs.IFilesystem
---@param chartview table
function GameplayChart:new(
	config,
	replayBase,
	computeContext,
	fs,
	chartview
)
	self.config = config
	self.replayBase = replayBase
	self.computeContext = computeContext
	self.fs = fs
	self.chartview = chartview
end

function GameplayChart:load()
	local chartview = self.chartview
	local config = self.config
	local replayBase = self.replayBase
	local computeContext = self.computeContext
	local fs = self.fs

	local data = assert(fs:read(chartview.location_path))
	assert(computeContext:fromFileData(chartview.chartfile_name, data, chartview.index))
	computeContext:applyModifierReorder(replayBase)
	computeContext:computeBase(replayBase)

	computeContext:applyTempo(config.gameplay.tempoFactor, config.gameplay.primaryTempo)
	if config.gameplay.autoKeySound then
		computeContext:applyAutoKeysound()
	end
	if config.gameplay.swapVelocityType then
		computeContext:swapVelocityType()
	end
end

return GameplayChart
