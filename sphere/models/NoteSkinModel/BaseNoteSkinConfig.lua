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
	data.hitposition = round(imgui.slider("hitposition", data.hitposition, 240, 480, data.hitposition, "Hit position"))
	data.noteWidth = round(imgui.slider("noteWidth", data.noteWidth, 16, 128, data.noteWidth, "Note width"))
	data.noteHeight = round(imgui.slider("noteHeight", data.noteHeight, 16, 128, data.noteHeight, "Note height"))
	data.judgementLineHeight = round(imgui.slider("columnSize", data.judgementLineHeight, 0, 16, data.judgementLineHeight, "J. line height"))
	data.upscroll = imgui.checkbox("upscroll", data.upscroll, "Upscroll")
	data.measureLine = imgui.checkbox("measureLine", data.measureLine, "Measure line")

	imgui.separator()
	self:drawAfter()
end

return config
