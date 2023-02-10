local RhythmView = require("sphere.views.RhythmView")
local just = require("just")
local gfx_util = require("gfx_util")

local EditorRhythmView = RhythmView:new()

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

	for _, graphicalNote in ipairs(editorModel.graphicEngine.notes) do
		local over = just.mouse_over(graphicalNote, graphicalNote.over, "mouse")
		if over then
			if just.mousepressed(1) then
				editorModel:grabNote(graphicalNote)
			elseif just.mousepressed(2) then
				editorModel:removeNote(graphicalNote)
			end
		end
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
