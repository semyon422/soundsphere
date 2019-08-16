local Score = require("sphere.game.CloudburstEngine.Score")

local CustomScore = Score:new()

CustomScore.passEdge = 0.120
CustomScore.missEdge = 0.160

CustomScore.timegates = {
	{
		time = 0.016,
		name = "great"
	},
	{
		time = 0.040,
		name = "good",
		nameLate = "late good",
		nameEarly = "early good"
	},
	{
		time = 0.120,
		name = "bad",
		nameLate = "late bad",
		nameEarly = "early bad"
	},
	{
		time = 0.160,
		name = "miss"
	}
}

Score.grades = {
	{
		time = 0.012,
		name = "SS"
	},
	{
		time = 0.032,
		name = "S"
	},
	{
		time = 0.040,
		name = "A"
	},
	{
		time = 0.056,
		name = "B"
	},
	{
		time = 0.072,
		name = "C"
	},
	{
		time = 0.092,
		name = "D"
	},
	{
		time = 0.120,
		name = "E"
	},
	{
		name = "F"
	},
}

return CustomScore
