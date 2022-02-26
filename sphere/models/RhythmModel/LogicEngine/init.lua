local Class				= require("aqua.util.Class")
local Observable		= require("aqua.util.Observable")
local Queue				= require("aqua.util.Queue")
local NoteHandler		= require("sphere.models.RhythmModel.LogicEngine.NoteHandler")

local LogicEngine = Class:new()

LogicEngine.construct = function(self)
	self.observable = Observable:new()
	self.noteHandlers = {}
end

LogicEngine.load = function(self)
	self.sharedLogicalNotes = {}
	self.currentTime = 0
	self.exactCurrentTimeNoOffset = -math.huge
	self.events = Queue:new()

	self:loadNoteHandlers()
end

-- local sortEvents = function(a, b)
-- 	return a.time < b.time
-- end
LogicEngine.update = function(self)
	self.currentTime = self.rhythmModel.timeEngine.exactCurrentTime
	self.exactCurrentTimeNoOffset = self.rhythmModel.timeEngine.exactCurrentTimeNoOffset
	self.timeRate = self.rhythmModel.timeEngine.timeRate
	-- table.sort(events, sortEvents)

	-- for event in self.events do
	-- 	self.currentTime = event.time
		self:updateNoteHandlers()
	-- 	self:_receive(event)
	-- 	self:updateNoteHandlers()
	-- end
end

LogicEngine.unload = function(self)
	self:unloadNoteHandlers()
	self.autoplay = false
	self.promode = false
end

LogicEngine.send = function(self, event)
	return self.observable:send(event)
end

LogicEngine.receive = function(self, event)
	-- self.currentTime = self.rhythmModel.timeEngine.exactCurrentTime
	-- self.exactCurrentTimeNoOffset = self.rhythmModel.timeEngine.exactCurrentTimeNoOffset
	-- self.timeRate = self.rhythmModel.timeEngine.timeRate
	-- self.events:add(event)
	self:_receive(event)
end

LogicEngine._receive = function(self, event)
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
	if self.timeRate == 0 then
		return
	end
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
	return self.rhythmModel.scoreEngine:getScoreNote(noteData)
end

return LogicEngine
