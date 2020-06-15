local Modifier	= require("sphere.screen.gameplay.ModifierManager.Modifier")
local NoteChartExporter			= require("osu.NoteChartExporter")

local ToOsu = Modifier:new()

ToOsu.inconsequential = true
ToOsu.type = "NoteChartModifier"

ToOsu.name = "ToOsu"
ToOsu.shortName = "ToOsu"
ToOsu.after = true

ToOsu.variableType = "boolean"

ToOsu.apply = function(self)
	local GameplayScreen = require("sphere.screen.gameplay.GameplayScreen")
	
	local nce = NoteChartExporter:new()
	nce.noteChart = self.sequence.manager.noteChart
	nce.noteChartEntry = GameplayScreen.noteChartEntry
	nce.noteChartDataEntry = GameplayScreen.noteChartDataEntry
	
	local path = GameplayScreen.noteChartEntry.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")
	
	local out = io.open(("userdata/export/%s.osu"):format(fileName), "w")
	out:write(nce:export())
	out:close()
end

return ToOsu
