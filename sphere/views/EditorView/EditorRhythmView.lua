local RhythmView = require("sphere.views.RhythmView")
local just = require("just")
local gfx_util = require("gfx_util")

local EditorRhythmView = RhythmView:new()

EditorRhythmView.processNote = function(self, note)
	local editorModel = self.game.editorModel

	if note.noteType == "ShortNote" then
		local over = just.mouse_over(note, note.over, "mouse")
		if over then
			if just.mousepressed(1) then
				editorModel:grabNote(note)
			elseif just.mousepressed(2) then
				editorModel:removeNote(note)
			end
		end
	elseif note.noteType == "LongNote" then
		local bodyOver = just.mouse_over(tostring(note) .. "body", note.bodyOver, "mouse")
		local headOver = just.mouse_over(tostring(note) .. "head", note.headOver, "mouse")
		local tailOver = just.mouse_over(tostring(note) .. "tail", note.tailOver, "mouse")
		if just.mousepressed(1) then
			if bodyOver then
				editorModel:grabNote(note, "body")
			elseif headOver then
				editorModel:grabNote(note, "head")
			elseif tailOver then
				editorModel:grabNote(note, "tail")
			end
		end
		if (bodyOver or headOver or tailOver) and just.mousepressed(2) then
			editorModel:removeNote(note)
		end
	end
end

EditorRhythmView.draw = function(self)
	local editorModel = self.game.editorModel
	local ld = editorModel.layerData
	local noteSkin = self.game.noteSkinModel.noteSkin

	if not ld.ranges.timePoint.head then
		return
	end

	love.graphics.replaceTransform(gfx_util.transform(self.transform))

	local t = editorModel:getMouseTime()
	for i = 1, noteSkin.inputsCount do
		local Head = noteSkin.notes.ShortNote.Head
		local over = just.is_over(Head.w[i], noteSkin.unit, Head.x[i], 0)
		over = just.mouse_over("add note" .. i, over, "mouse")
		if over and just.mousepressed(1) then
			editorModel:addNote(t, "key", i)
		end
	end

	RhythmView.draw(self)

	for _, note in ipairs(editorModel.graphicEngine.notes) do
		self:processNote(note)
	end
	if just.mousereleased(1) and editorModel.grabbedNote then
		editorModel:dropNote()
	end
end

EditorRhythmView.fillChords = function(self)
	local editorModel = self.game.editorModel
	for _, graphicalNote in ipairs(editorModel.graphicEngine.notes) do
		self:fillChord(graphicalNote)
	end
end

EditorRhythmView.drawNotes = function(self)
	local editorModel = self.game.editorModel
	for _, graphicalNote in ipairs(editorModel.graphicEngine.notes) do
		self:drawNote(graphicalNote)
	end
end

return EditorRhythmView
