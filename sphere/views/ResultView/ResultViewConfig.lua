local inspect = require("inspect")
local rtime = require("aqua.util.rtime")
local transform = {{1 / 2, -16 / 9 / 2}, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}
local transformLeft = {0, 0, 0, {0, 1 / 1080}, {0, 1 / 1080}, 0, 0, 0, 0}

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

local showLoadedScore = function(self)
	if not self.gameController.rhythmModel.scoreEngine.scoreEntry then
		return
	end
	return self.gameController.selectModel.scoreItem.scoreEntry.id == self.gameController.rhythmModel.scoreEngine.scoreEntry.id
end

local showLoadedListScore = function(self)
	if not self.scoreEntry then
		return
	end
	return self.gameController.rhythmModel.scoreEngine.scoreEntry.id == self.scoreEntry.id
end

local BackgroundBlurSwitch = {
	class = "GaussianBlurView",
	blur = {key = "gameController.configModel.configs.settings.graphics.blur.result"}
}

local Background = {
	class = "BackgroundView",
	transform = transform,
	x = 0,
	y = 0,
	w = 1920,
	h = 1080,
	parallax = 0.01,
	dim = {key = "gameController.configModel.configs.settings.graphics.dim.result"},
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

local ComboGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 1.5,
	color = {1, 1, 0.25, 1},
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "gameController.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "base.combo",
	unit = "base.noteCount",
	point = function(time, startTime, endTime, value, unit)
		local x = (time - startTime) / (endTime - startTime)
		local y = -value / unit + 1
		return x, y
	end,
	show = showLoadedScore
}

local perfectColor = {1, 1, 1, 1}
local notPerfectColor = {1, 0.6, 0.4, 1}
local HitGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 1.5,
	color = function(time, startTime, endTime, value, unit)
		if math.abs(value) <= 0.016 then
			return perfectColor
		end
		return notPerfectColor
	end,
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "gameController.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "misc.deltaTime",
	unit = 0.16,
	point = function(time, startTime, endTime, value, unit)
		if math.abs(value) > 0.12 then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		local y = value / unit / 2 + 0.5
		return x, y
	end,
	show = showLoadedScore
}

local EarlyLateMissGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 3,
	color = {1, 0.2, 0.2, 1},
	background = true,
	backgroundColor = {1, 1, 1, 1},
	backgroundRadius = 4,
	key = "gameController.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "misc.deltaTime",
	unit = 0.16,
	point = function(time, startTime, endTime, value, unit)
		if math.abs(value) <= 0.12 or math.abs(value) > 0.16 then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		local y = math.min(math.max(value, -0.16), 0.16) / unit / 2 + 0.5
		return x, y
	end,
	show = showLoadedScore
}

local MissGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 1,
	color = {1, 0.6, 0.6, 1},
	background = true,
	backgroundColor = {1, 1, 1, 0},
	backgroundRadius = 3,
	key = "gameController.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "base.isMiss",
	unit = 0.16,
	line = function(time, startTime, endTime, value, unit)
		if not value then
			return
		end
		local x = (time - startTime) / (endTime - startTime)
		return x
	end,
	show = showLoadedScore
}

local HpGraph = {
	class = "PointGraphView",
	transform = transform,
	x = 279,
	y = 801,
	w = 1362,
	h = 190,
	radius = 1.5,
	color = {0.25, 1, 0.5, 1},
	background = true,
	backgroundColor = {0, 0, 0, 0.2},
	backgroundRadius = 4,
	key = "gameController.rhythmModel.scoreEngine.scoreSystem.sequence",
	time = "base.currentTime",
	value = "hp.hp",
	unit = 1,
	point = function(time, startTime, endTime, value, unit)
		local x = (time - startTime) / (endTime - startTime)
		local y = -value / unit + 1
		return x, y
	end,
	show = showLoadedScore
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
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "itemIndex",
			-- key = {
			-- 	{"gameController.rhythmModel.scoreEngine.scoreSystem.normalscore.scoreAdjusted", showLoadedListScore},
			-- 	"scoreEntry.score"
			-- },
			-- format = formatScore,
			onNew = false,
			x = 22,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
		},
		{
			type = "text",
			value = "rating",
			onNew = true,
			x = 94,
			baseline = 19,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = {
				{"gameController.rhythmModel.scoreEngine.scoreSystem.normalscore.performance", showLoadedListScore},
				"scoreEntry.rating"
			},
			onNew = false,
			format = "%d",
			x = 94,
			baseline = 45,
			limit = 72,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
		},
		{
			type = "text",
			value = "time rate",
			onNew = true,
			x = 166,
			baseline = 19,
			limit = 94,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = {
				{"gameController.rhythmModel.scoreEngine.timeRate", showLoadedListScore},
				"scoreEntry.timeRate"
			},
			onNew = false,
			x = 166,
			baseline = 45,
			limit = 94,
			align = "right",
			font = {
				filename = "Noto Sans Mono",
				size = 24,
			},
			format = function(timeRate)
				if math.abs(timeRate % 0.05) < 1e-6 then
					return ("%0.2f"):format(timeRate)
				end
				return ("%dQ"):format(10 * math.log(timeRate) / math.log(2))
			end
		},
		{
			type = "text",
			value = "",
			onNew = true,
			x = 162,
			baseline = 19,
			limit = 270,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = "scoreEntry.time",
			ago = true,
			onNew = false,
			x = 162,
			baseline = 19,
			limit = 270,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 16,
			},
		},
		{
			type = "text",
			key = {
				{"gameController.rhythmModel.scoreEngine.inputMode", showLoadedListScore},
				"scoreEntry.inputMode"
			},
			x = 162,
			baseline = 45,
			limit = 270,
			align = "right",
			font = {
				filename = "Noto Sans",
				size = 24,
			},
		},
		{
			type = "circle",
			key = "loaded",
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
	key = "gameController.noteChartModel.noteChartDataEntry.title",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 44,
	baseline = 144 + 45,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 24,
	},
	transform = transform
}

local SongArtistView = {
	class = "ValueView",
	key = "gameController.noteChartModel.noteChartDataEntry.artist",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 45,
	baseline = 144 + 19,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 16,
	},
	transform = transform
}

local ChartNameView = {
	class = "ValueView",
	key = "gameController.noteChartModel.noteChartDataEntry.name",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 116 + 29,
	baseline = 216 + 45,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 24,
	},
	transform = transform
}

local ChartCreatorView = {
	class = "ValueView",
	key = "gameController.noteChartModel.noteChartDataEntry.creator",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 117 + 29,
	baseline = 216 + 19,
	limit = math.huge,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 16,
	},
	transform = transform
}

local ChartInputModeView = {
	class = "ValueView",
	key = "gameController.noteChartModel.noteChartDataEntry.inputMode",
	format = "%s",
	color = {1, 1, 1, 1},
	x = 279 + 29 + 17,
	baseline = 216 + 19,
	limit = 500,
	align = "left",
	font = {
		filename = "Noto Sans",
		size = 16,
	},
	transform = transform
}

local ChartDifficultyView = {
	class = "ValueView",
	key = "gameController.noteChartModel.noteChartDataEntry.difficulty",
	color = {1, 1, 1, 1},
	x = 279 + 29,
	baseline = 216 + 45,
	limit = 72,
	align = "right",
	font = {
		filename = "Noto Sans Mono",
		size = 24,
	},
	transform = transform,
	format = formatDifficulty
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
		x = {454, 454 + 227},
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
		x = {3, 4}, y = 2,
		name = "bpm",
		value = function(self)
			local show = showLoadedScore(self)
			local baseBpm = self.gameController.selectModel.noteChartItem.noteChartDataEntry.bpm
			local bpm = self.gameController.rhythmModel.scoreEngine.bpm
			if not show then
				return math.floor(baseBpm)
			end
			if bpm == baseBpm then
				return math.floor(bpm)
			end
			return ("%d→%d"):format(baseBpm, bpm)
		end,
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {2, 4}, y = 3,
		name = "duration",
		value = function(self)
			local show = showLoadedScore(self)
			local baseLength = self.gameController.selectModel.noteChartItem.noteChartDataEntry.length
			local length = self.gameController.rhythmModel.scoreEngine.length
			if not show then
				return rtime(baseLength)
			end
			if length == baseLength then
				return rtime(length)
			end
			return ("%s→%s"):format(rtime(baseLength), rtime(length))
		end,
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 3,
		name = "density",
		key = {
			{"gameController.rhythmModel.scoreEngine.enps", showLoadedListScore},
			"gameController.selectModel.scoreItem.scoreEntry.difficulty"
		},
		format = formatDifficulty,
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 2, y = 2,
		name = "time rate",
		key = {
			{"gameController.rhythmModel.scoreEngine.baseTimeRate", showLoadedListScore},
			"gameController.selectModel.scoreItem.scoreEntry.timeRate"
		},
		format = "%0.2f",
	},

	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 4, y = 4,
		name = "notes",
		key = "gameController.selectModel.noteChartItem.noteChartDataEntry.noteCount"
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
		x = 1, y = 1,
		name = "accuracy",
		key = {
			{"gameController.rhythmModel.scoreEngine.scoreSystem.normalscore.accuracyAdjusted", showLoadedScore},
			"gameController.selectModel.scoreItem.scoreEntry.accuracy"
		},
		format = formatScore
	},
	{
		type = StageInfo.largeCell,
		valueType = "text",
		x = 2, y = 1,
		name = "score",
		key = {
			{"gameController.rhythmModel.scoreEngine.scoreSystem.normalscore.scoreAdjusted", showLoadedScore},
			"gameController.selectModel.scoreItem.scoreEntry.score"
		},
		format = formatScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 8, y = 3,
		name = "pauses",
		key = "gameController.selectModel.scoreItem.scoreEntry.pausesCount",
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {7, 8}, y = 4,
		name = "adjust",
		key = "gameController.rhythmModel.scoreEngine.scoreSystem.normalscore.adjustRatio",
		format = function(adjustRatio)
			if adjustRatio ~= adjustRatio then
				adjustRatio = 1
			end
			return ("%d%%"):format((1 - adjustRatio) * 100)
		end,
		show = showLoadedScore
	},

	{
		type = StageInfo.smallCell,
		valueType = "bar",
		x = {1, 2}, y = 5,
		name = "perfect/hits",
		key = {
			{"gameController.rhythmModel.scoreEngine.scoreSystem.misc.ratio", showLoadedScore},
			"gameController.selectModel.scoreItem.scoreEntry.ratio"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 5,
		name = "perfect",
		key = {
			{"gameController.rhythmModel.scoreEngine.scoreSystem.judgement.counters.soundsphere.perfect", showLoadedScore},
			"gameController.selectModel.scoreItem.scoreEntry.perfect"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {2, 3}, y = 6,
		name = "not perfect",
		key = {
			{"gameController.rhythmModel.scoreEngine.scoreSystem.judgement.counters.soundsphere.not perfect", showLoadedScore},
			"gameController.selectModel.scoreItem.scoreEntry.notPerfect"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 3, y = 7,
		name = "miss",
		key = {
			{"gameController.rhythmModel.scoreEngine.scoreSystem.base.missCount", showLoadedScore},
			"gameController.selectModel.scoreItem.scoreEntry.missCount"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 6,
		name = "early/late",
		key = {
			{"gameController.rhythmModel.scoreEngine.scoreSystem.misc.earlylate", showLoadedScore},
			"gameController.selectModel.scoreItem.scoreEntry.earlylate"
		},
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
		key = {
			{"gameController.rhythmModel.scoreEngine.scoreSystem.normalscore.normalscore.mean", showLoadedScore},
			"gameController.selectModel.scoreItem.scoreEntry.mean"
		},
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = {3, 4}, y = 7,
		name = "max delta",
		multiplier = 1000,
		format = "%d",
		key = "gameController.rhythmModel.scoreEngine.scoreSystem.misc.maxDeltaTime",
		show = showLoadedScore
	},
	{
		type = StageInfo.smallCell,
		valueType = "text",
		x = 1, y = 7,
		name = "",
		key = "gameController.rhythmModel.scoreEngine.scoreSystem.hp.failed",
		format = function(failed)
			if failed then
				return "fail"
			end
			return "pass"
		end,
		show = showLoadedScore
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
	noModifier = true,
	config = {
		{"gameController.modifierModel.config", showLoadedScore},
		"gameController.selectModel.scoreItem.scoreEntry.modifiers"
	},
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
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
	items = {
		{
			{
				method = "changeScreen",
				value = "Select",
				displayName = "back"
			}
		}
	}
}

local BottomRightScreenMenu = {
	class = "ScreenMenuView",
	transform = transform,
	x = 1187,
	y = 991,
	w = 454,
	h = 89,
	rows = 1,
	columns = 2,
	text = {
		x = 0,
		baseline = 54,
		limit = 227,
		align = "center",
		font = {
			filename = "Noto Sans",
			size = 24,
		},
	},
	items = {
		{
			{
				method = "play",
				value = "replay",
				displayName = "replay"
			},
			{
				method = "play",
				value = "retry",
				displayName = "retry"
			},
		}
	}
}

local InspectScoreSystem = {
	class = "ValueView",
	subscreen = "scoreSystemDebug",
	transform = transformLeft,
	key = "gameController.rhythmModel.scoreEngine.scoreSystem.slice",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {
		filename = "Noto Sans Mono",
		size = 14,
	},
	align = "left",
	color = {1, 1, 1, 1}
}

local InspectCounters = {
	class = "ValueView",
	subscreen = "countersDebug",
	transform = transformLeft,
	key = "gameController.rhythmModel.scoreEngine.scoreSystem.judgement.counters",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {
		filename = "Noto Sans Mono",
		size = 14,
	},
	align = "left",
	color = {1, 1, 1, 1}
}

local InspectScoreEntry = {
	class = "ValueView",
	subscreen = "scoreEntryDebug",
	transform = transformLeft,
	key = "gameController.selectModel.scoreItem.scoreEntry",
	format = function(...)
		return inspect(...)
	end,
	x = 0,
	baseline = 20,
	limit = 1920,
	font = {
		filename = "Noto Sans Mono",
		size = 14,
	},
	align = "left",
	color = {1, 1, 1, 1}
}

local NoteSkinViewConfig = {
	BackgroundBlurSwitch,
	Background,
	BackgroundBlurSwitch,
	BottomScreenMenu,
	BottomRightScreenMenu,
	Rectangle,
	require("sphere.views.HeaderViewConfig"),
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
	MissGraph,
	HitGraph,
	ComboGraph,
	HpGraph,
	EarlyLateMissGraph,
	InspectScoreSystem,
	InspectCounters,
	InspectScoreEntry,
	require("sphere.views.DebugInfoViewConfig"),
}

return NoteSkinViewConfig
