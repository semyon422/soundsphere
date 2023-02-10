local Class = require("Class")
local NoteViewFactory = require("sphere.views.RhythmView.NoteViewFactory")
local gfx_util = require("gfx_util")

local RhythmView = Class:new()

RhythmView.mode = "default"

RhythmView.fillChords = function(self)
	for _, noteDrawer in ipairs(self.game.rhythmModel.graphicEngine.noteDrawers) do
		for i = noteDrawer.endNoteIndex, noteDrawer.startNoteIndex, -1 do
			self:fillChord(noteDrawer.notes[i])
		end
	end
end

RhythmView.drawNotes = function(self)
	for _, noteDrawer in ipairs(self.game.rhythmModel.graphicEngine.noteDrawers) do
		for i = noteDrawer.startNoteIndex, noteDrawer.endNoteIndex do
			self:drawNote(noteDrawer.notes[i])
		end
	end
end

RhythmView.fillChord = function(self, note)
	local noteSkin = self.game.noteSkinModel.noteSkin

	local noteView = NoteViewFactory:getNoteView(note, self.mode)
	if noteView then
		noteView.index = 1
		noteView.noteSkin = noteSkin
		noteView.graphicalNote = note

		local column = noteSkin:getColumn(note.inputType .. note.inputIndex)
		if column and column <= noteSkin.inputsCount then
		-- if column and column <= inputsCount and noteView:isVisible() then
			if noteView.fillChords then
				noteView:fillChords(self.chords, column)
			end
		end
	end
end

RhythmView.drawNote = function(self, note)
	local noteSkin = self.game.noteSkinModel.noteSkin

	for j = 1, noteSkin:check(note) or 0 do
		local noteView = NoteViewFactory:getNoteView(note, self.mode)
		if noteView then
			noteView.index = j
			noteView.chords = self.chords
			noteView.noteSkin = noteSkin
			noteView.graphicalNote = note
			noteView.rhythmView = self
			noteView:draw()
		end
	end
end

RhythmView.pressNote = function(self, noteData) end

RhythmView.draw = function(self)
	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	love.graphics.setColor(1, 1, 1, 1)

	self.chords = {}
	if self.mode == "default" then
		self:fillChords()
	end

	self:drawNotes()

	local noteSkin = self.game.noteSkinModel.noteSkin
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
