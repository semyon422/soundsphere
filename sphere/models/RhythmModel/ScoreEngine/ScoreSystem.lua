local Class = require("aqua.util.Class")

local ScoreSystem = Class:new()

ScoreSystem.notes = {}
ScoreSystem.load = function(self) end
ScoreSystem.before = function(self, event) end
ScoreSystem.after = function(self, event) end

ScoreSystem.receive = function(self, event)
	if event.name ~= "ScoreNoteState" or not event.currentTime then
		return
	end

	self:before(event)

	local oldState, newState = event.oldState, event.newState
	local handler =
		self.notes[event.noteType] and
		self.notes[event.noteType][oldState] and
		self.notes[event.noteType][oldState][newState]

	if type(handler) == "function" then
		handler(self, event)
	elseif type(handler) == "table" then
		for _, h in ipairs(handler) do
			h(self, event)
		end
	end

	self:after(event)
end

ScoreSystem.getSlice = function(self)
	local slice = {}
	for k, v in pairs(self) do
		local t = type(v)
		if t == "number" or t == "string" or t == "boolean" then
			if v == math.huge then
				v = "inf"
			end
			slice[k] = v
		end
	end
	return slice
end

return ScoreSystem
