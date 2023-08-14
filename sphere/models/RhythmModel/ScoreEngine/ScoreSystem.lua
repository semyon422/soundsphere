local class = require("class")

local ScoreSystem = class()

ScoreSystem.notes = {}
function ScoreSystem:load() end
function ScoreSystem:before(event) end
function ScoreSystem:after(event) end

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

function ScoreSystem:receive(event)
	if event.name ~= "NoteState" or not event.currentTime then
		return
	end

	self:before(event)

	local oldState, newState = event.oldState, event.newState
	local handler =
		self.notes[event.noteType] and
		self.notes[event.noteType][oldState] and
		self.notes[event.noteType][oldState][newState]

	handle(self, handler, event)

	self:after(event)
end

function ScoreSystem:getSlice()
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
