local IDiffcalc = require("sphere.models.DifficultyModel.IDiffcalc")

---@class sphere.NotesDiffcalc: sphere.IDiffcalc
---@operator call: sphere.NotesDiffcalc
local NotesDiffcalc = IDiffcalc + {}

NotesDiffcalc.name = "notes"
NotesDiffcalc.chartdiff_field = "notes_count"

---@param ctx sphere.DiffcalcContext
function NotesDiffcalc:compute(ctx)
	local notes = ctx:getSimplifiedNotes()

	local min_time = math.huge
	local max_time = -math.huge

	local short_notes_count = 0
	local long_notes_count = 0
	for _, note in ipairs(notes) do
		min_time = math.min(min_time, note.time, note.end_time or note.time)
		max_time = math.max(max_time, note.time, note.end_time or note.time)
		if note.end_time then
			long_notes_count = long_notes_count + 1
		else
			short_notes_count = short_notes_count + 1
		end
	end

	if min_time == math.huge then
		min_time, max_time = 0, 0
	end

	local chartdiff = ctx.chartdiff

	chartdiff.notes_count = #notes
	chartdiff.judges_count = short_notes_count + long_notes_count * 2

	-- TODO: fix for other note types
	chartdiff.note_types_count = {
		tap = short_notes_count,
		hold = long_notes_count,
	}

	chartdiff.start_time = min_time
	chartdiff.duration = max_time - min_time

	-- stubs for future fields
	chartdiff.density_data = {}
	chartdiff.sv_data = {}
	chartdiff.user_diff = chartdiff.user_diff or 0
	chartdiff.user_diff_data = chartdiff.user_diff_data or ""
end

return NotesDiffcalc
