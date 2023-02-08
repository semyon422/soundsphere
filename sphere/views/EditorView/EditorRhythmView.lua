local RhythmView = require("sphere.views.RhythmView")
local just = require("just")
local gfx_util = require("gfx_util")

local EditorRhythmView = RhythmView:new()

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

	for _, graphicalNote in ipairs(editorModel.graphicEngine.notes) do
		graphicalNote:update()
		if just.button(graphicalNote, graphicalNote.over, 2) then
			ld:removeNoteData(graphicalNote.startNoteData, graphicalNote.inputType, graphicalNote.inputIndex)
		end
	end

	RhythmView.draw(self)
end

EditorRhythmView.fillChords = function(self)
	local editorModel = self.game.editorModel
	for _, graphicalNote in ipairs(editorModel.graphicEngine.notes) do
		graphicalNote:update()
		self:fillChord(graphicalNote)
	end
end

EditorRhythmView.drawNotes = function(self)
	local editorModel = self.game.editorModel
	for _, graphicalNote in ipairs(editorModel.graphicEngine.notes) do
		graphicalNote:update()
		self:drawNote(graphicalNote)
	end
end

return EditorRhythmView
