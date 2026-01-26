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

---@alias sphere.ScoreSystemHandler string|function|sphere.ScoreSystemHandler[]

---@type {[string]: {[string]: {[string]: sphere.ScoreSystemHandler}}}
ScoreSystem.events = {}

ScoreSystem.hasAccuracy = false
ScoreSystem.hasScore = false
ScoreSystem.hasJudges = false

---@return string
function ScoreSystem:getKey()
	error("not implemented")
end

---@param notes_count integer
function ScoreSystem:setNotesCount(notes_count)
	self.notes_count = notes_count
end

---@param event table
function ScoreSystem:before(event) end

---@param event table
function ScoreSystem:after(event) end

---@param self table
---@param handler sphere.ScoreSystemHandler?
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

---@param event rizu.LogicNoteChange
function ScoreSystem:receive(event)
	self:before(event)

	local handler =
		self.events[event.type] and
		self.events[event.type][event.old_state] and
		self.events[event.type][event.old_state][event.new_state]

	handle(self, handler, event)

	self:after(event)
end

---@return table
function ScoreSystem:getSlice()
	return {}
end

return ScoreSystem
