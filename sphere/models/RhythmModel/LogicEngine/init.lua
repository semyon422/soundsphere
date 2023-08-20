local class = require("class")
local NoteHandler = require("sphere.models.RhythmModel.LogicEngine.NoteHandler")
local Observable = require("Observable")

---@class sphere.LogicEngine
---@operator call: sphere.LogicEngine
local LogicEngine = class()

LogicEngine.inputOffset = 0

function LogicEngine:new()
	self.observable = Observable()
end

function LogicEngine:load()
	self.sharedLogicalNotes = {}
	self.noteHandlers = {}

	-- many layers can be here
	for noteDatas, inputType, inputIndex, layerDataIndex in self.noteChart:getInputIterator() do
		local key = inputType .. inputIndex

		local noteHandler = self.noteHandlers[key]
		if not noteHandler then
			noteHandler = NoteHandler({
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

	local noteHandler = self.noteHandlers[event[1]]
	if not noteHandler then
		return
	end

	self.eventTime = event.time
	noteHandler:setKeyState(event.name == "keypressed")
	self.eventTime = nil
end

---@param noteData ncdk.NoteData
---@return sphere.LogicalNote?
function LogicEngine:getLogicalNote(noteData)
	return self.sharedLogicalNotes[noteData]
end

---@param event table
function LogicEngine:sendScore(event)
	self.rhythmModel.scoreEngine.scoreSystem:receive(event)
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
	return self.eventTime or self.rhythmModel.timeEngine.currentTime
end

---@return number
function LogicEngine:getTimeRate()
	return self.timeRate or self.rhythmModel.timeEngine.timeRate
end

---@return number
function LogicEngine:getInputOffset()
	return self.inputOffset
end

return LogicEngine
