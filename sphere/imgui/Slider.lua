local round = require("aqua.math").round
local map = require("aqua.math").map
local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local imgui = require("cimgui")
local ImguiElement = require("sphere.imgui.ImguiElement")

local Slider = ImguiElement:new()

Slider.render = function(self)
	local ptr = self:getPointer("float[1]")
	ptr[0] = inside(self, self.key)
	local r = self.range
	if not imgui.SliderFloat(self.name, ptr, r[1], r[2], self.format or "%.0f") then return end
	outside(self, self.key, ptr[0])
end

return Slider
