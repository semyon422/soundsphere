local JustConfig = require("sphere.JustConfig")
local imgui = require("sphere.imgui")
local round = require("math_util").round

local config = JustConfig:new()

config.data = --[[data]] {
	autosave = false,
	HitPosition = 240,
	ScorePosition = 240,
	ComboPosition = 240,
	OverallDifficulty = 5,
	HitErrorPosition = 465,
	UpsideDown = false,
	Barline = true,
} --[[/data]]

function config:draw(w, h)
	local data = self.data

	imgui.setSize(w, h, w / 2, 55)
	data.HitPosition = round(imgui.slider("HitPosition", data.HitPosition, 240, 480, data.HitPosition, "Hit Position"))
	data.ScorePosition = round(imgui.slider("ScorePosition", data.ScorePosition, 0, 480, data.ScorePosition, "Score Position"))
	data.ComboPosition = round(imgui.slider("ComboPosition", data.ComboPosition, 0, 480, data.ComboPosition, "Combo Position"))
	data.OverallDifficulty = round(imgui.slider("OverallDifficulty", data.OverallDifficulty, 0, 10, data.OverallDifficulty, "Overall Difficulty"))
	data.HitErrorPosition = round(imgui.slider("HitErrorPosition", data.HitErrorPosition, 0, 480, data.HitErrorPosition, "Hit Error Position"))
	data.UpsideDown = imgui.checkbox("UpsideDown", data.UpsideDown, "Upside Down")
	data.Barline = imgui.checkbox("Barline", data.Barline, "Barline")

	imgui.separator()
	self:drawAfter()
end

return config
