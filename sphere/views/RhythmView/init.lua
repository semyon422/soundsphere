local Class = require("aqua.util.Class")
local Container = require("aqua.graphics.Container")
local GraphicalNoteFactory = require("sphere.views.RhythmView.GraphicalNoteFactory")

local RhythmView = Class:new()

RhythmView.load = function(self)
	self.rhythmModel.graphicEngine.observable:add(self)
	self.notes = {}

	self.container = Container:new()

	self.rhythmModel.graphicEngine.noteSkin:joinContainer(self.container)
end

RhythmView.unload = function(self)
	self.rhythmModel.graphicEngine.noteSkin:leaveContainer(self.container)
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
			graphicalNote.noteSkin = self.rhythmModel.graphicEngine.noteSkin
			graphicalNote.graphicEngine = self.rhythmModel.graphicEngine
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
	self.rhythmModel.graphicEngine.noteSkin:update()
	for _, note in pairs(self.notes) do
		note:update()
	end
	self.container:update()
end

RhythmView.draw = function(self)
	self.container:draw()
end

return RhythmView
