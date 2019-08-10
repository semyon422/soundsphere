local Modifier = require("sphere.game.ModifierManager.Modifier")
local NoteChartExporter = require("osu.NoteChartExporter")

local ToOsu = Modifier:new()

ToOsu.name = "ToOsu"

ToOsu.apply = function(self)
	local GameplayScreen = require("sphere.screen.GameplayScreen")
	
	local nce = NoteChartExporter:new()
	nce.noteChart = self.noteChart
	nce.cacheData = GameplayScreen.cacheData

	local out = io.open("userdata/export/map.osu", "w")
	out:write(nce:export())
	out:close()
end

return ToOsu
