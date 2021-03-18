local Class = require("aqua.util.Class")
local GraphicalNoteFactory = require("sphere.views.RhythmView.GraphicalNoteFactory")
local NoteSkinImageView = require("sphere.views.RhythmView.NoteSkinImageView")

local RhythmView = Class:new()

RhythmView.construct = function(self)
	self.graphicalNoteFactory = GraphicalNoteFactory:new()
	self.noteSkinImageView = NoteSkinImageView:new()
end

RhythmView.load = function(self)
	local noteSkinImageView = self.noteSkinImageView

	noteSkinImageView.noteSkin = self.noteSkin
	noteSkinImageView:load()

	self.notes = {}

	self.noteSkinImageView:joinContainer(self.container)

	local graphicalNoteFactory = self.graphicalNoteFactory
	graphicalNoteFactory.videoBgaEnabled = self.videoBgaEnabled
	graphicalNoteFactory.imageBgaEnabled = self.imageBgaEnabled
end

RhythmView.unload = function(self)
	self.noteSkinImageView:leaveContainer(self.container)
	self.noteSkinImageView:unload()
end

RhythmView.receive = function(self, event)
	self.noteSkinImageView:receive(event)

	if event.name == "GraphicalNoteState" then
		local notes = self.notes
		local note = event.note
		if note.activated then
			local graphicalNote = self.graphicalNoteFactory:getNote(note)
			if not graphicalNote then
				return
			end
			graphicalNote.graphicEngine = self.rhythmModel.graphicEngine
			graphicalNote.noteSkinImageView = self.noteSkinImageView
			graphicalNote.container = self.container
			graphicalNote:init()
			graphicalNote:activate()
			notes[note] = graphicalNote
		else
			local graphicalNote = notes[note]
			if not graphicalNote then
				return
			end
			graphicalNote:deactivate()
			notes[note] = nil
		end
	elseif event.name == "TimeState" then
		for _, note in pairs(self.notes) do
			note:receive(event)
		end
	end
end

RhythmView.update = function(self, dt)
	self.noteSkinImageView:update(dt)

	for _, note in pairs(self.notes) do
		note:update(dt)
	end
end

RhythmView.setBgaEnabled = function(self, type, enabled)
	if type == "video" then
		self.videoBgaEnabled = enabled
	elseif type == "image" then
		self.imageBgaEnabled = enabled
	end
end

return RhythmView
