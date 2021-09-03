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
			color = {1, 1, 1, 0.5},
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

local PointGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	r = 3,
	color = {1, 1, 1, 1},
	lineColor = {1, 1, 1, 0.5},
	field = "scoreSystem.sequence",
	time = "base.currentTime",
	value = "base.combo",
	unit = "base.noteCount",
	point = function(time, startTime, endTime, value, unit)
		local x = time / (endTime - startTime)
		local y = -value / unit + 1
		return x, y
	end
}

local ScoreList = {
	class = "ScoreListView",
	transform = transform,
	x = 1187,
	y = 288,
	w = 454,
	h = 504,
	rows = 7,
	elements = {
		{
			type = "text",
			value = "rank",
			onNew = true,
			x = 22,
			baseline = 19,
			limit = 72,
			align = "right",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			field = "itemIndex",
			onNew = false,
			x = 22,
			baseline = 45,
			limit = 72,
			align = "right",
			fontSize = 24,
			fontFamily = "Noto Sans Mono"
		},
		{
			type = "text",
			value = "pp",
			onNew = true,
			x = 116,
			baseline = 19,
			limit = 72,
			align = "right",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			field = "scoreEntry.rating",
			onNew = false,
			format = "%d",
			x = 116,
			baseline = 45,
			limit = 72,
			align = "right",
			fontSize = 24,
			fontFamily = "Noto Sans Mono"
		},
		{
			type = "text",
			value = "played",
			onNew = true,
			x = 162,
			baseline = 19,
			limit = 270,
			align = "right",
			fontSize = 16,
			fontFamily = "Noto Sans"
		},
		{
			type = "text",
			field = "scoreEntry.time",
			ago = true,
			onNew = false,
			x = 162,
			baseline = 45,
			limit = 270,
			align = "right",
			fontSize = 24,
			fontFamily = "Noto Sans"
		},
		{
			type = "circle",
			field = "loaded",
			onNew = false,
			x = 23,
			y = 36,
			r = 7
		},
	},
}

local ScoreScrollBar = {
	class = "ScrollBarView",
	transform = transform,
	list = ScoreList,
	x = 1641,
	y = 288,
	w = 16,
	h = 504,
	rows = 11,
	backgroundColor = {1, 1, 1, 0.33},
	color = {1, 1, 1, 0.66}
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
	defaultValue = 0,
	color = {1, 1, 1, 1},
	x = 279 + 29,
	baseline = 216 + 45,
	limit = 72,
	align = "right",
	fontSize = 24,
	fontFamily = "Noto Sans Mono",
	transform = transform,
	format = function(difficulty)
		local format = "%.2f"
		if difficulty >= 10 then
			format = "%.1f"
		elseif difficulty >= 100 then
			format = "%s"
			difficulty = "100+"
		end
		return format:format(difficulty)
	end
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
		x = {454, 454 + 227},
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
		x = 4, y = 2,
		name = "bpm",
		key = "selectModel.noteChartItem.noteChartDataEntry.bpm"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 3,
		name = "duration",
		key = "selectModel.noteChartItem.noteChartDataEntry.length",
		time = true
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 4,
		name = "notes",
		key = "selectModel.noteChartItem.noteChartDataEntry.noteCount"
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
		x = 1, y = 1,
		name = "accuracy",
		key = "selectModel.scoreItem.scoreEntry.accuracy",
		format = function(score)
			if score >= 0.1 then
				return "100+"
			end
			return ("%2.2f"):format(score * 1000)
		end
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 2, y = 1,
		name = "score",
		key = "selectModel.scoreItem.scoreEntry.score",
		format = function(score)
			if score >= 0.1 then
				return "100+"
			end
			return ("%2.2f"):format(score * 1000)
		end
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 8, y = 4,
		name = "pauses",
		key = "selectModel.scoreItem.scoreEntry.pauses"
	},

	{
		type = StageInfo.smallCell,
		valueType = "bar",
		x = {1, 2}, y = 5,
		name = "perfect/hits",
		key = "scoreSystem.judgement.ratio"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 5,
		name = "perfect",
		key = "scoreSystem.judgement.counters.perfect"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {2, 3}, y = 6,
		name = "not perfect",
		key = "scoreSystem.judgement.counters.not perfect"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 7,
		name = "miss",
		key = "scoreSystem.base.missCount"
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 6,
		name = "early/late",
		key = "scoreSystem.judgement.earlylate",
		format = function(earlylate)
			if earlylate > 1 then
				return ("-%d%%"):format((earlylate - 1) * 100)
			elseif earlylate < 1 then
				return ("%d%%"):format((1 / earlylate - 1) * 100)
			end
			return "0%"
		end
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 5,
		name = "mean",
		multiplier = 1000,
		format = "%0.1f",
		key = "scoreSystem.normalscore.normalscore.mean"
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
	rows = 2,
	noModifier = true
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
	ScoreScrollBar,
	PointGraph,
}

return NoteSkinViewConfig
