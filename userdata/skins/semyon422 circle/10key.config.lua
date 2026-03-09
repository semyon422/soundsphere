local JustConfig = require("sphere.JustConfig")
local imgui = require("imgui")
local just = require("just")

local config = JustConfig()

config.data = --[[data]] {
	autosave = true,
	colorsnap = false,
	columnSize = 38,
	hitposition = 380,
	measureLine = true,
	mines = true,
	upscroll = false
} --[[/data]]

function config:draw(w, h)
	local data = self.data

	just.indent(10)
	just.text("Skin by semyon422")

	imgui.setSize(w, h, w / 2, 55)
	data.hitposition = imgui.slider1("hitposition", data.hitposition, "%d", 240, 480, 1, "Hit position")
	data.columnSize = imgui.slider1("columnSize", data.columnSize, "%d", 16, 128, 1, "Column size")
	data.upscroll = imgui.checkbox("upscroll", data.upscroll, "Upscroll")
	data.measureLine = imgui.checkbox("measureLine", data.measureLine, "Measure line")
	data.mines = imgui.checkbox("mines", data.mines, "Mines")
	data.colorsnap = imgui.checkbox("colorsnap", data.colorsnap, "Colorsnap")

	imgui.separator()
	if imgui.button("Write config file", "Write") then
		self:write()
	end
	data.autosave = imgui.checkbox("autosave", data.autosave, "Autosave")
end

return config
