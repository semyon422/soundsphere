local inside = require("aqua.util.inside")
local outside = require("aqua.util.outside")
local imgui = require("cimgui")
local ImguiElement = require("sphere.imgui.ImguiElement")
local ImGui_Hotkey = require("aqua.imgui.Hotkey")

local Hotkey = ImguiElement:new()

local keymap = imgui.love.keymap
Hotkey.render = function(self)
	local ptr = self:getPointer("int[1]")
	ptr[0] = keymap[inside(self, self.key)] or 0
	if not ImGui_Hotkey(self.name, ptr) then return end
	outside(self, self.key, keymap[ptr[0]] or 0)
end

return Hotkey
