local Modifier = require("sphere.game.ModifierManager.Modifier")
local NoteChartExporter = require("osu.NoteChartExporter")

local ToOsu = Modifier:new()

ToOsu.name = "ToOsu"

ToOsu.apply = function(self)
	local nce = NoteChartExporter:new()
	nce.noteChart = self.noteChart

	local out = io.open("userdata/export/map.osu", "w")
	out:write(nce:export())
	out:close()
end

return ToOsu
