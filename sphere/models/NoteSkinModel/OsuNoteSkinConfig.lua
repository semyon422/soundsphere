local JustConfig = require("sphere.JustConfig")
local imgui = require("imgui")

local config = JustConfig()

config.data = --[[data]] {
	mania = {},
	autosave = false,
	DisableLimits = false,
	HitErrorPosition = 465,
	HitErrorTransparancy = 0.5,
	JudgementAnimation = true,
	Barline = true,
	ColumnLineMode = "default",
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

function config:init()
	local _mania = self.mania
	local mania = self.data.mania
	mania.HitPosition = _mania.HitPosition
	mania.ScorePosition = _mania.ScorePosition
	mania.ComboPosition = _mania.ComboPosition
	mania.UpsideDown = _mania.UpsideDown
	mania.SplitStages = _mania.SplitStages
end

function config:draw(w, h)
	local data = self.data
	local mania = data.mania

	imgui.setSize(w, h, w / 2, 55)
	mania.HitPosition = imgui.slider1("HitPosition", mania.HitPosition, "%d", 240, 480, 1, "Hit Position")
	mania.ScorePosition = imgui.slider1("ScorePosition", mania.ScorePosition, "%d", 0, 480, 1, "Score Position")
	mania.ComboPosition = imgui.slider1("ComboPosition", mania.ComboPosition, "%d", 0, 480, 1, "Combo Position")
	mania.UpsideDown = imgui.checkbox("UpsideDown", mania.UpsideDown, "Upside Down")
	mania.SplitStages = imgui.checkbox("SplitStages", mania.SplitStages, "SplitStages")

	imgui.separator()
	data.HitErrorPosition = imgui.slider1("HitErrorPosition", data.HitErrorPosition, "%d", 0, 480, 1, "Hit Error Position")
	data.HitErrorTransparancy = imgui.slider1("HitErrorTransparancy", data.HitErrorTransparancy, "%.1f", 0, 1, 0.1, "Hit Error Transparancy")
	data.Barline = imgui.checkbox("Barline", data.Barline, "Barline")
	data.JudgementAnimation = imgui.checkbox("JudgementAnimation", data.JudgementAnimation, "Judgement animation")
	data.ColumnLineMode = imgui.combo("ColumnLineMode", data.ColumnLineMode, {"default", "symmetric"}, nil, "Column Line Mode")
	data.DisableLimits = imgui.checkbox("DisableLimits", data.DisableLimits, "Disable osu skin limits")

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
