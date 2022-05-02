local ffi = require("ffi")
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local ImguiElement = require("sphere.imgui.ImguiElement")
local ImGui_Hotkey = require("aqua.imgui.Hotkey")

local Hotkey = ImguiElement:new()

Hotkey.render = function(self)
	local ptr = self:getPointer("const char*[2]")
	ptr[0] = inside(self, self.key) or "unknown"
	ptr[1] = inside(self, self.device) or "unknown"
	if not ImGui_Hotkey(self.name, ptr, ptr + 1) then return end
	outside(self, self.key, ffi.string(ptr[0]))
	outside(self, self.device, ffi.string(ptr[1]))
end

return Hotkey
