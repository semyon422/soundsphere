local Modifier	= require("sphere.models.ModifierModel.Modifier")
local NoteChartExporter			= require("osu.NoteChartExporter")

local ToOsu = Modifier:new()

ToOsu.type = "NoteChartModifier"
ToOsu.interfaceType = "toggle"

ToOsu.defaultValue = true
ToOsu.name = "ToOsu"
ToOsu.shortName = "OSU"

ToOsu.apply = function(self, config)
	local nce = NoteChartExporter:new()
	nce.noteChart = self.gameController.noteChartModel.noteChart
	nce.noteChartEntry = self.gameController.noteChartModel.noteChartEntry
	nce.noteChartDataEntry = self.gameController.noteChartModel.noteChartDataEntry

	if not self.gameController.noteChartModel.noteChartEntry then
		return
	end

	local path = self.gameController.noteChartModel.noteChartEntry.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")

	return assert(love.filesystem.write(("userdata/export/%s.osu"):format(fileName), nce:export()))
end

return ToOsu
