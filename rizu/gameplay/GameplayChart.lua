local class = require("class")

---@class rizu.GameplayChart
---@operator call: rizu.GameplayChart
local GameplayChart = class()

---@param config sphere.SettingsConfig
---@param fs fs.IFilesystem
---@param chartview table
function GameplayChart:new(config, fs, chartview)
	self.config = config
	self.fs = fs
	self.chartview = chartview
end

---@param replayBase sea.ReplayBase
---@param ctx sea.ComputeContext
function GameplayChart:load(replayBase, ctx)
	local chartview = self.chartview
	local config = self.config
	local fs = self.fs

	local data = assert(fs:read(chartview.location_path))
	assert(ctx:fromFileData(chartview.chartfile_name, data, chartview.index))
	ctx:applyModifierReorder(replayBase)
	ctx:computeBase(replayBase)

	ctx:applyTempo(config.gameplay.tempoFactor, config.gameplay.primaryTempo)
	if config.gameplay.autoKeySound then
		ctx:applyAutoKeysound()
	end
	if config.gameplay.swapVelocityType then
		ctx:swapVelocityType()
	end
end

return GameplayChart
