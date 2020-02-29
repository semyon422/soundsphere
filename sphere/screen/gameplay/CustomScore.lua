local Score = require("sphere.screen.gameplay.LogicEngine.Score")

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
	{time = 0.001,	name = "auto"	},
	{time = 0.002,	name = "cheater"},
	{time = 0.004,	name = ">_<"	},
	{time = 0.006,	name = "wtf?"	},
	{time = 0.008,	name = "ET"		},
	{time = 0.010,	name = "$$$"	},
	{time = 0.012,	name = "SS"		},
	{time = 0.016,	name = "S++"	},
	{time = 0.020,	name = "S+"		},
	{time = 0.024,	name = "S"		},
	{time = 0.028,	name = "A+"		},
	{time = 0.032,	name = "A"		},
	{time = 0.048,	name = "B"		},
	{time = 0.98,	name = "E"		},
	{name = "F"},
}

return CustomScore
