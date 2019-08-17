local Modifier			= require("sphere.screen.gameplay.ModifierManager.Modifier")
local NoteChartExporter	= require("osu.NoteChartExporter")

local ToOsu = Modifier:new()

ToOsu.name = "ToOsu"

ToOsu.apply = function(self)
	local GameplayScreen = require("sphere.screen.gameplay.GameplayScreen")
	
	local nce = NoteChartExporter:new()
	nce.noteChart = self.noteChart
	nce.cacheData = GameplayScreen.cacheData
	
	local path = GameplayScreen.cacheData.path
	path = path:find("^.+/.$") and path:match("^(.+)/.$") or path
	local fileName = path:match("^.+/(.-)$"):match("^(.+)%..-$")
	
	local out = io.open(("userdata/export/%s.osu"):format(fileName), "w")
	out:write(nce:export())
	out:close()
end

return ToOsu
