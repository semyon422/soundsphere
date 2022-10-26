local Class = require("Class")
local NoteViewFactory = require("sphere.views.RhythmView.NoteViewFactory")
local gfx_util = require("gfx_util")

local RhythmView = Class:new()

RhythmView.draw = function(self)
	local graphicEngine = self.game.rhythmModel.graphicEngine
	local noteSkin = graphicEngine.noteSkin
	local inputsCount = noteSkin.inputsCount
	local inputs = noteSkin.inputs

	NoteViewFactory.bga = self.game.configModel.configs.settings.gameplay.bga
	NoteViewFactory.mode = self.mode

	local chords = {}
	for _, noteDrawer in ipairs(graphicEngine.noteDrawers) do
		for i = noteDrawer.endNoteIndex, noteDrawer.startNoteIndex, -1 do
			local note = noteDrawer.noteData[i]

			local noteView = NoteViewFactory:getNoteView(note)
			if noteView then
				noteView.index = 1
				noteView.noteSkin = noteSkin
				noteView.graphicalNote = note
				local startNoteData = note.startNoteData

				local column = inputs[startNoteData.inputType .. startNoteData.inputIndex]
				if column and column <= inputsCount then
				-- if column and column <= inputsCount and noteView:isVisible() then
					if noteView.fillChords then
						noteView:fillChords(chords, column)
					end
				end
			end
		end
	end

	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	love.graphics.setColor(1, 1, 1, 1)

	for _, noteDrawer in ipairs(graphicEngine.noteDrawers) do
		for i = noteDrawer.startNoteIndex, noteDrawer.endNoteIndex do
			local note = noteDrawer.noteData[i]

			for j = 1, noteSkin:check(note) or 0 do
				local noteView = NoteViewFactory:getNoteView(note)
				if noteView then
					noteView.index = j
					noteView.chords = chords
					noteView.noteSkin = noteSkin
					noteView.graphicalNote = note
					noteView:draw()
				end
			end
		end
	end

	local blendModes = noteSkin.blendModes
	local spriteBatches = noteSkin.data.spriteBatches
	for _, spriteBatch in ipairs(spriteBatches) do
		local key = spriteBatches[spriteBatch]
		local blendMode = blendModes[key]
		if blendMode then
			love.graphics.setBlendMode(blendMode[1], blendMode[2])
		end
		love.graphics.draw(spriteBatch)
		spriteBatch:clear()
		if blendMode then
			love.graphics.setBlendMode("alpha")
		end
	end
end

return RhythmView
