local KeyValue = require("osu.sections.KeyValue")

---@class osu.EditorSection: osu.KeyValue
---@operator call: osu.EditorSection
local DifficultySection = KeyValue + {}

DifficultySection.space = false

DifficultySection.HPDrainRate = "5"
DifficultySection.CircleSize = "4"
DifficultySection.OverallDifficulty = "5"
DifficultySection.ApproachRate = "5"
DifficultySection.SliderMultiplier = "1.4"
DifficultySection.SliderTickRate = "1"

DifficultySection.keys = {
	"HPDrainRate",
	"CircleSize",
	"OverallDifficulty",
	"ApproachRate",
	"SliderMultiplier",
	"SliderTickRate",
}

return DifficultySection
