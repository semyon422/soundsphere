local Class				= require("Class")
local Observable		= require("Observable")
local NoteHandler		= require("sphere.models.RhythmModel.LogicEngine.NoteHandler")

local LogicEngine = Class:new()

LogicEngine.construct = function(self)
	self.observable = Observable:new()
	self.noteHandlers = {}
end

LogicEngine.load = function(self)
	self.sharedLogicalNotes = {}
	self.notesCount = {}

	self:loadNoteHandlers()
end

LogicEngine.update = function(self)
	self:updateNoteHandlers()
end

LogicEngine.unload = function(self)
	self:unloadNoteHandlers()
	self.autoplay = false
	self.promode = false
end

LogicEngine.send = function(self, event)
	return self.observable:send(event)
end

LogicEngine.getEventTime = function(self)
	return self.eventTime or self.rhythmModel.timeEngine.currentTime
end

LogicEngine.receive = function(self, event)
	if not event.virtual or self.promode then
		return
	end

	self.eventTime = event.time
	for _, noteHandler in ipairs(self.noteHandlers) do
		noteHandler:receive(event)
	end
	self.eventTime = nil
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
			table.insert(self.noteHandlers, noteHandler)
			noteHandler:load()
		end
	end
end

LogicEngine.updateNoteHandlers = function(self)
	if not self.rhythmModel.timeEngine.timer.isPlaying then
		return
	end
	for _, noteHandler in ipairs(self.noteHandlers) do
		noteHandler:update()
	end
end

LogicEngine.unloadNoteHandlers = function(self)
	for _, noteHandler in ipairs(self.noteHandlers) do
		noteHandler:unload()
	end
	self.noteHandlers = {}
end

return LogicEngine
