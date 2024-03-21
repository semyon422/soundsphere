local IMidiInput = require("native.midi.IMidiInput")

---@class native.LuaMidiInput: native.IMidiInput
---@operator call: native.LuaMidiInput
local LuaMidiInput = IMidiInput + {}

---@param luamidi table
function LuaMidiInput:new(luamidi)
	self.luamidi = luamidi
end

---@return number
function LuaMidiInput:getPorts()
	if self.ports then
		return self.ports
	end
	self.ports = self.luamidi.getinportcount()
	return self.ports
end

local function next_event(self, in_port)
	in_port = in_port or 1
	local ports = self:getPorts()
	if in_port > ports then
		return
	end

	-- command, note, velocity, delta-time-to-last-event
	local cmd, note, vel, dt = self.luamidi.getMessage(in_port - 1)
	if not cmd then
		return next_event(self, in_port + 1)
	end

	if cmd == 144 and vel ~= 0 then
		return in_port, tonumber(note), true
	elseif cmd == 128 or vel == 0 then
		return in_port, tonumber(note), false
	end
end

---@return function
---@return table
function LuaMidiInput:events()
	return next_event, self
end

return LuaMidiInput
