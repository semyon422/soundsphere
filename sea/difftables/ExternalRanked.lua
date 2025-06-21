local class = require("class")
local DifftableChartmeta = require("sea.difftables.DifftableChartmeta")

---@class sea.ExternalRanked
---@operator call: sea.ExternalRanked
local ExternalRanked = class()

---@param osu_beatmaps sea.OsuBeatmaps
---@param difftables_repo sea.DifftablesRepo
function ExternalRanked:new(osu_beatmaps, difftables_repo)
	self.osu_beatmaps = osu_beatmaps
	self.difftables_repo = difftables_repo
end

---@param cm sea.Chartmeta
---@return boolean?
function ExternalRanked:maybeRanked(cm)
	if cm.format == "osu" then
		local id = cm.osu_beatmap_id
		local sid = cm.osu_beatmapset_id
		return id and sid and id > 0 and sid > 0
	end
end

---@param chartmeta sea.Chartmeta
---@param time integer
function ExternalRanked:submit(chartmeta, time)
	local difftables_repo = self.difftables_repo
	local osu_beatmaps = self.osu_beatmaps

	if not self:maybeRanked(chartmeta) then
		return
	end

	local osu_difftable = difftables_repo:getDifftableByTag("osu")
	if not osu_difftable then
		return
	end

	local dt_cm = difftables_repo:getDifftableChartmeta(osu_difftable.id, chartmeta.hash, chartmeta.index)
	if dt_cm then
		return
	end

	local beatmap = osu_beatmaps:getOrCreateOsuBeatmapByHash(chartmeta.hash, time)

	if beatmap and beatmap.status == "ranked" then
		dt_cm = DifftableChartmeta()
		dt_cm.user_id = 0
		dt_cm.difftable_id = osu_difftable.id
		dt_cm.hash = chartmeta.hash
		dt_cm.index = chartmeta.index
		dt_cm.level = 0
		dt_cm.created_at = time

		self.difftables_repo:createDifftableChartmeta(dt_cm)
	end
end

return ExternalRanked
