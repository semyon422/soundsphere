local Class = require("Class")
local NoteChartExporter = require("sph.NoteChartExporter")

local EditorController = Class:new()

EditorController.load = function(self)
	self.game.noteChartModel:loadNoteChart()
	self.game.editorModel:load()
end

EditorController.save = function(self)
	local noteChartModel = self.game.noteChartModel

	self.game.editorModel:save()

	local exp = NoteChartExporter:new()
	exp.noteChart = noteChartModel.noteChart

	love.filesystem.write(noteChartModel.noteChartEntry.path, exp:export())
end

return EditorController
