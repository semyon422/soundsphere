local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local imgui = require("cimgui")
local ImguiElement = require("sphere.imgui.ImguiElement")

local Checkbox = ImguiElement:new()

Checkbox.render = function(self)
	local ptr = self:getPointer("bool[1]")
	ptr[0] = inside(self, self.key)
	if not imgui.Checkbox(self.name, ptr) then return end
	outside(self, self.key, ptr[0])
end

return Checkbox
