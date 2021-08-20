local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local Logo = {
	class = "LogoView",
	transform = transform,
	x = 279,
	y = 0,
	w = 454,
	h = 89,
	image = {
		x = 21,
		y = 20,
		w = 48,
		h = 48
	},
	text = {
		x = 89,
		baseline = 56,
		limit = 365,
		align = "left",
		fontSize = 32,
		fontFamily = "Noto Sans"
	}
}

local UserInfo = {
	class = "UserInfoView",
	transform = transform,
	x = 1187,
	y = 0,
	w = 454,
	h = 89,
	image = {
		x = 386,
		y = 20,
		w = 48,
		h = 48
	},
	text = {
		x = 0,
		baseline = 54,
		limit = 365,
		align = "right",
		fontSize = 26,
		fontFamily = "Noto Sans"
	}
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = 0.5
}

local Rectangle = {
	class = "RectangleView",
	transform = transform,
	rectangles = {
		{
			color = {1, 1, 1, 1},
			mode = "line",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 279,
			y = 801,
			w = 1362,
			h = 190,
			rx = 0,
			ry = 0
		},
	}
}

local ScoreList = {
	class = "ScoreListView",
	transform = transform,
	x = 1187,
	y = 288,
	w = 454,
	h = 504,
	rows = 7,
	playedName = {
		x = 116,
		baseline = 45,
		limit = 338,
		align = "left",
		fontSize = 24,
		fontFamily = "Noto Sans"
	},
	playedValue = {
		x = 117,
		baseline = 19,
		limit = 337,
		align = "left",
		fontSize = 16,
		fontFamily = "Noto Sans"
	},
	performanceName = {
		x = 71,
		baseline = 19,
		limit = 72,
		align = "right",
		fontSize = 16,
		fontFamily = "Noto Sans"
	},
	performanceValue = {
		x = 71,
		baseline = 45,
		limit = 72,
		align = "right",
		fontSize = 24,
		fontFamily = "Noto Sans Mono"
	},
	point = {
		x = 23,
		y = 36,
		r = 7
	}
}

local SongTitleView = {
	class = "ValueView",
	field = "noteChartDataEntry.title",
	format = "%s", defaultValue = "",
	color = {1, 1, 1, 1},
	x = 279 + 44,
	baseline = 144 + 45,
	limit = 410,
	align = "left",
	fontSize = 24,
	fontFamily = "Noto Sans",
	transform = transform
}

local SongArtistView = {
	class = "ValueView",
	field = "noteChartDataEntry.artist",
	format = "%s", defaultValue = "",
	color = {1, 1, 1, 1},
	x = 279 + 45,
	baseline = 144 + 19,
	limit = 409,
	align = "left",
	fontSize = 16,
	fontFamily = "Noto Sans",
	transform = transform
}

local ChartNameView = {
	class = "ValueView",
	field = "noteChartDataEntry.name",
	format = "%s", defaultValue = "",
	color = {1, 1, 1, 1},
	x = 279 + 116,
	baseline = 216 + 45,
	limit = 410,
	align = "left",
	fontSize = 24,
	fontFamily = "Noto Sans",
	transform = transform
}

local ChartCreatorView = {
	class = "ValueView",
	field = "noteChartDataEntry.creator",
	format = "%s", defaultValue = "",
	color = {1, 1, 1, 1},
	x = 279 + 117,
	baseline = 216 + 19,
	limit = 409,
	align = "left",
	fontSize = 16,
	fontFamily = "Noto Sans",
	transform = transform
}

local ChartInputModeView = {
	class = "ValueView",
	field = "noteChartDataEntry.inputMode",
	format = "%s", defaultValue = "",
	color = {1, 1, 1, 1},
	x = 279 + 29 + 17,
	baseline = 216 + 19,
	limit = 47,
	align = "left",
	fontSize = 16,
	fontFamily = "Noto Sans",
	transform = transform
}

local ChartDifficultyView = {
	class = "ValueView",
	field = "noteChartDataEntry.difficulty",
	format = "0.00", defaultValue = 0,
	color = {1, 1, 1, 1},
	x = 279 + 29,
	baseline = 216 + 45,
	limit = 72,
	align = "right",
	fontSize = 24,
	fontFamily = "Noto Sans Mono",
	transform = transform
}

local StageInfo = {
	class = "StageInfoView",
	transform = transform,
	x = 279,
	y = 279,
	w = 454,
	h = 522,
	smallCell = {
		x = {0, 113, 227, 340, 452, 565, 678, 791},
		y = {0, 50, 101, 152, 319, 370, 421, 472},
		name = {
			x = 22,
			baseline = 15,
			limit = 69,
			align = "right",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		value = {
			text = {
				x = 22,
				baseline = 44,
				limit = 70,
				align = "right",
				fontSize = 24,
				fontFamily = "Noto Sans"
			},
			bar = {
				x = 22,
				y = 26,
				w = 70,
				h = 19
			}
		}
	},
	largeCell = {
		x = {454, 454 + 227},
		y = {225},
		name = {
			x = 22,
			baseline = 14,
			limit = 160,
			align = "right",
			fontSize = 18,
			fontFamily = "Noto Sans"
		},
		value = {
			text = {
				x = 22,
				baseline = 49,
				limit = 161,
				align = "right",
				fontSize = 36,
				fontFamily = "Noto Sans"
			}
		}
	}
}

StageInfo.cells = {
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 2,
		name = "bpm",
		key = "bpm"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 3,
		name = "duration",
		key = "length"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 4,
		name = "notes",
		key = "noteCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 4,
		name = "level",
		key = "level"
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 1, y = 1,
		name = "accuracy",
		key = "accuracy"
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 2, y = 1,
		name = "score",
		key = "score"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 5,
		name = "start",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 6,
		name = "max",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 7,
		name = "min",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 6,
		name = "increase",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 7,
		name = "decrease",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 5,
		name = "HTW",
		key = "score"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {2, 3}, y = 7,
		name = "early/late",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 5,
		name = "hits",
		key = "score"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 6,
		name = "misses",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 7,
		name = "mean",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 6, y = 3,
		name = "rank",
		key = "score"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {5, 6}, y = 4,
		name = "difficulty",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 8, y = 4,
		name = "pp",
		key = "played"
	},
}

local ModifierIconGrid = {
	class = "ModifierIconGridView",
	transform = transform,
	x = 755,
	y = 598,
	w = 410,
	h = 136,
	columns = 6,
	rows = 2
}

local BottomScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 279,
	y = 991,
	w = 227,
	h = 89,
	rows = 1,
	columns = 1,
	text = {
		x = 0,
		baseline = 54,
		limit = 227,
		align = "center",
		fontSize = 24,
		fontFamily = "Noto Sans"
	},
	screens = {
		{
			{
				name = "Select",
				displayName = "back"
			}
		}
	}
}

local NoteSkinViewConfig = {
	Background,
	BottomScreenMenu,
	Rectangle,
	Logo,
	UserInfo,
	SongTitleView,
	SongArtistView,
	ChartNameView,
	ChartCreatorView,
	ChartInputModeView,
	ChartDifficultyView,
	StageInfo,
	ModifierIconGrid,
	ScoreList,
}

return NoteSkinViewConfig
