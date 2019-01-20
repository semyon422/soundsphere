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
		name = "good"
	},
	{
		time = 0.120,
		name = "bad"
	},
	{
		time = 0.160,
		name = "miss"
	}
}

return CustomScore
