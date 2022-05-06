local ffi = require("ffi")
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local ImGui_Hotkey = require("aqua.imgui.Hotkey")

local ptr = ffi.new("const char*[2]")
return function(self, config)
	ptr[0] = inside(config, self.key) or "unknown"
	ptr[1] = inside(config, self.device) or "unknown"
	if not ImGui_Hotkey(self.name, ptr, ptr + 1) then return end
	outside(config, self.key, ffi.string(ptr[0]))
	outside(config, self.device, ffi.string(ptr[1]))
end
