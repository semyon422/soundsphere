local RhythmView = require("sphere.views.RhythmView")
local GraphicalNoteFactory = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNoteFactory")
local just = require("just")
local gfx_util = require("gfx_util")

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

EditorRhythmView.pressNote = function(self, noteData, inputType, inputIndex)
	local layerData = self.game.editorModel.layerData
	layerData:removeNoteData(noteData, inputType, inputIndex)
end

EditorRhythmView.draw = function(self)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local columns = editorModel.columns
	local noteSkin = self.game.noteSkinModel.noteSkin

	if not ld.ranges.timePoint.head then
		return
	end

	local nw = noteSkin.fullWidth / columns

	just.push()

	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	love.graphics.translate(noteSkin.baseOffset, 0)

	local _mx, _my = love.graphics.inverseTransformPoint(love.mouse.getPosition())

	local t = (editorModel.timePoint.absoluteTime - noteSkin:getInverseTimePosition(_my) / editorModel.speed)
	for i = 1, columns do
		if just.button("add note" .. i, just.is_over(nw, noteSkin.unit), 1) then
			editorModel:addNote(t, "key", i)
		end
		love.graphics.translate(nw, 0)
	end
	just.pop()

	RhythmView.draw(self)
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
				local nextNote = noteData.next
				local graphicalNote = GraphicalNoteFactory:getNote(noteData)
				if graphicalNote then
					graphicalNote.currentTimePoint = editorModel.timePoint
					graphicalNote.graphicEngine = self
					graphicalNote.layerData = layerData
					graphicalNote.input = inputType .. inputIndex
					graphicalNote.inputType = inputType
					graphicalNote.inputIndex = inputIndex
					graphicalNote:update()
					self:drawNote(graphicalNote)
				end
				noteData = nextNote
			end
		end
	end
end

return EditorRhythmView
