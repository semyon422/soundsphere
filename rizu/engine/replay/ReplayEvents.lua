local zlib = require("zlib")
local BinaryEvents = require("rizu.engine.replay.BinaryEvents")
local VirtualInputEvent = require("rizu.input.VirtualInputEvent")

---@alias rizu.ReplayEvent {[1]: number, [2]: rizu.VirtualInputEvent}

---@class rizu.ReplayEvents
local ReplayEvents = {}

---@param events rizu.ReplayEvent[]
---@param input_mode ncdk.InputMode
---@return string
function ReplayEvents.encode(events, input_mode)
	local map = input_mode:getInputMap()

	---@type rizu.BinaryEvent[]
	local binary_events = {}
	for i, event in ipairs(events) do
		local t, e = event[1], event[2]
		binary_events[i] = {
			time = t,
			id = e.id,
			value = e.value,
			column = map[e.column],
			pos = e.pos,
		}
	end

	local data = BinaryEvents.encode(binary_events)
	local compressed_data = zlib.compress(data)

	return compressed_data
end

---@param data string
---@param input_mode ncdk.InputMode
---@return rizu.ReplayEvent[]
function ReplayEvents.decode(data, input_mode)
	local uncompressed_data = zlib.inflate(data)
	local binary_events = BinaryEvents.decode(uncompressed_data)

	local map = input_mode:getInputs()

	---@type rizu.ReplayEvent[]
	local events = {}
	for i, event in ipairs(binary_events) do
		local e = VirtualInputEvent(event.id, event.value, map[event.column], event.pos)
		events[i] = {event.time, e}
	end

	return events
end

return ReplayEvents
