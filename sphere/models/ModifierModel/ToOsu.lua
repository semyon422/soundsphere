local Modifier	= require("sphere.models.ModifierModel.Modifier")
local NoteChartExporter			= require("osu.NoteChartExporter")

local ToOsu = Modifier:new()

ToOsu.inconsequential = true
ToOsu.type = "NoteChartModifier"

ToOsu.name = "ToOsu"
ToOsu.shortName = "ToOsu"
ToOsu.after = true

ToOsu.variableType = "boolean"

ToOsu.apply = function(self)
	local nce = NoteChartExporter:new()
	nce.noteChart = self.noteChartModel.noteChart
	nce.noteChartEntry = self.noteChartModel.noteChartEntry
	nce.noteChartDataEntry = self.noteChartModel.noteChartDataEntry

	if not self.noteChartModel.noteChartEntry then
		return
	end

	local path = self.noteChartModel.noteChartEntry.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")

	local out = io.open(("userdata/export/%s.osu"):format(fileName), "w")
	out:write(nce:export())
	out:close()
end

return ToOsu
