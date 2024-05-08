local class = require("class")
local NoteHandler = require("sphere.models.RhythmModel.LogicEngine.NoteHandler")
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

function LogicEngine:getNoteHandler(input, create)
	if self.singleHandler then
		input = 1
	end

	local noteHandler = self.noteHandlers[input]
	if not noteHandler then
		if not create then
			return
		end
		noteHandler = NoteHandler(self)
		self.noteHandlers[input] = noteHandler
	end

	return noteHandler
end

function LogicEngine:load()
	self.sharedLogicalNotes = {}
	self.noteHandlers = {}

	-- many layers can be here
	for noteDatas, inputType, inputIndex, layerDataIndex in self.noteChart:getInputIterator() do
		local input = inputType .. inputIndex
		local noteHandler = self:getNoteHandler(input, true)

		for _, noteData in ipairs(noteDatas) do
			table.insert(noteHandler.logicNoteDatas, {
				noteData = noteData,
				input = input,
			})
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

---@param noteData ncdk.NoteData
---@return sphere.LogicalNote?
function LogicEngine:getLogicalNote(noteData)
	return self.sharedLogicalNotes[noteData]
end

---@param event table
function LogicEngine:sendScore(event)
	self.scoreEngine.scoreSystem:receive(event)
end

---@param noteData ncdk.NoteData
---@param isBackground boolean?
function LogicEngine:playSound(noteData, isBackground)
	self.observable:send({
		name = "LogicalNoteSound",
		noteData, isBackground
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
