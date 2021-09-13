local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local formatScore = function(score)
	if score >= 0.1 then
		return "100+"
	end
	return ("%2.2f"):format(score * 1000)
end

local NoteChartSetList = {
	class = "NoteChartSetListView",
	transform = transform,
	x = 1187,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	elements = {
		{
			type = "text",
			key = "noteChartDataEntry.title",
			onNew = false,
			x = 44,
			baseline = 45,
			limit = math.huge,
			align = "left",
			fontSize = 24,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			key = "noteChartDataEntry.artist",
			onNew = false,
			x = 45,
			baseline = 19,
			limit = math.huge,
			align = "left",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "circle",
			key = "tagged",
			onNew = false,
			x = 22,
			y = 36,
			r = 7
		},
	},
}

local NoteChartList = {
	class = "NoteChartListView",
	transform = transform,
	x = 733,
	y = 216,
	w = 454,
	h = 648,
	rows = 9,
	elements = {
		{
			type = "text",
			key = "noteChartDataEntry.name",
			onNew = false,
			x = 116,
			baseline = 45,
			limit = math.huge,
			align = "left",
			fontSize = 24,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			key = "noteChartDataEntry.creator",
			onNew = true,
			x = 117,
			baseline = 19,
			limit = math.huge,
			align = "left",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			key = "noteChartDataEntry.inputMode",
			onNew = true,
			x = 17,
			baseline = 19,
			limit = 47,
			align = "left",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			key = "noteChartDataEntry.difficulty",
			onNew = false,
			x = 0,
			baseline = 45,
			limit = 72,
			align = "right",
			fontSize = 24,
			fontFamily = "Noto Sans Mono",
			format = function(difficulty)
				local format = "%.2f"
				if difficulty >= 100 then
					format = "%s"
					difficulty = "100+"
				elseif difficulty >= 10 then
					format = "%.1f"
				end
				return format:format(difficulty)
			end
		},
		{
			type = "circle",
			key = "tagged",
			onNew = false,
			x = 94,
			y = 36,
			r = 7
		},
	},
}

local StageInfo = {
	class = "StageInfoView",
	transform = transform,
	x = 279,
	y = 279,
	w = 454,
	h = 522,
	smallCell = {
		x = {0, 113, 227, 340},
		y = {0, 50, 101, 152, 319, 370, 421, 472},
		name = {
			x = 22,
			baseline = 18,
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
		x = {0, 227},
		y = {225},
		name = {
			x = 22,
			baseline = 15,
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
		x = 1, y = 3,
		name = "bpm",
		format = "%d",
		key = "selectModel.noteChartItem.noteChartDataEntry.bpm"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 3,
		name = "duration",
		key = "selectModel.noteChartItem.noteChartDataEntry.length",
		time = true
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 4,
		name = "notes",
		key = "selectModel.noteChartItem.noteChartDataEntry.noteCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "bar",
		x = {3, 4}, y = 4,
		name = "long notes",
		key = "selectModel.noteChartItem.noteChartDataEntry.longNoteRatio"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 4,
		name = "level",
		key = "selectModel.noteChartItem.noteChartDataEntry.level"
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 2, y = 1,
		name = "score",
		key = "scoreLibraryModel.firstScoreItem.scoreEntry.score",
		format = formatScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 8,
		name = "played time ago",
		key = "scoreLibraryModel.firstScoreItem.scoreEntry.time",
		ago = true,
		suffix = ""
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 5,
		name = "rating",
		format = "%d",
		key = "scoreLibraryModel.firstScoreItem.scoreEntry.rating"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 5,
		name = "accuracy",
		key = "scoreLibraryModel.firstScoreItem.scoreEntry.accuracy",
		format = formatScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 6,
		name = "density",
		format = "%0.2f",
		key = "scoreLibraryModel.firstScoreItem.scoreEntry.density"
	},
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "settings.graphics.dim.select"},
	blur = {key = "settings.graphics.blur.select"}
}

local Preview = {
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080
}

local NoteChartSetScrollBar = {
	class = "ScrollBarView",
	transform = transform,
	list = NoteChartSetList,
	x = 1641,
	y = 144,
	w = 16,
	h = 792,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
}

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
	key = "onlineConfig.username",
	file = "userdata/avatar.png",
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

local SearchField = {
	class = "SearchFieldView",
	transform = transform,
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
		baseline = 35,
		limit = 227,
		align = "left",
		fontSize = 20,
		fontFamily = "Noto Sans"
	},
	point = {
		r = 7
	}
}

local SortStepper = {
	class = "SortStepperView",
	transform = transform,
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
		baseline = 35,
		limit = 119,
		align = "center",
		fontSize = 20,
		fontFamily = "Noto Sans"
	}
}

local ModifierIconGrid = {
	class = "ModifierIconGridView",
	transform = transform,
	x = 301,
	y = 855,
	w = 410,
	h = 136,
	columns = 6,
	rows = 2,
	config = "modifierModel.config"
}

local StageInfoModifierIconGrid = {
	class = "ModifierIconGridView",
	transform = transform,
	x = 301,
	y = 598,
	w = 183,
	h = 138,
	columns = 4,
	rows = 3,
	config = "scoreLibraryModel.firstScoreItem.scoreEntry.modifiers",
	noModifier = true
}

local UpdateStatus = {
	class = "ValueView",
	transform = transform,
	key = "updateModel.status",
	x = 0,
	baseline = 1070,
	limit = 1920,
	color = {1, 1, 1, 1},
	fontSize = 24,
	fontFamily = "Noto Sans Mono",
	align = "left",
}

local BottomScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 392,
	y = 991,
	w = 681,
	h = 89,
	rows = 1,
	columns = 3,
	text = {
		x = 0,
		baseline = 54,
		limit = 228,
		align = "center",
		fontSize = 24,
		fontFamily = "Noto Sans"
	},
	items = {
		{
			{
				method = "changeScreen",
				value = "Modifier",
				displayName = "modifiers"
			},
			{
				method = "changeScreen",
				value = "NoteSkin",
				displayName = "noteskins"
			},
			{
				method = "changeScreen",
				value = "Input",
				displayName = "input"
			}
		}
	}
}

local LeftScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 89,
	y = 279,
	w = 190,
	h = 261,
	rows = 4,
	columns = 1,
	text = {
		x = 0,
		baseline = 41,
		limit = 190,
		align = "left",
		fontSize = 24,
		fontFamily = "Noto Sans"
	},
	items = {
		{
			{
				method = "changeScreen",
				value = "Settings",
				displayName = "settings"
			}
		},
		{
			{
				method = "changeScreen",
				value = "Collection",
				displayName = "collection"
			}
		},
	}
}

local Rectangle = {
	class = "RectangleView",
	transform = transform,
	rectangles = {
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 733,
			y = 504,
			w = 4,
			h = 72,
			rx = 0,
			ry = 0
		},
		{
			color = {1, 1, 1, 1},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 1183,
			y = 504,
			w = 4,
			h = 72,
			rx = 0,
			ry = 0
		},
		{
			color = {1, 1, 1, 0.25},
			mode = "fill",
			lineStyle = "smooth",
			lineWidth = 1,
			x = 277,
			y = 279,
			w = 2,
			h = 522,
			rx = 1,
			ry = 1
		}
	}
}

local Line = {
	class = "LineView",
	transform = transform,
	lines = {}
}

local SelectViewConfig = {
	Background,
	Preview,
	NoteChartSetList,
	NoteChartList,
	StageInfo,
	NoteChartSetScrollBar,

	Logo,
	UserInfo,
	SearchField,
	SortStepper,

	ModifierIconGrid,
	StageInfoModifierIconGrid,
	BottomScreenMenu,
	LeftScreenMenu,
	UpdateStatus,

	Rectangle,
	Line
}

return SelectViewConfig
