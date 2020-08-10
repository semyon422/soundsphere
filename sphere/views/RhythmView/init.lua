local Class = require("aqua.util.Class")
local GraphicalNoteFactory = require("sphere.views.RhythmView.GraphicalNoteFactory")

local RhythmView = Class:new()

RhythmView.load = function(self)
	self.notes = {}

	self.noteSkinView:joinContainer(self.container)
end

RhythmView.unload = function(self)
	self.noteSkinView:leaveContainer(self.container)
end

RhythmView.receive = function(self, event)
	if event.name == "GraphicalNoteState" then
		local notes = self.notes
		local note = event.note
		if note.activated then
			local graphicalNote = GraphicalNoteFactory:getNote(note)
			if not graphicalNote then
				return
			end
			-- graphicalNote.noteSkin = self.rhythmModel.graphicEngine.noteSkin
			graphicalNote.graphicEngine = self.rhythmModel.graphicEngine
			graphicalNote.noteSkinView = self.noteSkinView
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
	end
end

RhythmView.update = function(self, dt)
	for _, note in pairs(self.notes) do
		note:update(dt)
	end
end

return RhythmView
