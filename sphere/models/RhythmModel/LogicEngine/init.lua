local Class				= require("Class")
local NoteHandler		= require("sphere.models.RhythmModel.LogicEngine.NoteHandler")
local Observable = require("Observable")

local LogicEngine = Class:new()

LogicEngine.inputOffset = 0

LogicEngine.construct = function(self)
	self.observable = Observable:new()
end

LogicEngine.load = function(self)
	self.sharedLogicalNotes = {}
	self.noteHandlers = {}

	-- many layers can be here
	for noteDatas, inputType, inputIndex, layerDataIndex in self.noteChart:getInputIterator() do
		local key = inputType .. inputIndex

		local noteHandler = self.noteHandlers[key]
		if not noteHandler then
			noteHandler = NoteHandler:new({
				noteDatas = {},
				logicEngine = self
			})
			self.noteHandlers[key] = noteHandler
		end

		for _, noteData in ipairs(noteDatas) do
			table.insert(noteHandler.noteDatas, noteData)
		end
	end

	local notesCount = 0
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:load()
		for _, note in ipairs(noteHandler.notes) do
			if note.isScorable then
				notesCount = notesCount + 1
			end
		end
	end
	self.notesCount = notesCount
end

LogicEngine.unload = function(self)
	self.autoplay = false
	self.promode = false
end

LogicEngine.update = function(self)
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:update()
	end
end

LogicEngine.receive = function(self, event)
	if not event.virtual or self.autoplay then
		return
	end

	local noteHandler = self.noteHandlers[event[1]]
	if not noteHandler then
		return
	end

	self.eventTime = event.time
	noteHandler:setKeyState(event.name == "keypressed")
	self.eventTime = nil
end

LogicEngine.getLogicalNote = function(self, noteData)
	return self.sharedLogicalNotes[noteData]
end

LogicEngine.sendScore = function(self, event)
	self.rhythmModel.scoreEngine.scoreSystem:receive(event)
end

LogicEngine.playSound = function(self, noteData, isBackground)
	self.observable:send({
		name = "LogicalNoteSound",
		noteData, isBackground
	})
end

LogicEngine.getEventTime = function(self)
	return self.eventTime or self.rhythmModel.timeEngine.currentTime
end

LogicEngine.getTimeRate = function(self)
	return self.timeRate or self.rhythmModel.timeEngine.timeRate
end

LogicEngine.getInputOffset = function(self)
	return self.inputOffset
end

return LogicEngine
