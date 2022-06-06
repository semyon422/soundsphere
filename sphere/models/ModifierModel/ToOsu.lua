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
	nce.noteChart = self.game.noteChartModel.noteChart
	nce.noteChartEntry = self.game.noteChartModel.noteChartEntry
	nce.noteChartDataEntry = self.game.noteChartModel.noteChartDataEntry

	if not self.game.noteChartModel.noteChartEntry then
		return
	end

	local path = self.game.noteChartModel.noteChartEntry.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")

	return assert(love.filesystem.write(("userdata/export/%s.osu"):format(fileName), nce:export()))
end

return ToOsu
