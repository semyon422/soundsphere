local class = require("class")

---@class sphere.ScoreSystem
---@operator call: sphere.ScoreSystem
---@field judge_accuracy sphere.JudgeAccuracy?
---@field judge_windows sphere.JudgeWindows?
---@field judge_counter sphere.JudgeCounter?
---@field judge_names string[]?
---@field timings sea.Timings?
---@field subtimings sea.Subtimings?
local ScoreSystem = class()

ScoreSystem.events = {}

ScoreSystem.hasAccuracy = false
ScoreSystem.hasScore = false
ScoreSystem.hasJudges = false

---@return string
function ScoreSystem:getKey()
	error("not implemented")
end

---@param event table
function ScoreSystem:before(event) end

---@param event table
function ScoreSystem:after(event) end

---@param self table
---@param handler function|string|table?
---@param event table
local function handle(self, handler, event)
	if type(handler) == "function" then
		handler(self, event)
	elseif type(handler) == "string" then
		self[handler](self, event)
	elseif type(handler) == "table" then
		for _, h in ipairs(handler) do
			handle(self, h, event)
		end
	end
end

---@param event table
function ScoreSystem:receive(event)
	if event.name ~= "NoteState" or not event.currentTime then
		return
	end

	self:before(event)

	local oldState, newState = event.oldState, event.newState
	local handler =
		self.events[event.noteType] and
		self.events[event.noteType][oldState] and
		self.events[event.noteType][oldState][newState]

	handle(self, handler, event)

	self:after(event)
end

---@return table
function ScoreSystem:getSlice()
	return {}
end

return ScoreSystem
