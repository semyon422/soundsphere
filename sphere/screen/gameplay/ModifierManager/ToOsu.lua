local InconsequentialModifier	= require("sphere.screen.gameplay.ModifierManager.InconsequentialModifier")
local NoteChartExporter			= require("osu.NoteChartExporter")

local ToOsu = InconsequentialModifier:new()

ToOsu.name = "ToOsu"
ToOsu.shortName = "ToOsu"
ToOsu.after = true

ToOsu.type = "boolean"

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
