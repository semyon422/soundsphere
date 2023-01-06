local Class = require("Class")

local EditorController = Class:new()

EditorController.load = function(self)
	local noteChartModel = self.game.noteChartModel
	local modifierModel = self.game.modifierModel

	noteChartModel:load()
	noteChartModel:loadNoteChart()
	modifierModel:apply("NoteChartModifier")

	self.game.editorModel:load()
end

return EditorController
