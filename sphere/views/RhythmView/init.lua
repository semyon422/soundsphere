local class = require("class")
local NoteViewFactory = require("sphere.views.RhythmView.NoteViewFactory")
local gfx_util = require("gfx_util")

---@class sphere.RhythmView
---@operator call: sphere.RhythmView
local RhythmView = class()

RhythmView.mode = "default"

---@param f function
function RhythmView:processNotes(f)
	local graphicEngine = self.game.rhythmModel.graphicEngine
	for _, noteDrawer in ipairs(graphicEngine.noteDrawers) do
		if graphicEngine.eventBasedRender then
			for note in pairs(noteDrawer.visibleNotes) do
				f(self, note)
			end
		else
			for i = noteDrawer.startNoteIndex, noteDrawer.endNoteIndex do
				f(self, noteDrawer.notes[i])
			end
		end
	end
end

---@param note sphere.GraphicalNote
function RhythmView:fillChord(note)
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

---@param note sphere.GraphicalNote
function RhythmView:drawNote(note)
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

---@param note sphere.GraphicalNote
function RhythmView:drawSelected(note)
	local noteSkin = self.game.noteSkinModel.noteSkin

	for j = 1, noteSkin:check(note) or 0 do
		local noteView = NoteViewFactory:getNoteView(note, self.mode)
		-- if noteView and noteView.drawSelected then
		if noteView and noteView.drawSelected and note.selected then
			noteView.index = j
			noteView.chords = self.chords
			noteView.noteSkin = noteSkin
			noteView.graphicalNote = note
			noteView.rhythmView = self
			noteView:drawSelected()
		end
	end
end

---@param noteData ncdk.NoteData
function RhythmView:pressNote(noteData) end

function RhythmView:draw()
	love.graphics.replaceTransform(gfx_util.transform(self.transform))
	love.graphics.setColor(1, 1, 1, 1)

	self.chords = {}
	if self.mode == "default" then
		self:processNotes(self.fillChord)
	end

	self:processNotes(self.drawNote)

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

	self:processNotes(self.drawSelected)
end

return RhythmView
