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

	local t = editorModel:getMouseTime()
	for i = 1, columns do
		local over = just.mouse_over("add note" .. i, just.is_over(nw, noteSkin.unit), "mouse")
		if over and just.mousepressed(1) then
			editorModel:addNote(t, "key", i)
		end
		love.graphics.translate(nw, 0)
	end
	just.pop()

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
