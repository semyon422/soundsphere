local Modifier	= require("sphere.models.ModifierModel.Modifier")
local NoteChartExporter			= require("osu.NoteChartExporter")

local ToOsu = Modifier:new()

ToOsu.type = "NoteChartModifier"

ToOsu.name = "ToOsu"
ToOsu.shortName = "ToOsu"

ToOsu.apply = function(self)
	local config = self.config
	if not config.value then
		return
	end

	local nce = NoteChartExporter:new()
	nce.noteChart = self.noteChartModel.noteChart
	nce.noteChartEntry = self.noteChartModel.noteChartEntry
	nce.noteChartDataEntry = self.noteChartModel.noteChartDataEntry

	local path = self.noteChartModel.noteChartEntry.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")

	local out = io.open(("userdata/export/%s.osu"):format(fileName), "w")
	out:write(nce:export())
	out:close()
end

return ToOsu
