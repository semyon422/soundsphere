local ffi = require("ffi")
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local imgui = require("cimgui")

local ptr = ffi.new("float[1]")
return function(self, config)
	local m = self.multiplier or 1
	ptr[0] = inside(config, self.key) * m
	local r = self.range
	if not imgui.SliderFloat(self.name, ptr, r[1] * m, r[2] * m, self.format or "%.0f") then return end
	outside(config, self.key, ptr[0] / m)
end
