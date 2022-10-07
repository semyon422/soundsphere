local JustConfig = require("sphere.JustConfig")
local imgui = require("sphere.imgui")
local round = require("math_util").round

local config = JustConfig:new()

config.data = --[[data]] {
	autosave = false,
	noteWidth = 48,
	noteHeight = 24,
	hitposition = 450,
	measureLine = true,
	judgementLineHeight = 4,
	upscroll = false
} --[[/data]]

function config:draw(w, h)
	local data = self.data

	imgui.setSize(w, h, w / 2, 55)
	data.hitposition = imgui.slider1("hitposition", data.hitposition, "%d", 240, 480, 1, "Hit position")
	data.noteWidth = imgui.slider1("noteWidth", data.noteWidth, "%d", 16, 128, 1, "Note width")
	data.noteHeight = imgui.slider1("noteHeight", data.noteHeight, "%d", 16, 128, 1, "Note height")
	data.judgementLineHeight = imgui.slider1("jlh", data.judgementLineHeight, "%d", 0, 16, 1, "J. line height")
	data.upscroll = imgui.checkbox("upscroll", data.upscroll, "Upscroll")
	data.measureLine = imgui.checkbox("measureLine", data.measureLine, "Measure line")

	imgui.separator()
	self:drawAfter()
end

return config
