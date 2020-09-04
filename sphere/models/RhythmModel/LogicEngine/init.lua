local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteHandler		= require("sphere.models.RhythmModel.LogicEngine.NoteHandler")

local LogicEngine = Class:new()

LogicEngine.construct = function(self)
	self.observable = Observable:new()
	self.noteHandlers = {}
end

LogicEngine.load = function(self)
	self.sharedLogicalNotes = {}
	self.currentTime = 0
	self.events = {}

	self:loadNoteHandlers()
end

local sortEvents = function(a, b)
	return a.time < b.time
end
LogicEngine.update = function(self)
	local events = self.events
	table.sort(events, sortEvents)

	for _, event in ipairs(events) do
		self.currentTime = event.time
		self:updateNoteHandlers()
		self:_receive(event)
		self:updateNoteHandlers()
	end

	self.events = {}
end

LogicEngine.unload = function(self)
	self:unloadNoteHandlers()
end

LogicEngine.send = function(self, event)
	return self.observable:send(event)
end

LogicEngine.receive = function(self, event)
	self.events[#self.events + 1] = event
end

LogicEngine._receive = function(self, event)
	if event.name == "TimeState" then
		self.currentTime = event.exactCurrentTime
		return
	end

	if not event.virtual or self.promode then
		return
	end

	for noteHandler in pairs(self.noteHandlers) do
		noteHandler:receive(event)
	end
end

LogicEngine.getNoteHandler = function(self, inputType, inputIndex)
	return NoteHandler:new({
		inputType = inputType,
		inputIndex = inputIndex,
		logicEngine = self
	})
end

LogicEngine.loadNoteHandlers = function(self)
	self.noteHandlers = {}
	for inputType, inputIndex in self.noteChart:getInputIteraator() do
		local noteHandler = self:getNoteHandler(inputType, inputIndex)
		if noteHandler then
			self.noteHandlers[noteHandler] = noteHandler
			noteHandler:load()
		end
	end
end

LogicEngine.updateNoteHandlers = function(self)
	for noteHandler in pairs(self.noteHandlers) do
		noteHandler:update()
	end
end

LogicEngine.unloadNoteHandlers = function(self)
	for noteHandler in pairs(self.noteHandlers) do
		noteHandler:unload()
	end
	self.noteHandlers = {}
end

LogicEngine.getScoreNote = function(self, noteData)
	return self.scoreEngine:getScoreNote(noteData)
end

return LogicEngine
