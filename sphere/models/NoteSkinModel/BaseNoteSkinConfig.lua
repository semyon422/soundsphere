local JustConfig = require("sphere.JustConfig")
local imgui = require("imgui")

local config = JustConfig()

config.data = --[[data]] {
	autosave = false,
	offset = 0,
	align = "center",
	noteWidth = 48,
	noteHeight = 24,
	hitposition = 450,
	measureLine = true,
	judgementLineHeight = 4,
	upscroll = false,
	covers = {
		top = {
			enabled = false,
			position = 240,
			size = 48,
		},
		bottom = {
			enabled = false,
			position = 240,
			size = 48,
		},
	},
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

	data.offset = imgui.slider1("offset", data.offset, "%d", -240, 240, 1, "Lanes offset")
	data.align = imgui.combo("align", data.align, {"left", "right", "center"}, nil, "Lanes align")

	imgui.separator()
	local cover = data.covers.top
	cover.enabled = imgui.checkbox("covers.top.enabled", cover.enabled, "Top lane cover")
	cover.position = imgui.slider1("covers.top.position", cover.position, "%d", 0, 480, 1, "Position")
	cover.size = imgui.slider1("covers.top.size", cover.size, "%d", 0, 480, 1, "Size")

	imgui.separator()
	cover = data.covers.bottom
	cover.enabled = imgui.checkbox("covers.bottom.enabled", cover.enabled, "Bottom lane cover")
	cover.position = imgui.slider1("covers.bottom.position", cover.position, "%d", 0, 480, 1, "Position")
	cover.size = imgui.slider1("covers.bottom.size", cover.size, "%d", 0, 480, 1, "Size")

	imgui.separator()
	self:drawAfter()
end

return config
