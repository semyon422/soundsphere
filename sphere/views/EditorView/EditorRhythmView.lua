local RhythmView = require("sphere.views.RhythmView")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")

local EditorRhythmView = RhythmView:new()

EditorRhythmView.longNoteShortening = 0

EditorRhythmView.getCurrentTime = function(self)
	return self.game.editorModel.timePoint.absoluteTime
end

EditorRhythmView.getInputOffset = function(self)
	return 0
end

EditorRhythmView.getVisualOffset = function(self)
	return 0
end

EditorRhythmView.getVisualTimeRate = function(self)
	return self.game.editorModel.speed
end

EditorRhythmView.fillChords = function(self)
	local editorModel = self.game.editorModel
	local layerData = editorModel.layerData

	for inputType, r in pairs(layerData.ranges.note) do
		for inputIndex, range in pairs(r) do
			local noteData = range.head
			while noteData and noteData <= range.tail do
				local graphicalNote = GraphicalNoteFactory:getNote(noteData)
				if graphicalNote then
					graphicalNote.currentTimePoint = editorModel.timePoint
					graphicalNote.graphicEngine = self
					graphicalNote.layerData = layerData
					graphicalNote.input = inputType .. inputIndex
					graphicalNote:update()
					self:fillChord(graphicalNote)
				end
				noteData = noteData.next
			end
		end
	end
end

EditorRhythmView.drawNotes = function(self)
	local editorModel = self.game.editorModel
	local layerData = editorModel.layerData

	for inputType, r in pairs(layerData.ranges.note) do
		for inputIndex, range in pairs(r) do
			local noteData = range.head
			while noteData and noteData <= range.tail do
				local graphicalNote = GraphicalNoteFactory:getNote(noteData)
				if graphicalNote then
					graphicalNote.currentTimePoint = editorModel.timePoint
					graphicalNote.graphicEngine = self
					graphicalNote.layerData = layerData
					graphicalNote.input = inputType .. inputIndex
					graphicalNote:update()
					self:drawNote(graphicalNote)
				end
				noteData = noteData.next
			end
		end
	end
end

return EditorRhythmView
