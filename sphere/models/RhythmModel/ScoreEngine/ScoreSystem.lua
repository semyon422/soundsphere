local Class = require("aqua.util.Class")

local ScoreSystem = Class:new()

ScoreSystem.notes = {}
ScoreSystem.before = function() end
ScoreSystem.after = function() end

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

return ScoreSystem
