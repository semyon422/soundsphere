local GraphicalNote = require("sphere.models.RhythmModel.GraphicEngine.GraphicalNote")

local VideoNote = GraphicalNote:new()

VideoNote.construct = function(self)
	self.startNoteData = self.noteData
	self.noteData = nil

	self.images = self.startNoteData.images
end

VideoNote.timeRate = 0

VideoNote.update = function(self, dt)
	return self:tryNext()
end

VideoNote.receive = function(self, event)
	if event.name == "TimeState" then
		self.timeRate = event.timeRate
	end
end

return VideoNote
