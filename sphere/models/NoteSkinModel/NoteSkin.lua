local Class = require("aqua.util.Class")
local InputMode	= require("ncdk.InputMode")
local NoteSkinLoader = require("sphere.models.NoteSkinModel.NoteSkinLoader")

local NoteSkin = Class:new()

NoteSkin.construct = function(self)
	self.data = {}
	self.env = {}
	self.notes = {}
	self.playField = {}

	self.name = ""
	self.inputMode = InputMode:new()
	self.type = ""
	self.path = ""
	self.directoryPath = ""
end

NoteSkin.load = function(self)
	return NoteSkinLoader:load(self)
end

-- NoteSkin.checkNote = function(self, noteView)
	-- local noteData = noteView.startNoteData
	-- return
	-- 	self.notes[noteData.inputType] and
	-- 	self.notes[noteData.inputType][noteData.inputIndex] and
	-- 	self.notes[noteData.inputType][noteData.inputIndex][noteView.noteType]
-- end

NoteSkin.check = function(self, note)
end

NoteSkin.get = function(self, noteView, part, name, timeState)
	-- local noteData = noteView.startNoteData
	-- local seq = self.notes[noteData.inputType][noteData.inputIndex][noteView.noteType][part].gc[name]

	-- return seq[1](timeState, noteView.logicalState, seq[2])
end

NoteSkin.where = function(self, note, time)
	-- local noteData = note.startNoteData
	-- local drawInterval = self.notes[noteData.inputType][noteData.inputIndex][note.noteType][part].drawInterval

	-- if -time > drawInterval[2] then
	-- 	return 1
	-- elseif -time < drawInterval[1] then
	-- 	return -1
	-- else
	-- 	return 0
	-- end
end

return NoteSkin
