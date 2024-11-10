local class = require("class")
local NanoChart = require("libchart.NanoChart")
local zlib = require("zlib")
local mime = require("mime")

---@class sphere.ReplayNanoChart
---@operator call: sphere.ReplayNanoChart
local ReplayNanoChart = class()

function ReplayNanoChart:new()
	self.nanoChart = NanoChart()
end

---@param inputMode ncdk.InputMode
---@return table
---@return table
---@return number
function ReplayNanoChart:getInputMap(inputMode)
	local inputs = {}

	for inputType, inputCount in pairs(inputMode) do
		inputs[#inputs + 1] = {inputType, inputCount}
	end

	table.sort(inputs, function(a, b)
		if a[2] ~= b[2] then
			return a[2] > b[2]
		else
			return a[1] < b[1]
		end
	end)

	local inputMap = {}
	local reversedInputMap = {}
	local c = 1
	for _, input in ipairs(inputs) do
		for i = 1, input[2] do
			local inputId = input[1] .. i
			inputMap[inputId] = c
			reversedInputMap[c] = inputId
			c = c + 1
		end
	end

	return inputMap, reversedInputMap, #inputs
end

local emptyHash = string.char(0):rep(16)

---@param events table
---@param inputMode ncdk.InputMode
---@return string
---@return number
function ReplayNanoChart:encode(events, inputMode)
	local inputMap, reversedInputMap, inputs = self:getInputMap(inputMode)

	local notes = {}
	for _, event in ipairs(events) do
		notes[#notes + 1] = {
			time = event.time,
			type = event.name:find("pressed") and 1 or 0,
			input = inputMap[event[1]]
		}
	end

	local content = self.nanoChart:encode(emptyHash, inputs, notes)
	local compressedContent = zlib.compress(content)
	return mime.b64(compressedContent), #content
end

---@param content string
---@param size number
---@param inputMode ncdk.InputMode
---@return table
function ReplayNanoChart:decode(content, size, inputMode)
	local inputMap, reversedInputMap, inputs = self:getInputMap(inputMode)

	local uncompressedContent = zlib.uncompress(mime.unb64(content), size)
	local version, hash, inputs, notes = self.nanoChart:decode(uncompressedContent)
	local events = {}
	for _, note in ipairs(notes) do
		events[#events + 1] = {
			reversedInputMap[note.input],
			time = note.time,
			name = note.type == 1 and "keypressed" or "keyreleased",
			virtual = true,
		}
	end

	return events
end

return ReplayNanoChart
