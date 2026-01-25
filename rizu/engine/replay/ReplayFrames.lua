local zlib = require("zlib")
local BinaryEvents = require("rizu.engine.replay.BinaryEvents")
local VirtualInputEvent = require("rizu.input.VirtualInputEvent")

---@class rizu.ReplayFrame
---@field time number
---@field event rizu.VirtualInputEvent

---@class rizu.ReplayFrames
local ReplayFrames = {}

---@param frames rizu.ReplayFrame[]
---@param input_mode ncdk.InputMode
---@return string
function ReplayFrames.encode(frames, input_mode)
	local map = input_mode:getInputMap()

	---@type rizu.BinaryEvent[]
	local binary_events = {}
	for i, frame in ipairs(frames) do
		local event = frame.event
		binary_events[i] = {
			time = frame.time,
			id = event.id,
			value = event.value,
			column = map[event.column],
			pos = event.pos,
		}
	end

	local data = BinaryEvents.encode(binary_events)
	local compressed_data = zlib.compress(data)

	return compressed_data
end

---@param data string
---@param input_mode ncdk.InputMode
---@return rizu.ReplayFrame[]
function ReplayFrames.decode(data, input_mode)
	local uncompressed_data = zlib.inflate(data)
	local binary_events = BinaryEvents.decode(uncompressed_data)

	local map = input_mode:getInputs()

	---@type rizu.ReplayFrame[]
	local frames = {}
	for i, event in ipairs(binary_events) do
		frames[i] = {
			time = event.time,
			event = VirtualInputEvent(event.id, event.value, map[event.column], event.pos)
		}
	end

	return frames
end

return ReplayFrames
