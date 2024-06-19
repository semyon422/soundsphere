local IDiffcalc = require("sphere.models.DifficultyModel.IDiffcalc")

---@class sphere.NotesDiffcalc: sphere.IDiffcalc
---@operator call: sphere.NotesDiffcalc
local NotesDiffcalc = IDiffcalc + {}

NotesDiffcalc.name = "notes"
NotesDiffcalc.chartdiff_field = "notes_count"

---@param ctx sphere.DiffcalcContext
function NotesDiffcalc:compute(ctx)
	local notes = ctx:getSimplifiedNotes()

	local long_notes_count = 0
	for _, note in ipairs(notes) do
		if note.end_time then
			long_notes_count = long_notes_count + 1
		end
	end

	ctx.chartdiff.notes_count = #notes
	ctx.chartdiff.long_notes_count = long_notes_count
end

return NotesDiffcalc
