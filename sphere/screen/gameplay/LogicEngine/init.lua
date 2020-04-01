local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local NoteHandler		= require("sphere.screen.gameplay.LogicEngine.NoteHandler")

local LogicEngine = Class:new()

LogicEngine.load = function(self)
	self.observable = Observable:new()
	
	self.sharedLogicalNoteData = {}
	self.noteCount = 0
	self.currentTime = 0
	
	self:loadNoteHandlers()

	self.score.noteCount = self.noteCount
end

LogicEngine.update = function(self, dt)
	self:updateNoteHandlers()
end

LogicEngine.unload = function(self)
	self:unloadNoteHandlers()
end

LogicEngine.send = function(self, event)
	return self.observable:send(event)
end

LogicEngine.receive = function(self, event)
	if event.name == "TimeState" then
		self.currentTime = event.exactCurrentTime
		self.score.timeRate = event.timeRate
	end

	if not event.virtual then
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
	self.noteHandlers = nil
end

return LogicEngine
