local class = require("class")
local NoteHandler = require("sphere.models.RhythmModel.LogicEngine.NoteHandler")
local HandlerNote = require("sphere.models.RhythmModel.LogicEngine.HandlerNote")
local Observable = require("Observable")

---@class sphere.LogicEngine
---@operator call: sphere.LogicEngine
local LogicEngine = class()

LogicEngine.inputOffset = 0
LogicEngine.singleHandler = false

---@param timeEngine sphere.TimeEngine
---@param scoreEngine sphere.ScoreEngine
function LogicEngine:new(timeEngine, scoreEngine)
	self.observable = Observable()
	self.timeEngine = timeEngine
	self.scoreEngine = scoreEngine
end

---@param column ncdk2.Column
---@param create boolean?
---@return sphere.NoteHandler?
function LogicEngine:getNoteHandler(column, create)
	if self.singleHandler then
		column = 1
	end

	local noteHandler = self.noteHandlers[column]
	if not noteHandler then
		if not create then
			return
		end
		noteHandler = NoteHandler(self)
		self.noteHandlers[column] = noteHandler
	end

	return noteHandler
end

---@param chart ncdk2.Chart
function LogicEngine:setChart(chart)
	self.chart = chart
end

function LogicEngine:load()
	---@type {[ncdk2.Note]: sphere.LogicalNote}
	self.sharedLogicalNotes = {}

	---@type sphere.NoteHandler[]
	self.noteHandlers = {}

	local column_notes = self.chart.notes:getColumnNotes()
	for column, notes in pairs(column_notes) do
		local noteHandler = assert(self:getNoteHandler(column, true))
		for _, note in ipairs(notes) do
			table.insert(noteHandler.logicNotes, HandlerNote(note, column))
		end
	end

	local notesCount = 0
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:load()
		for _, note in ipairs(noteHandler.notes) do
			if note.note.isScorable then
				notesCount = notesCount + 1
			end
		end
	end
	self.notesCount = notesCount
end

function LogicEngine:unload()
	self.autoplay = false
	self.promode = false
end

function LogicEngine:update()
	for _, noteHandler in pairs(self.noteHandlers) do
		noteHandler:update()
	end
end

---@param event table
function LogicEngine:receive(event)
	if not event.virtual or self.autoplay then
		return
	end

	local input = event[1]
	local noteHandler = self:getNoteHandler(input)
	if not noteHandler then
		return
	end

	self.eventTime = event.time
	noteHandler:setKeyState(event.name == "keypressed", input)
	self.eventTime = nil
end

---@param note ncdk2.Note
---@return sphere.LogicalNote?
function LogicEngine:getLogicalNote(note)
	return self.sharedLogicalNotes[note]
end

---@param event table
function LogicEngine:sendScore(event)
	self.scoreEngine.scoreSystem:receive(event)
end

---@param note ncdk2.Note
---@param isBackground boolean?
function LogicEngine:playSound(note, isBackground)
	self.observable:send({
		name = "LogicalNoteSound",
		note, isBackground
	})
end

---@return number
function LogicEngine:getEventTime()
	return self.eventTime or self.timeEngine.currentTime
end

---@return number
function LogicEngine:getTimeRate()
	return self.timeRate or self.timeEngine.timeRate
end

---@return number
function LogicEngine:getInputOffset()
	return self.inputOffset
end

return LogicEngine
