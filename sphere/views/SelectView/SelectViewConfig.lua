local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

local formatScore = function(score)
	if score >= 0.1 then
		return "100+"
	end
	return ("%2.2f"):format(score * 1000)
end

local formatDifficulty = function(difficulty)
	local format = "%.2f"
	if difficulty >= 100 then
		format = "%s"
		difficulty = "100+"
	elseif difficulty >= 10 then
		format = "%.1f"
	end
	return format:format(difficulty)
end

local CacheView = {
	class = "CacheView",
	subscreen = "collections",
	transform = transform,
	x = 733,
	y = 504,
	w = 454,
	h = 72,
	text = {
		type = "text",
		x = 44,
		baseline = 45,
		limit = 1920,
		align = "left",
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
}

local CollectionList = {
	class = "CollectionListView",
	subscreen = "collections",
	transform = transform,
	x = 1187,
	y = 144,
	w = 454,
	h = 792,
	rows = 11,
	elements = {
		{
			type = "text",
			key = "name",
			onNew = false,
			x = 116,
			baseline = 45,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "text",
			key = "shortPath",
			onNew = false,
			x = 117,
			baseline = 19,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "count",
			onNew = false,
			format = function(value)
				return value ~= 0 and value or ""
			end,
			x = 0,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
		},
	},
}

local CollectionScrollBar = {
	class = "ScrollBarView",
	subscreen = "collections",
	transform = transform,
	list = CollectionList,
	x = 1641,
	y = 144,
	w = 16,
	h = 792,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
}

local NoteChartSetList = {
	class = "NoteChartSetListView",
	subscreen = "notecharts",
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
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "text",
			key = "noteChartDataEntry.artist",
			onNew = false,
			x = 45,
			baseline = 19,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
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
	subscreen = "notecharts",
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
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "text",
			key = "noteChartDataEntry.creator",
			onNew = true,
			x = 117,
			baseline = 19,
			limit = math.huge,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "noteChartDataEntry.inputMode",
			onNew = true,
			x = 17,
			baseline = 19,
			limit = 500,
			align = "left",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "noteChartDataEntry.difficulty",
			onNew = false,
			x = 0,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
			format = formatDifficulty
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
	subscreen = "score",
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
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		value = {
			text = {
				x = 22,
				baseline = 44,
				limit = 70,
				align = "right",
				font = {
					filename = "Noto Sans",
					size = 24,
				},
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
			font = {
				filename = "Noto Sans",
				size = 18,
			},
		},
		value = {
			text = {
				x = 22,
				baseline = 49,
				limit = 161,
				align = "right",
				font = {
					filename = "Noto Sans",
					size = 36,
				},
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
		key = "gameController.selectModel.noteChartItem.noteChartDataEntry.bpm"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {1, 2}, y = 3,
		name = "duration",
		key = "gameController.selectModel.noteChartItem.noteChartDataEntry.length",
		time = true
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 4,
		name = "notes",
		key = "gameController.selectModel.noteChartItem.noteChartDataEntry.noteCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "bar",
		x = {3, 4}, y = 4,
		name = "long notes",
		key = "gameController.selectModel.noteChartItem.noteChartDataEntry.longNoteRatio"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 3,
		name = "local offset",
		format = "%d",
		multiplier = 1000,
		key = "gameController.selectModel.noteChartItem.noteChartDataEntry.localOffset"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 4,
		name = "level",
		key = "gameController.selectModel.noteChartItem.noteChartDataEntry.level"
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 2, y = 1,
		name = "score",
		key = "gameController.scoreLibraryModel.firstScoreItem.scoreEntry.score",
		format = formatScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 8,
		name = "played time ago",
		key = "gameController.scoreLibraryModel.firstScoreItem.scoreEntry.time",
		ago = true,
		suffix = ""
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 5,
		name = "rating",
		format = "%d",
		key = "gameController.scoreLibraryModel.firstScoreItem.scoreEntry.rating"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 5,
		name = "accuracy",
		key = "gameController.scoreLibraryModel.firstScoreItem.scoreEntry.accuracy",
		format = formatScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 6,
		name = "miss count",
		format = "%d",
		key = "gameController.scoreLibraryModel.firstScoreItem.scoreEntry.missCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {2, 3}, y = 6,
		name = "density",
		format = formatDifficulty,
		key = "gameController.scoreLibraryModel.firstScoreItem.scoreEntry.difficulty"
	},
}

local BackgroundBlurSwitch = {
	class = "GaussianBlurView",
	blur = {key = "gameController.configModel.configs.settings.graphics.blur.select"}
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "gameController.configModel.configs.settings.graphics.dim.select"},
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
	subscreen = "notecharts",
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
		font = {
			filename = "Noto Sans",
			size = 20,
		},
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
		font = {
			filename = "Noto Sans",
			size = 20,
		},
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
	config = "gameController.modifierModel.config"
}

local StageInfoModifierIconGrid = {
	class = "ModifierIconGridView",
	subscreen = "score",
	transform = transform,
	x = 301,
	y = 598,
	w = 183,
	h = 138,
	columns = 4,
	rows = 3,
	config = "gameController.scoreLibraryModel.firstScoreItem.scoreEntry.modifiers",
	noModifier = true
}

local UpdateStatus = {
	class = "ValueView",
	transform = transform,
	key = "gameController.updateModel.status",
	x = 0,
	baseline = 1070,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {
		filename = "Noto Sans Mono",
		size = 24,
	},
	align = "left",
}

local SessionTime = {
	class = "ValueView",
	transform = transform,
	value = function()
		local event = require("aqua.event")
		local rtime = require("aqua.util.rtime")
		return rtime(event.time - event.startTime)
	end,
	x = 301,
	baseline = 818,
	limit = 1920,
	color = {1, 1, 1, 1},
	font = {
		filename = "Noto Sans",
		size = 20,
	},
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
		font = {
			filename = "Noto Sans",
			size = 24,
		},
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

local BottomRightNotechartsScreenMenu = {
	class = "ScreenMenuView",
	subscreen = "notecharts",
	transform = transform,
	x = 1300,
	y = 991,
	w = 227,
	h = 89,
	rows = 1,
	columns = 1,
	text = {
		x = 0,
		baseline = 54,
		limit = 228,
		align = "center",
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
	items = {{
		{
			method = "addSubscreen",
			value = "collections",
			displayName = "collections"
		},
	}}
}

local BottomRightCollectionsScreenMenu = {
	class = "ScreenMenuView",
	subscreen = "collections",
	transform = transform,
	x = 1300,
	y = 991,
	w = 227,
	h = 89,
	rows = 1,
	columns = 1,
	text = {
		x = 0,
		baseline = 54,
		limit = 228,
		align = "center",
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
	items = {{
		{
			method = "addSubscreen",
			value = "notecharts",
			displayName = "notecharts"
		},
	}}
}

local NoteChartSubScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 279,
	y = 224,
	-- y = 89,
	w = 454,
	h = 55,
	rows = 1,
	columns = 4,
	text = {
		x = 0,
		baseline = 35,
		limit = 454 / 4,
		align = "center",
		font = {
			filename = "Noto Sans",
			size = 20,
		},
	},
	items = {
		{
			{},
			{},
			{
				method = "addSubscreen",
				value = "score",
				displayName = "score"
			},
			{
				method = "addSubscreen",
				value = "options",
				displayName = "options"
			},
		}
	}
}

local NoteChartOptionsScreenMenu = {
	class = "ScreenMenuView",
	subscreen = "options",
	transform = transform,
	x = 506,
	y = 279,
	w = 454,
	h = 522,
	rows = 10,
	columns = 1,
	text = {
		x = 0,
		baseline = 36,
		limit = 228,
		align = "left",
		font = {
			filename = "Noto Sans",
			size = 20,
		},
	},
	items = {
		{
			{
				method = "openDirectory",
				displayName = "open directory"
			}
		},
		{
			{
				method = "updateCache",
				displayName = "update cache"
			}
		},
		{
			{
				method = "updateCache",
				value = true,
				displayName = "update cache (force)"
			}
		},
		--[[
		{
			{
				method = "deleteNoteChart",
				displayName = "delete notechart"
			}
		},
		{
			{
				method = "deleteNoteChartSet",
				displayName = "delete notechart set"
			}
		},
		]]
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
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
	items = {
		{
			{
				method = "changeScreen",
				value = "Settings",
				displayName = "settings"
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
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	Preview,
	NoteChartSetList,
	NoteChartList,
	StageInfo,
	NoteChartSetScrollBar,
	CacheView,
	CollectionList,
	CollectionScrollBar,
	require("sphere.views.HeaderViewConfig"),
	SearchField,
	SortStepper,
	ModifierIconGrid,
	StageInfoModifierIconGrid,
	BottomScreenMenu,
	BottomRightNotechartsScreenMenu,
	BottomRightCollectionsScreenMenu,
	NoteChartSubScreenMenu,
	NoteChartOptionsScreenMenu,
	LeftScreenMenu,
	UpdateStatus,
	SessionTime,
	Rectangle,
	Line,
	require("sphere.views.DebugInfoViewConfig"),
}

return SelectViewConfig
