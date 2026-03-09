local JustConfig = require("sphere.JustConfig")
local imgui = require("imgui")
local just = require("just")

local config = JustConfig()

config.data = --[[data]] {
	autosave = true,
	baseElements = true,
	measureLine = true,
	scale = 1
} --[[/data]]


function config:draw(w, h)
	local data = self.data

	just.indent(10)
	just.text("Ugly piano skin uwu")

	imgui.setSize(w, h, w / 2, 55)
	data.baseElements = imgui.checkbox("baseElements", data.baseElements, "Base Elements")
	data.measureLine = imgui.checkbox("measureLine", data.measureLine, "Measure Line")
	data.scale = imgui.slider1("scale", data.scale, "%d", 1, 5, 1, "Key Scale")

	imgui.separator()
	if imgui.button("Write config file", "Write") then
		self:write()
	end
	data.autosave = imgui.checkbox("autosave", data.autosave, "Autosave")
end

return config
