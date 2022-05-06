local ffi = require("ffi")
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local imgui = require("cimgui")

local ptr = ffi.new("bool[1]")
return function(self, config)
	ptr[0] = inside(config, self.key)
	if not imgui.Checkbox(self.name, ptr) then return end
	outside(config, self.key, ptr[0])
end
