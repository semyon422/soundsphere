
local screen = {
	w = 1920,
	h = 1080
}

local NoteChartSetList = {
	class = "NoteChartSetListView",
	screen = screen,
	x = 1187,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	title = {
		x = 44,
		y = 17,
		w = 410,
		h = 36,
		align = "left",
		fontSize = 24
	},
	artist = {
		x = 45,
		y = 0,
		w = 409,
		h = 25,
		align = "left",
		fontSize = 16
	},
	point = {
		x = 22,
		y = 36,
		r = 7
	}
}

local NoteChartList = {
	class = "NoteChartListView",
	screen = screen,
	x = 733,
	y = 216,
	w = 454,
	h = 648,
	rows = 9,
	name = {
		x = 116,
		y = 17,
		w = 338,
		h = 36,
		align = "left",
		fontSize = 24
	},
	creator = {
		x = 117,
		y = 0,
		w = 337,
		h = 25,
		align = "left",
		fontSize = 16
	},
	inputMode = {
		x = 17,
		y = 0,
		w = 47,
		h = 25,
		align = "left",
		fontSize = 16
	},
	difficulty = {
		x = 0,
		y = 22,
		w = 72,
		h = 36,
		align = "right",
		fontSize = 24
	},
	point = {
		x = 94,
		y = 36,
		r = 7
	}
}

local StageInfo = {
	class = "StageInfoView",
	screen = screen,
	x = 279,
	y = 279,
	w = 454,
	h = 522,
	smallCell = {
		x = {0, 113, 227, 340},
		y = {0, 50, 101, 152, 319, 370, 421, 472},
		name = {
			x = 22,
			y = -4,
			w = 69,
			h = 27,
			align = "right",
			fontSize = 16
		},
		value = {
			text = {
				x = 22,
				y = 16,
				w = 70,
				h = 36,
				align = "right",
				fontSize = 24
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
		x = {0, 227},
		y = {225},
		name = {
			x = 22,
			y = -6,
			w = 160,
			h = 27,
			align = "right",
			fontSize = 18
		},
		value = {
			text = {
				x = 22,
				y = 7,
				w = 161,
				h = 54,
				align = "right",
				fontSize = 36
			}
		}
	}
}

StageInfo.cells = {
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 3,
		name = "duration",
		key = "length"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 4,
		name = "notes",
		key = "noteCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "bar",
		x = {3, 4}, y = 4,
		name = "long notes",
		key = "longNoteCount"
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
		x = {3, 4}, y = 5,
		name = "played",
		key = "played"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 6,
		name = "pp",
		key = "pp"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 6,
		name = "rank",
		key = "rank"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {1, 2}, y = 8,
		name = "predicted accuracy",
		key = "accuracy"
	},
}

local Background = {
	class = "BackgroundView",
	screen = screen,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 20
}

local Preview = {
	screen = screen,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080
}

local NoteChartSetScrollBar = {
	class = "NoteChartSetScrollBarView",
	screen = screen,
	x = 1641,
	y = 144,
	w = 16,
	h = 792,
	rows = 11
}

local StageInfoScrollBar = {
	class = "StageInfoScrollBarView",
	screen = screen,
	x = 270,
	y = 279,
	w = 8,
	h = 522
}

local Logo = {
	class = "LogoView",
	screen = screen,
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
		y = 18,
		w = 365,
		h = 50,
		fontSize = 32,
		align = "left"
	}
}

local UserInfo = {
	class = "UserInfoView",
	screen = screen,
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
		y = 23,
		w = 365,
		h = 40,
		fontSize = 26,
		align = "right"
	}
}

local SearchField = {
	class = "SearchFieldView",
	screen = screen,
	x = 733,
	y = 89,
	w = 281,
	h = 55,
	frame = {
		x = 6,
		y = 6,
		w = 269,
		h = 43,
		lineStyle = "smooth",
		lineWidth = 1
	},
	text = {
		x = 27,
		y = 11,
		w = 227,
		h = 31,
		align = "left",
		fontSize = 20
	}
}

local SortStepper = {
	class = "SortStepperView",
	screen = screen,
	x = 1014,
	y = 89,
	w = 173,
	h = 55,
	frame = {
		x = 6,
		y = 6,
		w = 161,
		h = 43,
		lineStyle = "smooth",
		lineWidth = 1
	},
	text = {
		x = 27,
		y = 11,
		w = 119,
		h = 31,
		align = "center",
		fontSize = 20
	}
}

local ModifierIconGrid = {
	class = "ModifierIconGridView",
	screen = screen,
	x = 301,
	y = 855,
	w = 410,
	h = 136,
	columns = 6,
	rows = 2
}

local StageInfoModifierIconGrid = {
	class = "ModifierIconGridView",
	screen = screen,
	x = 301,
	y = 598,
	w = 183,
	h = 138,
	columns = 4,
	rows = 3
}

local ScreenMenu = {
	class = "ScreenMenuView",
	screen = screen,
	x = 392,
	y = 991,
	w = 681,
	h = 89,
	columns = 3,
	text = {
		x = 0,
		y = 26,
		w = 228,
		h = 36,
		fontSize = 24,
		align = "center"
	},
	screens = {
		{
			name = "Modifier",
			displayName = "modifiers"
		},
		{
			name = "NoteSkin",
			displayName = "noteskins"
		},
		{
			name = "Input",
			displayName = "input"
		}
	}
}

local SelectViewConfig = {
	Background,
	Preview,
	NoteChartSetList,
	NoteChartList,
	StageInfo,
	NoteChartSetScrollBar,
	StageInfoScrollBar,

	Logo,
	UserInfo,
	SearchField,
	SortStepper,

	ModifierIconGrid,
	StageInfoModifierIconGrid,
	ScreenMenu
}

return SelectViewConfig
