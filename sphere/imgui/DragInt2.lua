local ffi = require("ffi")
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local imgui = require("cimgui")

local ptr = ffi.new("int[2]")
return function(self, config)
	local m = self.multiplier or 1
	local t = inside(config, self.key)
	if type(t) ~= "table" then
		t = {}
	end
	ptr[0], ptr[1] = t[1] * m, t[2] * m
	local r = self.range
	if not imgui.DragInt2(self.name, ptr, self.speed or 1, r[1] * m, r[2] * m, self.format or "%d") then return end
	outside(config, self.key, {ptr[0] / m, ptr[1] / m})
end
