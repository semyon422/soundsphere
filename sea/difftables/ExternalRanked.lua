local class = require("class")

---@class sea.ExternalRanked
---@operator call: sea.ExternalRanked
local ExternalRanked = class()

---@param osu_beatmaps sea.OsuBeatmaps
---@param difftables sea.Difftables
function ExternalRanked:new(osu_beatmaps, difftables)
	self.osu_beatmaps = osu_beatmaps
	self.difftables = difftables
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
function ExternalRanked:submit(chartmeta)
	if not self:maybeRanked(chartmeta) then
		return
	end

	local osu_beatmaps = self.osu_beatmaps

	local beatmap = osu_beatmaps:getOrCreateOsuBeatmapByHash(chartmeta.hash)

	if beatmap.status == "missing" then
		return
	elseif beatmap.status == "ranked" then
		-- update osu ranked difftable
	end

end

return ExternalRanked
