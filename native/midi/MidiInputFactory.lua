local class = require("class")
local LuaMidiInput = require("native.midi.LuaMidiInput")
local IMidiInput = require("native.midi.IMidiInput")

---@class native.MidiInputFactory
---@operator call: native.MidiInputFactory
local MidiInputFactory = class()

---@return native.IMidiInput
function MidiInputFactory:getMidiInput()
	local midiInput = self.midiInput
	if midiInput then
		return midiInput
	end

	local ok, luamidi = pcall(require, "luamidi")
	if ok then
		midiInput = LuaMidiInput(luamidi)
	else
		midiInput = IMidiInput()
	end

	self.midiInput = midiInput
	return midiInput
end

return MidiInputFactory
