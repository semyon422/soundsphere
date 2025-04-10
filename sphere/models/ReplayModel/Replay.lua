local class = require("class")
local json = require("json")
local ReplayNanoChart = require("sphere.models.ReplayModel.ReplayNanoChart")
local ReplayConverter = require("sphere.models.ReplayModel.ReplayConverter")
local InputMode = require("ncdk.InputMode")
local Osr = require("osu.Osr")

---@class sphere.Replay
---@operator call: sphere.Replay
local Replay = class()

function Replay:new()
	self.replayNanoChart = ReplayNanoChart()
	self.replayConverter = ReplayConverter()
	self.events = {}
	self.eventOffset = 0
end

---@param event table
function Replay:receive(event)
	if not event.virtual then
		return
	end

	local events = self.events
	events[#events + 1] = {
		event[1],
		name = event.name,
		time = event.time - self.logicEngine.inputOffset,
	}
end

function Replay:reset()
	self.eventOffset = 0
end

function Replay:step()
	self.eventOffset = math.min(self.eventOffset + 1, #self.events)
end

---@return table?
function Replay:getNextEvent()
	return self.events[self.eventOffset + 1]
end

---@return osu.Osr
function Replay:toOsr()
	local osr = Osr()

	osr.beatmap_hash = assert(self.hash)

	local inputMap = self.inputMode:getInputMap()

	local mania_events = {}
	for i, e in ipairs(self.events) do
		mania_events[i] = {
			math.floor(e.time * 1000),
			inputMap[e[1]],
			not not e.name:find("pressed")
		}
	end
	osr:encodeManiaEvents(mania_events)
	osr:setTimestamp(self.time)
	osr.player_name = self.player

	return osr
end

---@return string
function Replay:toString()
	local content, size = self.replayNanoChart:encode(self.events, self.inputMode)
	return json.encode({
		hash = self.hash,
		index = self.index,
		inputMode = tostring(self.inputMode),
		modifiers = self.modifiers,
		rate = self.rate,
		rate_type = self.rate_type,
		const = self.const,
		player = "Player",
		time = os.time(),
		events = content,
		size = size,
		timings = self.timings,
		single = self.single,
	})
end

---@param s string
---@return sphere.Replay?
function Replay:fromString(s)
	local ok, object = pcall(json.decode, s)

	if not ok then
		return
	end

	local replay = self.replayConverter:convert(object)

	self.hash = object.hash
	self.index = object.index
	self.player = object.player
	self.time = object.time
	self.timings = object.timings
	self.modifiers = object.modifiers
	self.rate = object.rate
	self.const = object.const
	self.single = object.single

	if not object.inputMode then
		self.events = {}
		return self
	end

	local inputMode = InputMode(object.inputMode)
	self.inputMode = inputMode
	self.events = self.replayNanoChart:decode(object.events, object.size, inputMode)

	return self
end

return Replay
